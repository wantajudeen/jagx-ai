# JagX AI

Native Android & iOS intelligence console built by **JagX & JRILICENSE**.

Fast, dark-first experience with email OTP auth, chat, and image generation. Frontend only shows **JagX models**.

## Current Status

- [x] Project scaffold
- [x] Dark JagX design system (teal accents)
- [x] Supabase Auth (email + 6-digit OTP → set password)
- [x] Splash + Auth flow + Chat home shell
- [ ] Chat messaging + streaming
- [ ] Image generation
- [ ] Model router (JagX models only in UI)
- [ ] Google / Apple Sign-In (Coming Soon)

## Stack

- Flutter
- Supabase Auth
- Riverpod
- go_router
- Feature-first architecture

## Getting Started

```bash
git clone https://github.com/wantajudeen/jagx-ai.git
cd jagx-ai
cp .env.example .env
# Fill SUPABASE_ANON_KEY and other keys
flutter pub get
flutter run
```

## Auth Flow

1. Enter email
2. Receive 6-digit code
3. Verify code
4. Set password
5. Land in chat

Google & Apple Sign-In are marked Coming Soon.

## Brand

Dark-first • Teal accents • Clean typography  
*Build quietly. Let the work be the noise.*
