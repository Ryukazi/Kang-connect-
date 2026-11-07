-- Run this AFTER the initial schema supplied earlier.
-- Adds private invite acceptance and a safe per-user chat listing.
-- Functions execute with a controlled owner context; inputs are validated.

create or replace function public.create_private_invitation()
returns text
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  new_code text;
begin
  if auth.uid() is null then
    raise exception 'You must be signed in';
  end if;

  new_code := upper(encode(gen_random_bytes(5), 'hex'));
  insert into public.invitations(owner_id, code, expires_at)
  values (auth.uid(), new_code, now() + interval '7 days');
  return new_code;
end;
$$;

create or replace function public.accept_private_invitation(invite_code text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  inv public.invitations%rowtype;
  new_chat_id uuid;
begin
  if auth.uid() is null then
    raise exception 'You must be signed in';
  end if;

  select * into inv
  from public.invitations
  where code = upper(trim(invite_code))
  for update;

  if not found then raise exception 'Invitation code is invalid'; end if;
  if inv.expires_at < now() then raise exception 'Invitation code has expired'; end if;
  if inv.used_by is not null then raise exception 'Invitation code has already been used'; end if;
  if inv.owner_id = auth.uid() then raise exception 'You cannot accept your own invitation'; end if;

  insert into public.private_chats(owner_id, member_id)
  values (inv.owner_id, auth.uid())
  returning id into new_chat_id;

  update public.invitations set used_by = auth.uid() where id = inv.id;
  return new_chat_id;
end;
$$;

create or replace function public.get_my_private_chats()
returns table(chat_id uuid, other_user_id uuid, other_display_name text)
language sql
security definer
stable
set search_path = public
as $$
  select c.id,
         case when c.owner_id = auth.uid() then c.member_id else c.owner_id end,
         coalesce(p.display_name, 'Private connection')
  from public.private_chats c
  left join public.profiles p
    on p.id = case when c.owner_id = auth.uid() then c.member_id else c.owner_id end
  where auth.uid() in (c.owner_id, c.member_id)
  order by c.created_at desc;
$$;

revoke all on function public.create_private_invitation() from public;
revoke all on function public.accept_private_invitation(text) from public;
revoke all on function public.get_my_private_chats() from public;
grant execute on function public.create_private_invitation() to authenticated;
grant execute on function public.accept_private_invitation(text) to authenticated;
grant execute on function public.get_my_private_chats() to authenticated;

-- Supabase Realtime is used by the chat screen. Enable the messages table
-- in Database -> Publications -> supabase_realtime if it is not already enabled.
