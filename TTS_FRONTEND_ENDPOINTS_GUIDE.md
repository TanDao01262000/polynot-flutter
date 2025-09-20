# TTS Frontend Endpoints Guide

## Base URL
```
http://localhost:8001
```

## Authentication
All TTS endpoints require authentication. Include the Bearer token in the Authorization header:
```javascript
headers: {
  "Authorization": "Bearer YOUR_JWT_TOKEN",
  "Content-Type": "application/json"
}
```

---

## 🎤 TTS Core Endpoints

### 1. Generate TTS Audio
**POST** `/tts/generate`
- **Purpose**: Generate TTS audio for custom text
- **Request Body**:
```json
{
  "text": "Hello world",
  "voice_id": "optional_voice_id",
  "language": "en-US",
  "speed": 1.0,
  "provider": "google" // or "elevenlabs"
}
```
- **Response**:
```json
{
  "success": true,
  "audio_url": "https://storage.url/audio.mp3",
  "duration_seconds": 2.5,
  "text_length": 11,
  "provider": "google"
}
```

### 2. Generate TTS for Vocabulary Entry
**POST** `/tts/generate-vocab/{vocab_entry_id}`
- **Purpose**: Generate TTS audio for a specific vocabulary entry
- **Path Parameters**: `vocab_entry_id` (string)
- **Query Parameters**:
  - `voice_id` (optional): Custom voice ID
  - `language` (default: "en-US"): Language code
- **Response**: Same as above

---

## 🗣️ Pronunciation Management Endpoints

### 3. Generate Pronunciations
**POST** `/tts/pronunciation/generate`
- **Purpose**: Generate multiple pronunciation versions for a vocabulary entry
- **Request Body**:
```json
{
  "vocab_entry_id": "uuid-string",
  "text": "word to pronounce",
  "language": "en",
  "versions": ["normal", "slow"] // or ["fast", "normal", "slow"]
}
```
- **Response**:
```json
{
  "success": true,
  "message": "Generated 2 pronunciation versions",
  "generated_versions": ["normal", "slow"],
  "vocab_entry_id": "uuid-string"
}
```

### 4. Get Pronunciations
**GET** `/tts/pronunciation/{vocab_entry_id}`
- **Purpose**: Retrieve existing pronunciations for a vocabulary entry
- **Path Parameters**: `vocab_entry_id` (string)
- **Response**:
```json
{
  "vocab_entry_id": "uuid-string",
  "word": "example",
  "versions": {
    "normal": {
      "audio_url": "https://storage.url/normal.mp3",
      "duration_seconds": 1.2,
      "provider": "google",
      "voice_id": "en-US-Standard-A"
    },
    "slow": {
      "audio_url": "https://storage.url/slow.mp3",
      "duration_seconds": 1.8,
      "provider": "google",
      "voice_id": "en-US-Standard-A"
    }
  }
}
```

### 5. Ensure Pronunciations Exist
**POST** `/tts/pronunciation/ensure/{vocab_entry_id}`
- **Purpose**: Ensure required pronunciation versions exist (generates if missing)
- **Path Parameters**: `vocab_entry_id` (string)
- **Query Parameters**:
  - `versions`: Array of pronunciation types (default: ["normal", "slow"])
- **Response**:
```json
{
  "success": true,
  "message": "Pronunciations ensured",
  "vocab_entry_id": "uuid-string",
  "required_versions": ["normal", "slow"]
}
```

### 6. Batch Generate Pronunciations
**POST** `/tts/pronunciation/batch`
- **Purpose**: Generate pronunciations for multiple vocabulary entries
- **Request Body**:
```json
{
  "vocab_entry_ids": ["uuid1", "uuid2", "uuid3"],
  "versions": ["normal", "slow"]
}
```
- **Response**:
```json
{
  "success": true,
  "message": "Batch pronunciation generation completed",
  "results": {
    "uuid1": {"success": true, "generated_versions": ["normal", "slow"]},
    "uuid2": {"success": true, "generated_versions": ["normal"]},
    "uuid3": {"success": false, "error": "Vocabulary entry not found"}
  }
}
```

### 7. Delete Pronunciations
**DELETE** `/tts/pronunciation/{vocab_entry_id}`
- **Purpose**: Delete all pronunciations for a vocabulary entry
- **Path Parameters**: `vocab_entry_id` (string)
- **Response**:
```json
{
  "success": true,
  "message": "Pronunciations deleted successfully",
  "vocab_entry_id": "uuid-string"
}
```

---

## 🎭 Voice Cloning Endpoints

