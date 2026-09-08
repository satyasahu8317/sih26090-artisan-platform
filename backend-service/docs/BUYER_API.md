# Buyer API Documentation

**Base URL:** `https://sih26090-artisan-platform.onrender.com`

> [!NOTE]
> All authenticated routes require a JWT token passed in the `Authorization` header as `Bearer <token>`.
> Most of these routes require the user's role to be `BUYER`.

---

## Authentication APIs

### 1. Request OTP
**Endpoint:** `POST /api/auth/mobile`
**Auth Required:** No
**Request Body:**
```json
{
  "mobileNumber": "+919876543210",
  "role": "BUYER"
}
```
**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "OTP sent successfully (mocked for dev)",
  "mockOtp": "123456" 
}
```

### 2. Verify OTP (Mock/Dev)
**Endpoint:** `POST /api/auth/verify-otp`
**Auth Required:** No
**Request Body:**
```json
{
  "mobileNumber": "+919876543210",
  "otp": "123456",
  "role": "BUYER"
}
```
**Success Response (200 OK):**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1...",
  "user": {
    "id": "uuid",
    "mobileNumber": "+919876543210",
    "role": "BUYER",
    "status": "ACTIVE"
  }
}
```
*Note: Use `POST /api/auth/msg91/verify` for production MSG91 verification with the same payload.*

### 3. Get Current User Profile
**Endpoint:** `GET /api/auth/me`
**Auth Required:** Yes (`BUYER` or `ARTISAN`)
**Success Response (200 OK):**
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "mobileNumber": "+919876543210",
    "role": "BUYER",
    "status": "ACTIVE",
    "buyerProfile": {
      "id": "uuid",
      "name": "John Doe",
      "businessName": "Doe Retail",
      "businessType": "Retailer",
      "state": "Maharashtra",
      "district": "Mumbai"
    }
  }
}
```

---

## Buyer Profile APIs

### 4. Update Buyer Profile
**Endpoint:** `PATCH /api/v1/buyers/me`
**Auth Required:** Yes (`BUYER` only)
**Request Body:** (All fields are optional, send only what you want to update)
```json
{
  "name": "Updated Name",
  "businessName": "Updated Business",
  "businessType": "Wholesaler",
  "state": "Karnataka",
  "district": "Bengaluru"
}
```
**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Updated Name",
    "businessName": "Updated Business",
    "businessType": "Wholesaler",
    "state": "Karnataka",
    "district": "Bengaluru"
  }
}
```
**Common Errors:**
- `400 Bad Request`: Invalid fields provided.
- `403 Forbidden`: User is not a buyer.

---

## Product Discovery APIs

### 5. List Public Products
**Endpoint:** `GET /api/v1/products`
**Auth Required:** Yes (`BUYER` or `ARTISAN`)
**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Results per page (default: 20)
- `q` (optional): Search query (matches productName, description, category, material, tags)
- `category` (optional): Filter by category (case-insensitive exact match)

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "productName": { "en": "Bowl", "hi": "कटोरा" },
      "category": "Pottery",
      "material": "Clay",
      "status": "PUBLISHED",
      "imageUrl": "https://...",
      "artisan": {
        "id": "uuid",
        "name": "Artisan Name",
        "craftType": "Pottery"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 50,
    "pages": 3
  }
}
```

### 6. Get Product Details
**Endpoint:** `GET /api/v1/products/:id`
**Auth Required:** Yes (`BUYER` or `ARTISAN`)
**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "productName": { "en": "Bowl", "hi": "कटोरा" },
    "description": { "en": "Nice bowl", "hi": "..." },
    "category": "Pottery",
    "material": "Clay",
    "status": "PUBLISHED",
    "tags": ["handmade"],
    "artisan": {
      "id": "uuid",
      "name": "Artisan Name",
      "craftType": "Pottery",
      "state": "Rajasthan",
      "district": "Jaipur"
    }
  }
}
```
**Common Errors:**
- `403 Forbidden`: Product is in DRAFT state and user is a BUYER.
- `404 Not Found`: Product doesn't exist.

### 7. Get Artisan Public Profile
**Endpoint:** `GET /api/v1/artisans/:id`
**Auth Required:** Yes (`BUYER` or `ARTISAN`)
**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Artisan Name",
    "craftType": "Pottery",
    "state": "Rajasthan",
    "district": "Jaipur",
    "preferredLanguage": "Hindi"
  }
}
```
*Note: Private fields like mobile number and user ID are explicitly excluded.*

---

## Enquiries / Chat APIs

### 8. Create Enquiry
**Endpoint:** `POST /api/v1/enquiries`
**Auth Required:** Yes (`BUYER` only)
**Request Body:**
```json
{
  "artisanId": "uuid",
  "productId": "uuid",
  "message": "I want to order 50 bowls."
}
```
**Success Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "NEW",
    "message": "I want to order 50 bowls."
  }
}
```

