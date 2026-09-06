

const getMlConfig = () => {
  const url = process.env.ML_SERVICE_URL || 'http://localhost:8000';
  const apiKey = process.env.ML_INTERNAL_API_KEY;
  if (!apiKey) {
    console.warn('ML_INTERNAL_API_KEY is not set. Requests to protected ML endpoints will fail.');
  }
  return { url, apiKey };
};

const defaultHeaders = () => ({
  'Content-Type': 'application/json',
  'X-Internal-API-Key': getMlConfig().apiKey || ''
});

const handleFetchError = async (response) => {
  if (!response.ok) {
    let errorData = {};
    try {
      errorData = await response.json();
    } catch (e) {
      errorData = { detail: await response.text() };
    }
    const err = new Error(`ML Service Error: ${response.status} ${response.statusText}`);
    err.status = response.status >= 500 ? 502 : 500; // Map ML service errors to 502 Bad Gateway if it's an upstream issue
    err.details = errorData;
    throw err;
  }
  return response.json();
};

export const checkHealth = async () => {
  try {
    const { url } = getMlConfig();
    const response = await fetch(`${url}/health`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      },
      // Short timeout for health
      signal: AbortSignal.timeout(3000)
    });
    return await handleFetchError(response);
  } catch (error) {
    const err = new Error(`ML Service Unreachable: ${error.message}`);
    err.status = 502;
    if (error.details) err.details = error.details;
    throw err;
  }
};

export const startImageEnhancement = async (imageUrl, listingId = null) => {
  try {
    const { url } = getMlConfig();
    const response = await fetch(`${url}/image/enhance`, {
      method: 'POST',
      headers: defaultHeaders(),
      body: JSON.stringify({ imageUrl, listingId }),
      signal: AbortSignal.timeout(10000)
    });
    return await handleFetchError(response);
  } catch (error) {
    const err = new Error(`Image enhancement request failed: ${error.message}`);
    err.status = 502;
    if (error.details) err.details = error.details;
    throw err;
  }
};

export const getImageEnhancementStatus = async (jobId) => {
  try {
    const { url } = getMlConfig();
    const response = await fetch(`${url}/image/enhance/${jobId}`, {
      method: 'GET',
      headers: defaultHeaders(),
      signal: AbortSignal.timeout(5000)
    });
    return await handleFetchError(response);
  } catch (error) {
    const err = new Error(`Failed to get image status: ${error.message}`);
    err.status = 502;
    if (error.details) err.details = error.details;
    throw err;
  }
};

export const startAudioTranscription = async (audioUrl, listingId = null, hintLanguage = null) => {
  try {
    const { url } = getMlConfig();
    const payload = { audioUrl };
    if (listingId) payload.listingId = listingId;
    if (hintLanguage) payload.hintLanguage = hintLanguage;

    const response = await fetch(`${url}/audio/transcribe`, {
      method: 'POST',
      headers: defaultHeaders(),
      body: JSON.stringify(payload),
      signal: AbortSignal.timeout(10000)
    });
    return await handleFetchError(response);
  } catch (error) {
    const err = new Error(`Audio transcription request failed: ${error.message}`);
    err.status = 502;
    throw err;
  }
};

export const getAudioTranscriptionStatus = async (jobId) => {
  try {
    const { url } = getMlConfig();
    const response = await fetch(`${url}/audio/transcribe/${jobId}`, {
      method: 'GET',
      headers: defaultHeaders(),
      signal: AbortSignal.timeout(5000)
    });
    return handleFetchError(response);
  } catch (error) {
    const err = new Error(`Failed to get audio status: ${error.message}`);
    err.status = 502;
    throw err;
  }
};

/**
 * Polls a job status function until SUCCESS, FAILED, or timeout.
 * @param {Function} statusFn - Function returning a promise that resolves to job status (e.g. getImageEnhancementStatus)
 * @param {string} jobId - Job ID to poll
 * @param {number} maxAttempts - Maximum number of polling attempts
 * @param {number} intervalMs - Interval between attempts in milliseconds
 * @returns {Promise<Object>} - The final successful result
 */
export const pollJobStatus = async (statusFn, jobId, maxAttempts = 30, intervalMs = 2000) => {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const result = await statusFn(jobId);
    
    if (result.status === 'SUCCESS') {
      return result.result;
    }
    
    if (result.status === 'FAILED') {
      const err = new Error(`ML Job Failed: ${result.errorMessage || 'Unknown error'}`);
      err.status = 500;
      throw err;
    }
    
    // Status is likely QUEUED or PROCESSING, wait and retry
    if (attempt < maxAttempts) {
      await new Promise(resolve => setTimeout(resolve, intervalMs));
    }
  }
  
  const err = new Error(`Job polling timed out after ${maxAttempts} attempts`);
  err.status = 504; // Gateway Timeout
  throw err;
};
