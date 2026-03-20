# Agenda Edu — API de Comunicados Escolares

API REST para um sistema de comunicados escolares, desenvolvida como parte do teste técnico do time de Comunicação da Agenda Edu.

---

## Stack

- **Ruby 3.3** + **Rails 7.2** (API only)
- **PostgreSQL 16** — banco principal
- **Redis 7** — backend do Sidekiq
- **Sidekiq 7** — processamento assíncrono de envios
- **Blueprinter** — serialização de respostas JSON
- **Kaminari** — paginação
- **Faker** — geração de dados para seeds
- **Docker + Docker Compose** — ambiente de desenvolvimento

---

## Configuração e execução

### Pré-requisitos

- Docker
- Docker Compose

### Subindo o projeto

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>
cd agenda-edu

# 2. Copie o arquivo de variáveis de ambiente
cp .env.example .env

# 3. Suba todos os containers
docker compose up --build
```

O entrypoint já roda as migrations automaticamente ao subir o serviço `web`.

### Populando o banco com dados de teste

```bash
docker compose run --rm web bundle exec rails db:seed
```

O seed cria:
- 3 escolas
- ~51 turmas
- 10.000 alunos
- 15.000 responsáveis
- Vínculos aluno ↔ turma e aluno ↔ responsável
- Comunicados já enviados com logs de entrega (~65% lidos)

Tempo estimado: **30–60 segundos** (usa `insert_all` em lotes de 1.000).

### Comandos úteis

```bash
# Rails console
docker compose run --rm web bundle exec rails console

# Rodar migrations
docker compose run --rm web bundle exec rails db:migrate

# Ver status das migrations
docker compose run --rm web bundle exec rails db:migrate:status

# Rodar testes
docker compose run --rm web bundle exec rspec

# Ver rotas
docker compose run --rm web bundle exec rails routes | grep api
```

---

## Endpoints

Todos os endpoints do namespace `/api/v1` exigem o header `X-School-Id` com o UUID da escola.

```
X-School-Id: <uuid-da-escola>
```

### Escolas

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/v1/schools` | Lista todas as escolas |
| GET | `/api/v1/schools/:id` | Detalhe de uma escola |

### Turmas

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/v1/classrooms` | Lista turmas da escola |
| GET | `/api/v1/classrooms/:id` | Detalhe da turma com alunos |

### Alunos

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/v1/students` | Lista alunos da escola (paginado) |

### Comunicados

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/v1/announcements` | Lista comunicados da escola |
| POST | `/api/v1/announcements` | Cria um comunicado (rascunho) |
| GET | `/api/v1/announcements/:id` | Detalhe + estatísticas |
| PATCH | `/api/v1/announcements/:id` | Atualiza (só em `draft`) |
| DELETE | `/api/v1/announcements/:id` | Remove o comunicado |
| POST | `/api/v1/announcements/:id/send` | Dispara o envio |
| GET | `/api/v1/announcements/:id/stats` | Estatísticas de leitura |

### Logs de entrega

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/api/v1/delivery_logs/:id/read` | Marca comunicado como lido |

### Exemplos de request

**Criar comunicado para toda a escola:**
```json
POST /api/v1/announcements
{
  "announcement": {
    "title": "Reunião de pais e mestres",
    "content": "Convidamos todos os responsáveis para a reunião...",
    "scope": "school"
  }
}
```

**Criar comunicado para turmas específicas:**
```json
POST /api/v1/announcements
{
  "announcement": {
    "title": "Atividade especial - 5º ano",
    "content": "Os alunos participarão de uma visita ao museu...",
    "scope": "classrooms",
    "classroom_ids": ["uuid-da-turma-1", "uuid-da-turma-2"]
  }
}
```

**Criar comunicado para alunos específicos:**
```json
POST /api/v1/announcements
{
  "announcement": {
    "title": "Comunicado individual",
    "content": "Solicitamos a presença do responsável na secretaria...",
    "scope": "students",
    "student_ids": ["uuid-do-aluno"]
  }
}
```

**Resposta das estatísticas:**
```json
GET /api/v1/announcements/:id/stats
{
  "total": 4823,
  "read": 3142,
  "unread": 1681,
  "read_percentage": 65.15,
  "status": "sent",
  "sent_at": "2024-01-10T14:30:00.000Z"
}
```

