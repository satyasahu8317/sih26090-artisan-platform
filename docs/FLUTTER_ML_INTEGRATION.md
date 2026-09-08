# SIH26090 — Flutter ML Catalogue Integration Guide

## Purpose

This guide is for the Flutter developer integrating the Artisan Add Product → AI Catalogue flow.

Architecture:
```
Flutter
  ↓ REST
Node.js Backend
  ├── Firebase Storage
  ├── Python ML Service
  └── Neon PostgreSQL
```

Flutter must NEVER directly call:
- Python/FastAPI ML service
- Groq
- Gemini
- PostgreSQL/Neon
- Firebase Admin SDK

Firebase Storage is ONLY for media assets.
Neon PostgreSQL is the source of truth for catalogue/business data.

---

## Node API Endpoints

Documented below are the exact endpoints for this flow:

- `POST /api/v1/ai/media/image`
- `POST /api/v1/ai/media/audio`
- `POST /api/v1/ai/catalogue/ml-generate`

**Important:** All endpoints require:
`Authorization: Bearer <JWT_TOKEN>`

*Only `ARTISAN` users can use them.*

---

## Image Upload

`POST /api/v1/ai/media/image`

**Content-Type:** `multipart/form-data`
**Field:** `file`
**Allowed Formats:** `image/jpeg`, `image/png`, `image/webp`
**Maximum Size:** 10 MB

### Example Response
```json
{
  "success": true,
  "data": {
    "url": "https://storage.googleapis.com/...",
    "path": "catalogue/<artisanId>/<uuid>/original-image.jpg",
    "contentType": "image/jpeg"
  }
}
```

*Tell Flutter to save `data.url`.*

### Flutter Dart Example
```dart
import 'package:http/http.dart' as http;
import 'dart:io';

Future<String> uploadImage(File image, String jwt) async {
  var request = http.MultipartRequest('POST', Uri.parse('YOUR_API/api/v1/ai/media/image'));
  request.headers['Authorization'] = 'Bearer $jwt';
  request.files.add(await http.MultipartFile.fromPath('file', image.path));
  
  var response = await request.send();
  // ... parse response and extract data.url
}
```

---

## Audio Upload

`POST /api/v1/ai/media/audio`

**Content-Type:** `multipart/form-data`
**Field:** `file`
**Supported Formats:** `m4a`, `mp3`, `wav`, `webm`, `ogg`, `mp4`, `mpeg`
**Maximum Size:** 25 MB

### Example Response
```json
{
  "success": true,
  "data": {
    "url": "https://storage.googleapis.com/...",
    "path": "catalogue/<artisanId>/<uuid>/audio.m4a",
    "contentType": "audio/m4a"
  }
}
```

*Tell Flutter to save `data.url`.*

### Flutter Dart Example
```dart
import 'package:http/http.dart' as http;
import 'dart:io';

Future<String> uploadAudio(File audio, String jwt) async {
  var request = http.MultipartRequest('POST', Uri.parse('YOUR_API/api/v1/ai/media/audio'));
  request.headers['Authorization'] = 'Bearer $jwt';
  request.files.add(await http.MultipartFile.fromPath('file', audio.path));
  
  var response = await request.send();
  // ... parse response and extract data.url
}
```

---

## Catalogue Generation

`POST /api/v1/ai/catalogue/ml-generate`

**Content-Type:** `application/json`

### Example Request
```json
{
  "productName": {
    "en": "Blue Pottery Vase",
    "hi": "नीली मिट्टी का फूलदान"
  },
  "imageUrl": "https://storage.googleapis.com/...",
  "audioUrl": "https://storage.googleapis.com/...",
  "category": "Pottery",
  "material": "Clay",
  "region": "Rajasthan",
  "materialCost": 150,
  "hintLanguage": "hi",
  "keywords": [
    "handmade",
    "traditional",
    "blue pottery"
  ]
}
```

**Required Fields:** `productName`, `category`
**Media Required:** At least one of `imageUrl` OR `audioUrl` must be provided. If neither exists, the backend returns a `400` error.

### Pipeline Cases
1. **Image + Audio:** Image enhancement and transcription run in parallel, followed by translation → description → pricing → Product.
2. **Image only:** Enhancement → pricing → Product.
3. **Audio only:** Transcription → translation → description → pricing → Product.

---

## Catalogue Response

A successful generation returns **`201 Created`**. The created product is set to `DRAFT` status.

*Flutter should show a Review/Edit screen and must not automatically publish the product.*

