# V Astra Create - API Documentation

Complete API reference for the V Astra Create backend.

## Base URL

```
https://api.vastracreate.app/api
```

## Authentication

All endpoints (except `/published/:shareId` and `/health`) require Firebase ID token:

```
Authorization: Bearer <firebase-id-token>
```

---

## User Endpoints

### Initialize User

**POST** `/user/init`

Initialize or restore user on backend.

**Request:**
```json
{}
```

**Response:**
```json
{
  "uid": "user-123",
  "tier": "free",
  "remainingCredits": 5,
  "maxPrompts": 5,
  "totalPrompts": 0,
  "createdAt": "2026-06-07T10:00:00Z"
}
```

**Status Codes:**
- `200` - User initialized
- `401` - Unauthorized
- `500` - Server error

---

### Get User Profile

**GET** `/user/profile`

Fetch current user's profile and subscription status.

**Response:**
```json
{
  "uid": "user-123",
  "tier": "plus",
  "remainingCredits": 4,
  "maxPrompts": 25,
  "totalPrompts": 1,
  "monthlyResetDate": "2026-07-07",
  "isActive": true,
  "createdAt": "2026-06-07T10:00:00Z",
  "updatedAt": "2026-06-07T15:30:00Z"
}
```

---

### Get User Apps

**GET** `/user/apps`

Fetch all apps created by the user.

**Query Parameters:**
- `limit` (optional) - Number of apps to return (default: 20)
- `offset` (optional) - Pagination offset (default: 0)

**Response:**
```json
{
  "apps": [
    {
      "appId": "app-123",
      "name": "My Todo App",
      "prompt": "Create a todo list app",
      "tier": "free",
      "provider": "huggingface",
      "status": "completed",
      "code": "...",
      "createdAt": "2026-06-07T10:00:00Z",
      "updatedAt": "2026-06-07T10:05:00Z",
      "isPublished": false,
      "viewCount": 0
    }
  ],
  "total": 1,
  "limit": 20,
  "offset": 0
}
```

---

## App Generation Endpoints

### Generate App

**POST** `/generate`

Generate a new app using AI (tier-based routing).

**Request:**
```json
{
  "prompt": "Create a weather app that shows current temperature and forecast",
  "appName": "Weather App"
}
```

**Response:**
```json
{
  "appId": "app-456",
  "name": "Weather App",
  "prompt": "Create a weather app...",
  "tier": "free",
  "provider": "huggingface",
  "code": "import React...",
  "creditsDeducted": 1,
  "remainingCredits": 1,
  "status": "completed",
  "createdAt": "2026-06-07T10:10:00Z"
}
```

**Status Codes:**
- `200` - App generated
- `400` - Invalid request
- `402` - Insufficient credits
- `401` - Unauthorized
- `500` - Generation failed

**Error Response:**
```json
{
  "error": "Insufficient credits",
  "code": "INSUFFICIENT_CREDITS",
  "remainingCredits": 0
}
```

---

### Edit App

**PUT** `/app/:appId/edit`

Edit an existing app with new prompt.

**Request:**
```json
{
  "editPrompt": "Add dark mode support"
}
```

**Response:**
```json
{
  "appId": "app-456",
  "name": "Weather App",
  "code": "import React...",
  "creditsDeducted": 1,
  "remainingCredits": 0,
  "status": "completed",
  "updatedAt": "2026-06-07T10:15:00Z"
}
```

---

### Get App Details

**GET** `/app/:appId`

Fetch details of a specific app.

**Response:**
```json
{
  "appId": "app-456",
  "name": "Weather App",
  "prompt": "Create a weather app...",
  "editHistory": [
    {
      "editPrompt": "Add dark mode",
      "timestamp": "2026-06-07T10:15:00Z"
    }
  ],
  "code": "import React...",
  "tier": "free",
  "provider": "huggingface",
  "status": "completed",
  "isPublished": false,
  "shareId": null,
  "viewCount": 0,
  "createdAt": "2026-06-07T10:10:00Z",
  "updatedAt": "2026-06-07T10:15:00Z"
}
```

---

## Publishing Endpoints

### Publish App

**POST** `/app/:appId/publish`

Publish app to shareable link.

**Request:**
```json
{}
```

**Response:**
```json
{
  "appId": "app-456",
  "shareId": "share-abc123",
  "publishedUrl": "https://vastracreate.app/app/share-abc123",
  "isPublished": true,
  "publishedAt": "2026-06-07T10:20:00Z"
}
```

---

### Get Published App

**GET** `/published/:shareId`

Fetch a published app (public endpoint, no auth required).

**Response:**
```json
{
  "appId": "app-456",
  "name": "Weather App",
  "code": "import React...",
  "viewCount": 42,
  "createdAt": "2026-06-07T10:10:00Z",
  "publishedAt": "2026-06-07T10:20:00Z"
}
```

---

## Billing Endpoints

### Verify Purchase

**POST** `/billing/verify-purchase`

Verify Google Play purchase and update user tier.

**Request:**
```json
{
  "productId": "v_astra_plus_monthly",
  "purchaseToken": "purchase-token-from-google-play",
  "packageName": "com.vastra.create"
}
```