### 9. List My Enquiries
**Endpoint:** `GET /api/v1/enquiries/my`
**Auth Required:** Yes (`BUYER` only)
**Success Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "status": "NEW",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "artisan": {
        "id": "uuid",
        "name": "Artisan Name"
      },
      "product": {
        "id": "uuid",
        "productName": { "en": "Bowl", "hi": "कटोरा" },
        "imageUrl": "https://..."
      }
    }
  ]
}
```

### 10. Get Enquiry Details
**Endpoint:** `GET /api/v1/enquiries/:id`
**Auth Required:** Yes (must be the buyer who created it)
**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "message": "I want to order 50 bowls.",
    "status": "NEW",
    "artisan": { "id": "uuid", "name": "Artisan Name" },
    "product": { "id": "uuid", "productName": { "en": "Bowl", "hi": "कटोरा" } }
  }
}
```

### 11. List Enquiry Messages (Chat History)
**Endpoint:** `GET /api/v1/enquiries/:id/messages`
**Auth Required:** Yes (must be the buyer who created the enquiry)
**Success Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "senderId": "uuid",
      "message": "I want to order 50 bowls.",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "senderRole": "BUYER"
    }
  ]
}
```

### 12. Send Enquiry Message
**Endpoint:** `POST /api/v1/enquiries/:id/messages`
**Auth Required:** Yes (must be the buyer who created the enquiry)
**Request Body:**
```json
{
  "message": "Can you do a discount?"
}
```
**Success Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "message": "Can you do a discount?",
    "senderId": "uuid",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

---

## Orders APIs

### 13. Create Order
**Endpoint:** `POST /api/v1/orders`
**Auth Required:** Yes (`BUYER` only)
**Request Body:**
```json
{
  "artisanId": "uuid",
  "productId": "uuid",
  "requestedQty": 50,
  "unitPrice": 100
}
```
**Success Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "PENDING",
    "requestedQty": 50,
    "unitPrice": 100,
    "totalAmount": 5000
  }
}
```

### 14. List My Orders
**Endpoint:** `GET /api/v1/orders/my`
**Auth Required:** Yes (`BUYER` only)
**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Results per page (default: 20)

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "status": "PENDING",
      "requestedQty": 50,
      "totalAmount": 5000,
      "createdAt": "2024-01-01T00:00:00.000Z",
      "artisan": {
        "id": "uuid",
        "name": "Artisan Name"
      },
      "product": {
        "id": "uuid",
        "productName": { "en": "Bowl", "hi": "कटोरा" },
        "imageUrl": "https://..."
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "pages": 1
  }
}
```

### 15. Get Order Details
**Endpoint:** `GET /api/v1/orders/:id`
**Auth Required:** Yes (must be the buyer who created it)
**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "PENDING",
    "requestedQty": 50,
    "acceptedQty": null,
    "unitPrice": 100,
    "totalAmount": 5000,
    "artisan": { "id": "uuid", "name": "Artisan Name" },
    "product": { "id": "uuid", "productName": { "en": "Bowl", "hi": "कटोरा" } }
  }
}
```

---

## Notifications APIs

### 16. List My Notifications
**Endpoint:** `GET /api/v1/notifications`
**Auth Required:** Yes (`BUYER` or `ARTISAN`)
**Success Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "Order Accepted",
      "message": "Your order has been accepted.",
      "type": "ORDER",
      "isRead": false,
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

### 17. Mark Notification as Read
**Endpoint:** `PATCH /api/v1/notifications/:id/read`
**Auth Required:** Yes
**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "isRead": true
  }
}
```

### 18. Mark All Notifications as Read
**Endpoint:** `PATCH /api/v1/notifications/read-all`
**Auth Required:** Yes
**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "All notifications marked as read"
}
```

---

## Payment APIs (Razorpay Test Mode)

### 19. Initiate Payment
**Endpoint:** `POST /api/v1/orders/:id/payment`
**Auth Required:** Yes (must be the buyer who created the order)
**Description:** Creates a Razorpay order for an existing application order.
**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "orderId": "application-order-uuid",
    "razorpayOrderId": "order_xxx",
    "amount": 50000,
    "currency": "INR",
    "keyId": "rzp_test_xxx"
  }
}
```

### 20. Verify Payment
**Endpoint:** `POST /api/v1/orders/:id/payment/verify`
**Auth Required:** Yes (must be the buyer who created the order)
**Description:** Verifies the Razorpay payment signature after a successful checkout.
**Request Body:**
```json
{
  "razorpay_payment_id": "pay_xxx",
  "razorpay_order_id": "order_xxx",
  "razorpay_signature": "signature_xxx"
}
```
**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Payment verified successfully",
  "data": {
    "paymentStatus": "SUCCESS",
    "paidAt": "2024-01-01T00:00:00.000Z"
  }
}
```
