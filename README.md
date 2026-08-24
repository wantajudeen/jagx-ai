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

## Capabilities

- Chat, reasoning, code, vision, images
- Web search (Oracle)
- Draft CVs / resumes
- Product packages & design drafts
- Documents users can personalize (proposals, reports, letters…)
- Structured output ready for PDF / files
- **Invisible watermark** on every text response  
  (`jagxai by JagX and JRILICENSE`) — hidden via zero-width characters

## Chat History

Conversations are saved to Supabase and survive app restarts.

Run `supabase/schema.sql` once in your Supabase SQL editor.

## Setup

```bash
git clone https://github.com/wantajudeen/jagx-ai.git
cd jagx-ai
cp .env.example .env
flutter pub get
flutter run
```

## Status

- [x] Unique models
- [x] Streaming + thinking UI
- [x] Web search
- [x] Chat history
- [x] Deep dark theme
- [x] Invisible text watermark
- [x] CV / document / design generation support
- [ ] Native PDF export button
- [ ] Conversation list drawer
- [ ] Google / Apple Sign-In (Coming Soon)

*Build quietly. Let the work be the noise.*
