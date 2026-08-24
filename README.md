# JagX AI

Native Android & iOS intelligence console built by **JagX & JRILICENSE**.

## Models

| Name       | Role |
|------------|------|
| **Pulse**  | Fast everyday intelligence |
| **Nova**   | Deep reasoning |
| **Forge**  | Code & systems |
| **Aether** | Vision |
| **Ember**  | Image generation |
| **Oracle** | Everything + web search |

## Features

- Deep dark theme
- Email + 6-digit OTP auth
- Streaming responses
- Visible thinking / reasoning steps
- Web search (Oracle)
- Image generation (Ember)
- **Chat history** (saved to Supabase, survives restarts)
- Unique model names only

## Setup

1. Clone the repo
2. Copy `.env.example` → `.env` and fill keys
3. In Supabase SQL editor, run `supabase/schema.sql`
4. `flutter pub get && flutter run`

## Status

- [x] Unique models (Pulse, Nova, Forge, Aether, Ember, Oracle)
- [x] Streaming + reasoning UI
- [x] Web search via Oracle
- [x] Chat history persistence
- [x] Deep dark theme
- [ ] Conversation list drawer
- [ ] Google / Apple Sign-In (Coming Soon)

*Build quietly. Let the work be the noise.*