---

## Modelagem

```
schools
  └── classrooms (has many)
  └── announcements (has many)

students
  └── classrooms (many-to-many via student_classrooms)
  └── guardians  (many-to-many via student_guardians)

announcements
  ├── scope: school | classrooms | students
  ├── status: draft → sending → sent
  ├── classrooms (many-to-many via announcement_classrooms)
  ├── students   (many-to-many via announcement_students)
  └── delivery_logs (has many)

delivery_logs
  ├── announcement (belongs to)
  ├── guardian     (belongs to)
  ├── read: boolean
  └── read_at: datetime
```

---

## Decisões técnicas

### Processamento assíncrono com Sidekiq

O envio de comunicados é o ponto mais crítico de performance. Um comunicado para "toda a escola" pode gerar 15.000+ `DeliveryLog`s de uma vez. Processar isso na thread do request travaria a aplicação.

A solução: o endpoint `POST /send` apenas muda o status para `sending` e enfileira o `AnnouncementDispatchJob`. A resposta é devolvida em milissegundos com `202 Accepted`. O processamento pesado acontece no Sidekiq em background.

### Bulk insert em lotes

Dentro do job, os `DeliveryLog`s são criados com `insert_all!` em lotes de 1.000 registros:

```
15.000 responsáveis / 1.000 por lote = 15 queries
vs.
15.000 INSERTs individuais
```

Diferença de 10–100x no tempo de execução. O mesmo padrão é usado no `seeds.rb` — popular 10.000 alunos leva menos de 60 segundos.

### Idempotência no job

Antes de criar os logs, o job verifica quais `guardian_ids` já têm `DeliveryLog` para aquele comunicado e pula esses. Isso garante que retries do Sidekiq (por timeout ou falha) não geram registros duplicados.

### RecipientResolver com DISTINCT

Um responsável pode ter dois filhos na mesma escola. Sem `DISTINCT`, ele receberia dois `DeliveryLog`s para o mesmo comunicado. O `RecipientResolver` usa `SELECT DISTINCT guardian_id` com JOIN nas tabelas de vínculo, garantindo unicidade antes do `insert_all!`.

### Índices estratégicos

A tabela `delivery_logs` é a que mais cresce em volume. Os índices foram escolhidos para cobrir as queries mais frequentes:

- `(announcement_id, guardian_id)` UNIQUE — evita duplicatas no nível do banco
- `(announcement_id, read)` — usado pela query de estatísticas com `GROUP BY read`; o Postgres resolve com index scan sem tocar na tabela
- `(guardian_id)` — para o responsável listar seus comunicados pendentes

### Separação de responsabilidades

```
Controllers    → recebem a request, delegam, devolvem a response
Services       → regras de negócio (AnnouncementCreator, AnnouncementSender, RecipientResolver)
Jobs           → processamento pesado em background (AnnouncementDispatchJob)
Queries        → consultas complexas isoladas (AnnouncementStatsQuery)
Serializers    → formatação da resposta JSON (Blueprinter)
Models         → validações, associações, scopes
```

### Máquina de estados do comunicado

```
draft → sending → sent
```

A transição `draft → sending` acontece na thread do request (síncrona, imediata). A transição `sending → sent` acontece dentro do job ao finalizar. Em caso de erro no job, o status volta para `draft` para permitir reenvio.

---

## O que eu faria com mais tempo

- **Action Cable** para notificar o frontend em tempo real quando o status mudar de `sending` para `sent`
- **Testes de integração** cobrindo o fluxo completo: criar → enviar → verificar delivery_logs → marcar como lido → verificar estatísticas
- **Rate limiting** com `rack-attack` nos endpoints de envio
- **Endpoint de listagem de delivery_logs** por responsável, para o app mobile consultar comunicados pendentes
- **Soft delete** nos comunicados com `discarded_at` em vez de destruição permanente
- **Upload de anexos** com Active Storage + S3

---

## Monitoramento

O Sidekiq Web UI está disponível em `http://localhost:3000/sidekiq` e permite acompanhar filas, jobs em processamento, retries e jobs com falha em tempo real.

---

## Collection de API

O arquivo `insomnia_collection.json` na raiz do projeto contém todos os endpoints configurados com variáveis de ambiente. Importe no Insomnia via `File → Import → From File`.