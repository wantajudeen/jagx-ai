-- JagX AI Chat History Schema
-- Run this in your Supabase SQL editor

-- Conversations
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null default 'New chat',
  model_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Messages
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references public.conversations(id) on delete cascade not null,
  role text not null check (role in ('user', 'assistant', 'system')),
  content text not null,
  image_url text,
  created_at timestamptz not null default now()
);

-- Indexes
create index if not exists idx_conversations_user on public.conversations(user_id);
create index if not exists idx_messages_conversation on public.messages(conversation_id);

-- RLS
alter table public.conversations enable row level security;
alter table public.messages enable row level security;

create policy "Users can manage their own conversations"
  on public.conversations
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can manage messages in their conversations"
  on public.messages
  for all
  using (
    conversation_id in (
      select id from public.conversations where user_id = auth.uid()
    )
  )
  with check (
    conversation_id in (
      select id from public.conversations where user_id = auth.uid()
    )
  );