### 8. Create Voice Clone
**POST** `/voice-cloning/create-voice-clone`
- **Purpose**: Create a custom voice clone from uploaded audio files
- **Request**: Multipart form data
  - `user_id`: User ID
  - `voice_name`: Name for the cloned voice
  - `audio_files`: Array of audio files (minimum 1)
  - `description`: Optional description
- **Response**:
```json
{
  "success": true,
  "voice_id": "cloned_voice_id",
  "voice_name": "My Custom Voice",
  "status": "processing",
  "message": "Voice clone creation started"
}
```

### 9. Get Voice Profiles
**GET** `/tts/voice-profiles`
- **Purpose**: Get all voice profiles for the current user
- **Response**:
```json
[
  {
    "id": "voice_profile_id",
    "user_id": "user_id",
    "voice_name": "My Custom Voice",
    "voice_id": "cloned_voice_id",
    "provider": "elevenlabs",
    "is_active": true,
    "created_at": "2024-01-01T00:00:00Z"
  }
]
```

### 10. Delete Voice Profile
**DELETE** `/tts/voice-profiles/{voice_profile_id}`
- **Purpose**: Delete a voice profile
- **Path Parameters**: `voice_profile_id` (string)
- **Response**:
```json
{
  "success": true,
  "message": "Voice profile deleted successfully"
}
```

---

## 📊 TTS Usage & Subscription Endpoints

### 11. Get User Subscription
**GET** `/tts/subscription`
- **Purpose**: Get user's subscription information
- **Response**:
```json
{
  "user_id": "user_id",
  "plan": "premium",
  "status": "active",
  "expires_at": "2024-12-31T23:59:59Z",
  "features": {
    "voice_cloning": true,
    "unlimited_tts": true,
    "custom_voices": 5
  }
}
```

### 12. Get TTS Quota
**GET** `/tts/quota`
- **Purpose**: Get user's TTS usage quota information
- **Response**:
```json
{
  "user_id": "user_id",
  "plan": "premium",
  "monthly_character_limit": 100000,
  "characters_used_this_month": 15000,
  "characters_remaining": 85000,
  "reset_date": "2024-02-01T00:00:00Z",
  "voice_clones_limit": 5,
  "voice_clones_used": 2,
  "voice_clones_remaining": 3
}
```

---

## 🔧 Important Notes for Frontend

### Path Changes Made:
1. **Pronunciation endpoints** are now under `/tts/pronunciation/` instead of separate paths
2. **Voice cloning** endpoints are under `/voice-cloning/` prefix
3. **All TTS endpoints** are consolidated under `/tts/` prefix

### Error Handling:
- **404**: Resource not found (vocabulary entry, voice profile, etc.)
- **400**: Bad request (invalid parameters, missing required fields)
- **401**: Unauthorized (invalid or missing token)
- **500**: Server error (TTS generation failed, database error, etc.)

### Best Practices:
1. **Always check if pronunciations exist** before generating new ones
2. **Use batch endpoints** for multiple vocabulary entries
3. **Cache audio URLs** to avoid unnecessary regeneration
4. **Handle async operations** for voice cloning (status polling)
5. **Implement retry logic** for failed TTS generations

### Frontend Integration Example:
```javascript
// Generate pronunciations for a vocabulary entry
async function generatePronunciations(vocabEntryId, word) {
  try {
    const response = await fetch('/tts/pronunciation/generate', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        vocab_entry_id: vocabEntryId,
        text: word,
        language: 'en',
        versions: ['normal', 'slow']
      })
    });
    
    const result = await response.json();
    return result;
  } catch (error) {
    console.error('Pronunciation generation failed:', error);
    throw error;
  }
}

// Get existing pronunciations
async function getPronunciations(vocabEntryId) {
  try {
    const response = await fetch(`/tts/pronunciation/${vocabEntryId}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    const pronunciations = await response.json();
    return pronunciations;
  } catch (error) {
    console.error('Failed to get pronunciations:', error);
    throw error;
  }
}
```

---

## 🚀 Quick Start Checklist

1. ✅ **Authentication**: Ensure Bearer token is included in all requests
2. ✅ **Generate Vocabulary**: Use `/generate/single` to create vocabulary entries
3. ✅ **Generate Pronunciations**: Use `/tts/pronunciation/generate` for audio
4. ✅ **Retrieve Audio**: Use `/tts/pronunciation/{vocab_entry_id}` to get audio URLs
5. ✅ **Handle Errors**: Implement proper error handling for all endpoints
6. ✅ **Cache Results**: Store audio URLs to avoid regeneration
7. ✅ **Monitor Quota**: Check `/tts/quota` for usage limits

All endpoints are production-ready and fully tested! 🎉


