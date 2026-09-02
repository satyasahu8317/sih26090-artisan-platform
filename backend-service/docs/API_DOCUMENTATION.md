# Artisan Platform - API Documentation

## Base URL
`http://localhost:3000/api` (Local Development)

---

## Authentication API

All authentication in this platform is passwordless and relies on Mobile Number & OTP.

### 1. Request OTP
Initiates the login or registration process by sending an OTP to the user's mobile number.

- **Endpoint:** `POST /auth/mobile`
- **Rate Limit:** 5 requests per 10 minutes per IP.
- **Request Body:**
  ```json
  {
    "mobileNumber": "string (10 digits)",
    "role": "string (Enum: 'ARTISAN' or 'BUYER')"
  }
  ```
- **Responses:**
  - `200 OK`: `{"message": "OTP sent successfully"}`
  - `400 Bad Request`: If `mobileNumber` or `role` are missing.

---

### 2. Verify OTP
Verifies the OTP and returns an authentication token. If the user hasn't completed their profile, it flags them as a new user.

- **Endpoint:** `POST /auth/verify-otp`
- **Request Body:**
  ```json
  {
    "mobileNumber": "string (10 digits)",
    "role": "string (Enum: 'ARTISAN' or 'BUYER')",
    "otp": "string (6 digits)"
  }
  ```
- **Responses:**
  - `200 OK`: 
    ```json
    {
      "token": "jwt_token_string",
      "isNewUser": boolean,
      "redirect": "string (e.g., '/artisan/register' or '/artisan/home')"
    }
    ```
  - `400 Bad Request`: Invalid or expired OTP.
  - `404 Not Found`: User not found.

---

### 3. Complete Registration
Finalizes the registration for new users (whose status is `PENDING`). This endpoint requires the JWT token obtained from the Verify OTP step.

- **Endpoint:** `POST /auth/register/:role` 
  *(Replace `:role` with `artisan` or `buyer`)*
- **Headers:** 
  - `Authorization: Bearer <token>`
- **Request Body (If role is `artisan`):**
  ```json
  {
    "name": "string",
    "craftType": "string",
    "state": "string",
    "district": "string",
    "preferredLanguage": "string"
  }
  ```
- **Request Body (If role is `buyer`):**
  ```json
  {
    "name": "string",
    "businessName": "string",
    "businessType": "string",
    "state": "string",
    "district": "string"
  }
  ```
- **Responses:**
  - `200 OK`:
    ```json
    {
      "token": "new_jwt_token_string",
      "redirect": "string (e.g., '/artisan/home')"
    }
    ```
  - `400 Bad Request`: Role mismatch, Invalid role, or User is already registered (`ACTIVE`).
  - `401 Unauthorized`: Missing or invalid token.

---

### 4. Get Current User Profile
Retrieves the logged-in user's details and profile information.

- **Endpoint:** `GET /auth/me`
- **Headers:** 
  - `Authorization: Bearer <token>`
- **Responses:**
  - `200 OK`:
    ```json
    {
      "user": {
        "id": "uuid",
        "mobileNumber": "string",
        "role": "ARTISAN",
        "status": "ACTIVE",
        "createdAt": "date",
        "updatedAt": "date",
        "artisanProfile": { ...profileData },
        "buyerProfile": null
      },
      "redirect": "string (e.g., '/artisan/home')"
    }
    ```
  - `401 Unauthorized`: Missing or invalid token.
