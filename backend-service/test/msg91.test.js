import test from 'node:test';
import assert from 'node:assert/strict';
import { verifyMsg91AccessToken } from '../src/services/msg91Service.js';

test('MSG91 Service Tests', async (t) => {
  const originalFetch = global.fetch;
  const originalEnv = process.env.MSG91_AUTHKEY;

  t.afterEach(() => {
    global.fetch = originalFetch;
    process.env.MSG91_AUTHKEY = originalEnv;
  });

  await t.test('1. Missing access token', async () => {
    await assert.rejects(
      async () => {
        await verifyMsg91AccessToken('');
      },
      (err) => {
        assert.equal(err.message, 'Access token is required');
        return true;
      }
    );
  });

  await t.test('2. Missing MSG91_AUTHKEY configuration', async () => {
    delete process.env.MSG91_AUTHKEY;
    await assert.rejects(
      async () => {
        await verifyMsg91AccessToken('some-token');
      },
      (err) => {
        assert.equal(err.message, 'MSG91 configuration is missing');
        return true;
      }
    );
  });

  await t.test('3. Successful MSG91 verification', async () => {
    process.env.MSG91_AUTHKEY = 'test_authkey';
    
    global.fetch = async (url, options) => {
      // Confirm authkey is NOT logged or thrown, just sent in payload correctly
      const payload = JSON.parse(options.body);
      assert.equal(payload.authkey, 'test_authkey');
      assert.equal(payload['access-token'], 'valid-token');
      
      return {
        ok: true,
        json: async () => ({ type: 'success', message: 'token verified', messageData: { mobile: '919999999999' } }),
      };
    };

    const result = await verifyMsg91AccessToken('valid-token');
    assert.equal(result.success, true);
    assert.equal(result.data.type, 'success');
  });

  await t.test('4. MSG91 invalid token response', async () => {
    process.env.MSG91_AUTHKEY = 'test_authkey';
    
    global.fetch = async (url, options) => {
      return {
        ok: true,
        json: async () => ({ type: 'error', message: 'Invalid token', messageData: { mobile: '919999999999' } }),
      };
    };

    await assert.rejects(
      async () => {
        await verifyMsg91AccessToken('invalid-token');
      },
      (err) => {
        assert.equal(err.message, 'Invalid or expired MSG91 access token');
        assert.ok(!err.message.includes('test_authkey'));
        assert.ok(!err.message.includes('invalid-token'));
        return true;
      }
    );
  });

  await t.test('5. MSG91 server error (HTTP non-ok)', async () => {
    process.env.MSG91_AUTHKEY = 'test_authkey';
    
    global.fetch = async (url, options) => {
      return {
        ok: false,
        status: 500,
      };
    };

    await assert.rejects(
      async () => {
        await verifyMsg91AccessToken('server-error-token');
      },
      (err) => {
        assert.equal(err.message, 'MSG91 verification failed with status: 500');
        assert.ok(!err.message.includes('test_authkey'));
        assert.ok(!err.message.includes('server-error-token'));
        return true;
      }
    );
  });

  await t.test('6. Network failure', async () => {
    process.env.MSG91_AUTHKEY = 'test_authkey';
    
    global.fetch = async () => {
      const error = new Error('fetch failed');
      error.cause = { code: 'ENOTFOUND' };
      throw error;
    };

    await assert.rejects(
      async () => {
        await verifyMsg91AccessToken('network-error-token');
      },
      (err) => {
        assert.equal(err.message, 'Network error during MSG91 verification');
        assert.ok(!err.message.includes('test_authkey'));
        assert.ok(!err.message.includes('network-error-token'));
        return true;
      }
    );
  });

  await t.test('7 & 8. Confirm Authkey and Access token are not exposed in generic errors', async () => {
    process.env.MSG91_AUTHKEY = 'SECRET_AUTHKEY_123';
    
    global.fetch = async () => {
      // Simulate unexpected JS error containing the secret
      throw new Error('Something crashed processing SECRET_AUTHKEY_123 and token SECRET_TOKEN_456');
    };

    await assert.rejects(
      async () => {
        await verifyMsg91AccessToken('SECRET_TOKEN_456');
      },
      (err) => {
        assert.equal(err.message, 'MSG91 verification failed');
        assert.ok(!err.message.includes('SECRET_AUTHKEY_123'));
        assert.ok(!err.message.includes('SECRET_TOKEN_456'));
        return true;
      }
    );
  });
});
