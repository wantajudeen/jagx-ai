# JagX AI

Native Android & iOS intelligence console built by **JagX & JRILICENSE**.

A capable, dark-first AI app with email OTP auth, real multi-model chat, image generation, and strong system identity. Frontend only ever shows **JagX models**.

## What it can do

- Deep reasoning and clear explanations
- Code writing & debugging (any language)
- Image generation
- Vision-capable model available
- Product, design, and technical help
- Natural multi-turn conversation

All while presenting only JagX-branded models to the user.

## Current Status

- [x] Full project scaffold + clean architecture
- [x] Dark JagX design system
- [x] Supabase email + 6-digit OTP → set password
- [x] Session-aware routing
- [x] Real chat with message history in session
- [x] Model selector (Core / Pro / Code / Vision / Image)
- [x] Silent upstream routing (OpenRouter etc. hidden)
- [x] Strong system prompt (identity locked to JagX AI)
- [x] Image generation
- [x] Suggested prompts on empty state
- [ ] Streaming responses
- [ ] Persistent chat history (Supabase)
- [ ] Google / Apple Sign-In (Coming Soon)

## Getting Started

```bash
git clone https://github.com/wantajudeen/jagx-ai.git
cd jagx-ai
cp .env.example .env
# Add your SUPABASE_ANON_KEY + OPENROUTER_API_KEY (and others)
flutter pub get
flutter run
```

## Models shown to users

| Name         | Purpose                        |
|--------------|--------------------------------|
| JagX Core    | Fast general intelligence      |
| JagX Pro     | Deep reasoning                 |
| JagX Code    | Code & technical work          |
| JagX Vision  | Images & documents            |
| JagX Image   | Image generation               |

## Brand

Dark-first • Teal accents • Clean typography  
*Build quietly. Let the work be the noise.*