**Response:**
```json
{
  "isValid": true,
  "tier": "plus",
  "remainingCredits": 25,
  "maxPrompts": 25,
  "subscriptionExpiry": "2026-07-07T10:00:00Z",
  "message": "Subscription activated"
}
```

**Status Codes:**
- `200` - Purchase verified
- `400` - Invalid purchase
- `401` - Unauthorized
- `500` - Verification failed

---

### Get Subscription Status

**GET** `/billing/subscription-status`

Get current subscription status.

**Response:**
```json
{
  "tier": "plus",
  "isActive": true,
  "subscriptionExpiry": "2026-07-07T10:00:00Z",
  "remainingCredits": 4,
  "maxPrompts": 25,
  "monthlyResetDate": "2026-07-07",
  "autoRenew": true
}
```

---

### Restore Purchases

**POST** `/billing/restore-purchases`

Restore previous purchases from Google Play.

**Request:**
```json
{}
```

**Response:**
```json
{
  "restoredPurchases": 1,
  "tier": "pro",
  "remainingCredits": 60,
  "maxPrompts": 60,
  "message": "Purchases restored successfully"
}
```

---

## Analytics Endpoints

### Track App View

**POST** `/analytics/view`

Track view of published app (public endpoint).

**Request:**
```json
{
  "shareId": "share-abc123"
}
```

**Response:**
```json
{
  "success": true,
  "viewCount": 43
}
```

---

### Get App Analytics

**GET** `/analytics/:appId`

Get analytics for user's app.

**Response:**
```json
{
  "appId": "app-456",
  "viewCount": 42,
  "shareCount": 5,
  "downloadCount": 3,
  "lastViewedAt": "2026-06-07T15:30:00Z",
  "views": [
    {
      "timestamp": "2026-06-07T15:30:00Z",
      "source": "direct"
    }
  ]
}
```

---

## Health Check

### Health Check

**GET** `/health`

Check backend health (no auth required).

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2026-06-07T15:30:00Z",
  "version": "1.0.0"
}
```

---

## Error Handling

### Error Response Format

```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {
    "field": "Additional info"
  }
}
```

### Common Error Codes

| Code | Status | Description |
|------|--------|-------------|
| `UNAUTHORIZED` | 401 | Missing or invalid token |
| `INSUFFICIENT_CREDITS` | 402 | User has no credits |
| `INVALID_REQUEST` | 400 | Invalid request format |
| `NOT_FOUND` | 404 | Resource not found |
| `GENERATION_FAILED` | 500 | AI generation failed |
| `PURCHASE_INVALID` | 400 | Purchase verification failed |
| `SERVER_ERROR` | 500 | Internal server error |

---

## Rate Limiting

- **Requests per minute**: 60
- **Requests per hour**: 1000
- **Generation requests per day**: Limited by credits

**Rate limit headers:**
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 59
X-RateLimit-Reset: 1623065400
```

---

## Tier Limits

| Feature | Free | Plus | Pro | Ultra |
|---------|------|------|-----|-------|
| Monthly Credits | 5 | 25 | 60 | 100 |
| Max Prompts | 5 | 25 | 60 | 100 |
| Max Apps | 2 | 5 | 15 | 20 |
| Ads | Yes | No | No | No |
| API Access | No | No | Yes | Yes |
| Support | Community | Email | Priority | Dedicated |

---

## AI Provider Routing

- **Free Tier**: Hugging Face (Mistral-7B)
- **Plus Tier**: Gemini 2.5 Flash
- **Pro Tier**: Gemini 2.5 Flash
- **Ultra Tier**: Gemini 2.5 Flash

---

## Webhook Events

### Purchase Completed

```json
{
  "event": "purchase.completed",
  "timestamp": "2026-06-07T10:00:00Z",
  "data": {
    "uid": "user-123",
    "productId": "v_astra_plus_monthly",
    "tier": "plus",
    "subscriptionExpiry": "2026-07-07T10:00:00Z"
  }
}
```

### Subscription Expired

```json
{
  "event": "subscription.expired",
  "timestamp": "2026-06-07T10:00:00Z",
  "data": {
    "uid": "user-123",
    "previousTier": "plus",
    "newTier": "free"
  }
}
```

---

## Code Examples

### cURL

```bash
# Generate app
curl -X POST https://api.vastracreate.app/api/generate \
  -H "Authorization: Bearer $FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Create a todo app",
    "appName": "My Todo"
  }'
```

### JavaScript/Fetch

```javascript
const response = await fetch('https://api.vastracreate.app/api/generate', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${firebaseToken}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    prompt: 'Create a todo app',
    appName: 'My Todo',
  }),
});

const data = await response.json();
```

### Python

```python
import requests

headers = {
    'Authorization': f'Bearer {firebase_token}',
    'Content-Type': 'application/json',
}

response = requests.post(
    'https://api.vastracreate.app/api/generate',
    headers=headers,
    json={
        'prompt': 'Create a todo app',
        'appName': 'My Todo',
    },
)

data = response.json()
```

---

## Changelog

### v1.0.0 (2026-06-07)

- Initial API release
- User management endpoints
- App generation with AI routing
- Google Play billing integration
- Analytics tracking
- Publishing system
