export const verifyMsg91AccessToken = async (accessToken) => {
  if (!accessToken) {
    throw new Error('Access token is required');
  }

  const authKey = process.env.MSG91_AUTHKEY;
  if (!authKey) {
    throw new Error('MSG91 configuration is missing');
  }

  try {
    const response = await fetch('https://control.msg91.com/api/v5/widget/verifyAccessToken', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        authkey: authKey,
        'access-token': accessToken,
      }),
    });

    if (!response.ok) {
      throw new Error(`MSG91 verification failed with status: ${response.status}`);
    }

    const data = await response.json();
    
    // The typical MSG91 response on success contains { type: 'success', message: 'token verified', messageData: { mobile: '91xxxxxxxxxx' } }
    // Or { hasError: false, message: 'Verified' } depending on widget.
    // If it's an error, usually it might have type: 'error' or hasError: true
    if (data.type === 'error' || data.hasError) {
      throw new Error('Invalid or expired MSG91 access token');
    }

    let mobileNumber = data?.messageData?.mobile || data?.mobile;
    
    if (!mobileNumber) {
      throw new Error('Could not extract mobile number from MSG91 response');
    }

    mobileNumber = mobileNumber.toString();
    if (!mobileNumber.startsWith('+')) {
      mobileNumber = '+' + mobileNumber;
    }

    return {
      success: true,
      mobileNumber: mobileNumber,
      data: data,
    };
  } catch (error) {
    // Sanitize any potential secret leakage from Error object
    let safeErrorMessage = 'MSG91 verification failed';
    if (error.message.includes('status:')) {
      safeErrorMessage = error.message;
    } else if (error.message === 'Invalid or expired MSG91 access token') {
      safeErrorMessage = error.message;
    } else if (error.cause && error.cause.code) { // Network errors
      safeErrorMessage = `Network error during MSG91 verification`;
    }
    
    throw new Error(safeErrorMessage);
  }
};
