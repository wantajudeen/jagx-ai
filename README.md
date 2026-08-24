# JagX AI

Native Android & iOS intelligence console built by **JagX & JRILICENSE**.

Fast, dark-first experience with email OTP auth, real chat, model selector, and image generation. Frontend only shows **JagX models**.

## Current Status

- [x] Project scaffold + architecture
- [x] Dark JagX design system (teal accents)
- [x] Supabase Auth (email + 6-digit OTP → set password)
- [x] Splash + full auth flow
- [x] Chat UI with message bubbles
- [x] JagX model selector (Core, Pro, Code, Vision, Image)
- [x] Silent model routing (OpenRouter / others hidden from user)
- [x] Image generation support
- [ ] Streaming responses
- [ ] Conversation history persistence
- [ ] Google / Apple Sign-In (Coming Soon)

## Stack

- Flutter + Riverpod + go_router
- Supabase Auth
- Feature-first architecture

## Getting Started

```bash
git clone https://github.com/wantajudeen/jagx-ai.git
cd jagx-ai
cp .env.example .env
# Fill SUPABASE_ANON_KEY + API keys
flutter pub get
flutter run
```

## Auth Flow

1. Enter email
2. Receive 6-digit code
3. Verify code
4. Set password
5. Land in chat

## Models (shown to users)

- JagX Core
- JagX Pro
- JagX Code
- JagX Vision
- JagX Image

Internal routing is completely hidden.

## Brand

Dark-first • Teal accents • Clean typography  
*Build quietly. Let the work be the noise.*
