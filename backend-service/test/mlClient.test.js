import test from 'node:test';
import assert from 'node:assert';
import { 
  checkHealth, 
  startImageEnhancement, 
  getImageEnhancementStatus, 
  startAudioTranscription, 
  getAudioTranscriptionStatus, 
  pollJobStatus 
} from '../src/services/mlClient.js';

// Mock the global fetch object
const originalFetch = global.fetch;

test('mlClient test suite', async (t) => {

  t.afterEach(() => {
    global.fetch = originalFetch;
    delete process.env.ML_SERVICE_URL;
    delete process.env.ML_INTERNAL_API_KEY;
  });

  await t.test('checkHealth - success', async () => {
    process.env.ML_SERVICE_URL = 'http://test.local';
    
    global.fetch = async (url, options) => {
      assert.strictEqual(url, 'http://test.local/health');
      assert.strictEqual(options.method, 'GET');
      return {
        ok: true,
        json: async () => ({ status: 'ok' })
      };
    };

    const res = await checkHealth();
    assert.deepStrictEqual(res, { status: 'ok' });
  });

  await t.test('checkHealth - unavailable / network error', async () => {
    global.fetch = async () => {
      throw new Error('fetch failed');
    };

    await assert.rejects(
      async () => await checkHealth(),
      (err) => {
        assert.strictEqual(err.status, 502);
        assert.match(err.message, /ML Service Unreachable/);
        return true;
      }
    );
  });

  await t.test('startImageEnhancement - sends correct headers (no leak)', async () => {
    process.env.ML_INTERNAL_API_KEY = 'secret-key';
    
    global.fetch = async (url, options) => {
      assert.strictEqual(options.headers['X-Internal-API-Key'], 'secret-key');
      assert.strictEqual(JSON.parse(options.body).imageUrl, 'http://image.jpg');
      return {
        ok: true,
        json: async () => ({ jobId: '123' })
      };
    };

    const res = await startImageEnhancement('http://image.jpg');
    assert.deepStrictEqual(res, { jobId: '123' });
  });

  await t.test('startImageEnhancement - server error', async () => {
    global.fetch = async () => ({
      ok: false,
      status: 500,
      statusText: 'Internal Server Error',
      json: async () => ({ detail: 'Something failed' })
    });

    await assert.rejects(
      async () => await startImageEnhancement('http://img'),
      (err) => {
        assert.strictEqual(err.status, 502);
        assert.match(err.message, /Image enhancement request failed/);
        assert.deepStrictEqual(err.details, { detail: 'Something failed' });
        return true;
      }
    );
  });

  await t.test('pollJobStatus - success after polling', async () => {
    let attempt = 0;
    const mockStatusFn = async (jobId) => {
      assert.strictEqual(jobId, 'job-abc');
      attempt++;
      if (attempt === 1) return { status: 'QUEUED' };
      if (attempt === 2) return { status: 'PROCESSING' };
      return { status: 'SUCCESS', result: { imageUrl: 'done.jpg' } };
    };

    const result = await pollJobStatus(mockStatusFn, 'job-abc', 5, 10);
    assert.deepStrictEqual(result, { imageUrl: 'done.jpg' });
    assert.strictEqual(attempt, 3);
  });

  await t.test('pollJobStatus - failure status', async () => {
    const mockStatusFn = async () => ({ status: 'FAILED', errorMessage: 'Bad image' });

    await assert.rejects(
      async () => await pollJobStatus(mockStatusFn, 'job-abc', 5, 10),
      (err) => {
        assert.strictEqual(err.status, 500);
        assert.match(err.message, /Bad image/);
        return true;
      }
    );
  });

  await t.test('pollJobStatus - timeout max attempts', async () => {
    const mockStatusFn = async () => ({ status: 'PROCESSING' });

    await assert.rejects(
      async () => await pollJobStatus(mockStatusFn, 'job-abc', 2, 10),
      (err) => {
        assert.strictEqual(err.status, 504);
        assert.match(err.message, /timed out after 2 attempts/);
        return true;
      }
    );
  });
});
