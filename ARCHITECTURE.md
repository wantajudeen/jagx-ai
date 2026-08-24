# Architecture

## Overview

Feature-first structure with clear separation of concerns.

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/          # Env, constants
│   ├── theme/           # Colors, ThemeData
│   ├── router/          # go_router
│   └── utils/
└── features/
    ├── auth/
    │   └── presentation/
    │       └── screens/
    ├── chat/
    │   └── presentation/
    │       └── screens/
    └── splash/
        └── presentation/
```

## Auth

- Supabase email OTP (6-digit)
- After successful OTP → set password
- Session-based redirect via go_router

## AI Layer (next)

- Frontend only exposes "JagX models"
- Backend routes to OpenRouter / Nvidia / JagX API silently
- Image generation supported

## Design System

- Background: #0A0A0B
- Primary (teal): #00D4AA
- Accent (orange): #F59E0B
- Inter font via google_fonts
