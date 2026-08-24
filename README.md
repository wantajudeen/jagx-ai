# JagX AI

Native Android & iOS intelligence console by **JagX & JRILICENSE**.

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
- Streaming + thinking UI
- Web search (Oracle)
- Image generation (Ember)
- CV / document / design drafts
- Invisible watermark on all text
- Chat history (Supabase)
- Conversation drawer (switch / delete chats)
- Export conversation as PDF

## How to build & run

### 1. One-time setup

```bash
git clone https://github.com/wantajudeen/jagx-ai.git
cd jagx-ai
cp .env.example .env
```

Fill `.env` with:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `OPENROUTER_API_KEY` (and others if you have them)

### 2. Supabase tables

In Supabase → SQL Editor, run the file:
`supabase/schema.sql`

### 3. Run on computer

```bash
flutter pub get
flutter run
```

### 4. Run from phone (Codespaces)

1. Open the repo on GitHub in your phone browser
2. Click **Code** → **Codespaces** → Create codespace
3. In the terminal:
   ```bash
   flutter pub get
   flutter run -d web-server --web-port=3000
   ```
4. Open the preview link Codespaces gives you

### 5. Build APK (Android)

```bash
flutter build apk --release
```
The APK will be at:
`build/app/outputs/flutter-apk/app-release.apk`

## Status

- [x] Unique models
- [x] Streaming + reasoning
- [x] Web search
- [x] Chat history
- [x] Conversation drawer
- [x] PDF export
- [x] Invisible watermark
- [x] Deep dark theme
- [ ] Google / Apple Sign-In (Coming Soon)

*Build quietly. Let the work be the noise.*
