-- =====================================================================
-- FUGA DO LABIRINTO · banco de dados da classificação
-- Cole TUDO no Supabase (menu SQL Editor) e clique em Run.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) CREATE TABLE: onde cada tentativa concluída fica guardada
-- ---------------------------------------------------------------------
create table public.tentativas (
  id          uuid        primary key,   -- gerado no celular; evita gravar duas vezes a mesma tentativa
  nome        text        not null,
  sobrenome   text        not null,
  nome_chave  text        not null,      -- nome+sobrenome em minúsculas e sem acento (para achar repetidos)
  tempo_ms    integer     not null,      -- tempo em milissegundos
  dispositivo text,                      -- identificador anônimo do celular (ajuda a flagrar troca de nome)
  criado_em   timestamptz not null default now(),   -- hora em que o SERVIDOR recebeu
  constraint tentativas_nome_ck      check (char_length(btrim(nome)) between 1 and 40),
  constraint tentativas_sobrenome_ck check (char_length(btrim(sobrenome)) between 1 and 40),
  constraint tentativas_tempo_ck     check (tempo_ms between 1 and 5999999),   -- até 99:59.999
  constraint tentativas_disp_ck      check (dispositivo is null or char_length(dispositivo) <= 64)
);

create index tentativas_chave_idx on public.tentativas (nome_chave, criado_em);

-- Segurança: ninguém de fora lê, altera ou apaga a tabela diretamente.
alter table public.tentativas enable row level security;
revoke all on public.tentativas from anon, authenticated;

-- ---------------------------------------------------------------------
-- 2) Função auxiliar: transforma 95000 ms em "01:35.000"
-- ---------------------------------------------------------------------
create or replace function public.formatar_tempo(ms integer)
returns text
language sql
immutable
set search_path = ''
as $$
  select to_char(ms / 60000, 'FM00') || ':' ||
         to_char((ms % 60000) / 1000, 'FM00') || '.' ||
         to_char(ms % 1000, 'FM000');
$$;

-- ---------------------------------------------------------------------
-- 3) Função que o jogo chama ao terminar: grava a tentativa.
--    "on conflict (id) do nothing" = se o celular reenviar a mesma
--    tentativa (rede ruim), o banco ignora a cópia. Nada duplica.
-- ---------------------------------------------------------------------
create or replace function public.registrar_tentativa(
  p_id          uuid,
  p_nome        text,
  p_sobrenome   text,
  p_tempo_ms    integer,
  p_dispositivo text default null
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_nome      text := regexp_replace(btrim(p_nome),      '\s+', ' ', 'g');
  v_sobrenome text := regexp_replace(btrim(p_sobrenome), '\s+', ' ', 'g');
begin
  insert into public.tentativas (id, nome, sobrenome, nome_chave, tempo_ms, dispositivo)
  values (
    p_id,
    v_nome,
    v_sobrenome,
    translate(lower(v_nome || ' ' || v_sobrenome),
              'áàâãäéèêëíìîïóòôõöúùûüç',
              'aaaaaeeeeiiiiooooouuuuc'),
    p_tempo_ms,
    p_dispositivo
  )
  on conflict (id) do nothing;

  return 'ok';
end;
$$;

-- ---------------------------------------------------------------------
-- 4) Visões (consultas salvas)
--    ranking_labirinto  = a lista final 1, 2, 3... (só a 1ª tentativa de cada nome)
--    auditoria_labirinto = TODAS as tentativas, para você conferir
-- ---------------------------------------------------------------------
create or replace view public.ranking_labirinto
with (security_invoker = true) as
with ordenadas as (
  select t.*,
         row_number() over (partition by t.nome_chave order by t.criado_em, t.id) as n_tentativa
  from public.tentativas t
),
validas as (
  select o.*,
         row_number() over (order by o.tempo_ms, o.criado_em, o.id) as posicao
  from ordenadas o
  where o.n_tentativa = 1
)
select v.posicao,
       v.nome,
       v.sobrenome,
       public.formatar_tempo(v.tempo_ms) as tempo,
       v.tempo_ms,
       case when v.tempo_ms < 30000 then 'CONFERIR: tempo muito baixo' end as alerta,
       (v.criado_em at time zone 'America/Sao_Paulo') as horario
from validas v
order by v.posicao;

create or replace view public.auditoria_labirinto
with (security_invoker = true) as
select row_number() over (partition by t.nome_chave order by t.criado_em, t.id) as n_tentativa,
       t.nome,
       t.sobrenome,
       public.formatar_tempo(t.tempo_ms) as tempo,
       t.tempo_ms,
       (t.criado_em at time zone 'America/Sao_Paulo') as horario,
       t.dispositivo,
       (select count(distinct x.nome_chave)
          from public.tentativas x
         where x.dispositivo is not null
           and x.dispositivo = t.dispositivo) as nomes_neste_aparelho
from public.tentativas t
order by t.criado_em;

-- ---------------------------------------------------------------------
-- 5) Consulta do ranking protegida por senha (usada pela página ranking.html)
--    >>> TROQUE 'TROQUE_ESTA_SENHA' por uma senha só sua <<<
-- ---------------------------------------------------------------------
create or replace function public.consultar_ranking(p_senha text)
returns setof public.ranking_labirinto
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_senha is distinct from 'TROQUE_ESTA_SENHA' then
    raise exception 'senha incorreta' using errcode = '28000';
  end if;
  return query select * from public.ranking_labirinto order by posicao;
end;
$$;

-- ---------------------------------------------------------------------
-- 6) Permissões: o celular só pode chamar as 2 funções acima
-- ---------------------------------------------------------------------
revoke all on function public.registrar_tentativa(uuid, text, text, integer, text) from public;
revoke all on function public.consultar_ranking(text) from public;
grant execute on function public.registrar_tentativa(uuid, text, text, integer, text) to anon;
grant execute on function public.consultar_ranking(text) to anon;
revoke all on public.ranking_labirinto, public.auditoria_labirinto from anon, authenticated;

notify pgrst, 'reload schema';