### Example Response Data
```json
{
  "success": true,
  "data": {
    "id": "e6bd8b62-1234-4567-89ab-cdef01234567",
    "artisanId": "abc-123",
    "productName": {
      "en": "Blue Pottery Vase",
      "hi": "नीली मिट्टी का फूलदान"
    },
    "category": "Pottery",
    "material": "Clay",
    "description": {
      "en": "A beautifully handcrafted traditional blue pottery vase.",
      "hi": "एक खूबसूरती से हस्तनिर्मित पारंपरिक नीली मिट्टी का फूलदान।"
    },
    "tags": ["handmade", "traditional", "blue pottery", "vase"],
    "imageUrl": "https://storage.googleapis.com/enhanced-image-url",
    "status": "DRAFT",
    "suggestedPriceMin": 300,
    "suggestedPriceMax": 450,
    "currency": "INR",
    "pricingExplanation": "Pricing includes material costs and premium handcrafted markups.",
    "pricing": {
      "suggestedPriceMin": 300,
      "suggestedPriceMax": 450,
      "currency": "INR",
      "explanation": "Pricing includes material costs and premium handcrafted markups."
    }
  }
}
```
*(Response will also include `transcription` if audio was provided).*

---

## Loading UX

Because ML generation can take time, Flutter does NOT poll the ML service. Node handles ML polling internally. Show progress states such as:

- Uploading image...
- Uploading voice...
- Preparing your catalogue...
- Enhancing product image...
- Understanding your voice...
- Translating description...
- Creating product description...
- Estimating price...
- Preparing your catalogue...

---

## Error Handling

Tell Flutter to show user-friendly messages and never expose backend stack traces. Handle the following HTTP status codes gracefully:

- `400` → invalid request (e.g. unsupported file, missing fields)
- `401` → invalid/expired/missing JWT
- `403` → user is not an artisan
- `404` → artisan profile not found
- `502` → Firebase/ML/backend dependency failure
- `504` → ML timeout

---

## Flutter Service Layer

We recommend isolating this logic in the Flutter repository inside a dedicated service layer:
```
lib/
  services/
    api_service.dart
    ai_catalogue_service.dart
```

### Conceptual API Example

```dart
class AiCatalogueService {
  Future<String> uploadImage(File image);
  Future<String> uploadAudio(File audio);

  Future<Map<String, dynamic>> generateCatalogue({
    required Map<String, String> productName,
    String? imageUrl,
    String? audioUrl,
    required String category,
    String? material,
    String? region,
    double? materialCost,
    String? hintLanguage,
    List<String>? keywords,
  });
}
```
**Flow execution order:**
1. Attaches JWT
2. Uploads image to Node
3. Extracts `data.url`
4. Uploads audio to Node
5. Extracts `data.url`
6. Calls `/catalogue/ml-generate` with the retrieved URLs
7. Returns the catalogue to the UI

---

## Recommended UI State

Allow skipping either media upload depending on artisan capabilities.

```
initial
→ uploadingImage
→ imageUploaded
→ uploadingAudio
→ audioUploaded
→ generatingCatalogue
→ catalogueGenerated
→ review/edit
→ publish
```

---

## Security

Flutter must NEVER contain or receive the following secrets:
- `GROQ_API_KEY`
- `GEMINI_API_KEY`
- `FIREBASE_SERVICE_ACCOUNT_BASE64`
- `DATABASE_URL`
- `ML internal API key`
- `Firebase Admin private key`

*These remain completely server-side.*

---

## DO / DON'T

**DO:**
- send JWT
- upload media to Node
- save returned `data.url`
- send Firebase URLs to catalogue endpoint
- show loading state
- show review/edit screen
- keep product `DRAFT` until publish

**DO NOT:**
- call Python ML directly
- call Groq directly
- call Gemini directly
- connect to PostgreSQL directly
- use Firebase Admin credentials in Flutter
- implement ML polling in Flutter
- recreate ML orchestration in Flutter

---

## Final Checklist

### Authentication
- [ ] JWT is securely attached as Bearer token to all AI/media requests.

### Image
- [ ] Uses memory/multipart for upload endpoint.
- [ ] Correctly parses returning Firebase Storage `url`.

### Audio
- [ ] Uses memory/multipart for upload endpoint.
- [ ] Correctly parses returning Firebase Storage `url`.

### Catalogue
- [ ] Constructs proper JSON body incorporating the resolved Firebase URLs.
- [ ] Product correctly defaults to `DRAFT`.
- [ ] UI prompts the artisan to review the details and edit before publishing.

### Architecture
- [ ] Flutter → Node only
- [ ] Node → Firebase Storage
- [ ] Node → ML
- [ ] Node → Neon
- [ ] No secrets in Flutter
- [ ] No direct Flutter → ML

---

## Backend Reference

- **Branch:** `feat/yash-ml-integration`
- **Current backend commit:** `40ee062 feat: integrate firebase storage for ml catalogue flow`
