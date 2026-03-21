# Agenda Edu — API de Comunicados Escolares

API REST completa para um sistema de gestão de comunicados escolares, desenvolvida para processamento de alto volume e performance.

---

## 🛠 Stack Tecnológica

- **Ruby 3.3.0** + **Rails 7.2** (API mode)
- **PostgreSQL 16** — Banco de dados relacional principal
- **Redis 7** — Backend para Sidekiq e cache
- **Sidekiq 7** — Processamento assíncrono de disparos em background
- **Blueprinter** — Serialização JSON performática
- **Kaminari** — Paginação de recursos
- **Faker** — Geração de dados sintéticos para testes e seeds
- **Docker + Docker Compose** — Orquestração completa do ambiente

---

## 🚀 Configuração e Execução

### Pré-requisitos

- Docker & Docker Compose instalados.

### Subindo o ambiente

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>
cd SuperApp

# 2. Configure as variáveis de ambiente
cp .env.example .env

# 3. Suba os containers (build e execução)
docker compose up --build
```

> [!NOTE]
> O entrypoint do serviço `web` executa automaticamente `bin/rails db:prepare` ao subir, garantindo que o banco e as migrations estejam atualizados.

### Populando o banco (Volume Realista)

Para testar a performance do sistema, utilize o seed que gera uma massa crítica de dados:

```bash
docker compose run --rm web bundle exec rails db:seed
```

**O que o seed entrega:**
- **3 Escolas** (Namespace principal)
- **~51 Turmas**
- **10.000 Alunos**
- **15.000 Responsáveis**
- **Vínculos Complexos**: Aluno ↔ Turma e Aluno ↔ Responsável
- **Histórico**: Comunicados enviados com ~65% de taxa de leitura simulada.

Tempo estimado: **30-60 segundos** (otimizado com `insert_all` em lotes de 1.000).

---

## 🛤 Endpoints da API

A maioria dos endpoints do namespace `/api/v1` exige o header `X-School-Id` com o UUID da escola para garantir o isolamento dos dados.

```http
X-School-Id: <uuid-da-escola>
```

### 🏫 Escolas
*Não exige X-School-Id*

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/v1/schools` | Lista todas as escolas |
| GET | `/api/v1/schools/:id` | Detalhe de uma escola específica |

### 👥 Responsáveis (Guardians)

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/v1/guardians` | Lista todos os responsáveis da escola |
| GET | `/api/v1/guardians/:id` | Detalhe de um responsável |

### 🎓 Alunos e Turmas

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/v1/classrooms` | Lista turmas da escola |
| GET | `/api/v1/classrooms/:id` | Detalhe da turma |
| GET | `/api/v1/students` | Lista todos os alunos da escola |

### 📢 Comunicados (Announcements)

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/v1/announcements` | Lista comunicados (Suporta `page` e `per_page`) |
| GET | `/api/v1/announcements/:id` | Detalhe do comunicado + estatísticas básicas |
| POST | `/api/v1/announcements` | Cria um novo comunicado (Status: `draft`) |
| PATCH | `/api/v1/announcements/:id` | Atualiza comunicado (Apenas se status for `draft`) |
| DELETE | `/api/v1/announcements/:id` | Remove o comunicado |
| POST | `/api/v1/announcements/:id/send` | Dispara o job de envio (Retorna `202 Accepted`) |
| GET | `/api/v1/announcements/:id/stats` | Estatísticas detalhadas de entrega |
| GET | `/api/v1/announcements/:id/delivery_logs` | Lista logs de entrega (Amostra de 10) |

### 📑 Logs de Entrega

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/api/v1/delivery_logs/:id/read` | Marca o comunicado como lido pelo responsável |

---

## 🏗 Arquitetura e Decisões Técnicas

### Processamento em Lote e Assíncrono
O core do sistema é o envio de comunicados. Para evitar bloqueios em disparos para 15.000+ destinatários:
1. **Sidekiq**: O envio é delegado ao `AnnouncementDispatchJob`.
2. **Bulk Insert**: Utilizamos `insert_all!` em lotes de 1.000 registros para criar os `DeliveryLog`s, reduzindo drasticamente o overhead do banco de dados.

### Idempotência e Resiliência
- O job de disparo verifica duplicatas antes da inserção, garantindo que retries do Sidekiq não gerem cobranças ou logs duplicados.
- **RecipientResolver**: Garante unicidade de destinatários mesmo que um responsável possua múltiplos filhos na mesma escola/turma.

### Padrões de Projeto
- **Services**: Lógica de negócio isolada (`AnnouncementCreator`, `AnnouncementSender`).
- **Queries**: Consultas complexas abstraídas em objetos (`AnnouncementStatsQuery`).
- **Serializers**: Respostas JSON consistentes e rápidas com Blueprinter.

---

## 🛠 Comandos de Desenvolvimento

```bash
# Rodar a suíte de testes (RSpec)
docker compose run --rm web bundle exec rspec

# Acessar o Rails Console
docker compose run --rm web bundle exec rails c

# Monitorar Sidekiq
# Acesse: http://localhost:3000/sidekiq
```

---

## 📈 Melhorias Futuras

- [ ] **Webhooks/Action Cable**: Notificação em tempo real do progresso de envio.
- [ ] **Soft Delete**: Implementação de `discarded_at` para recuperação de dados.
- [ ] **Anexos**: Integração com Active Storage + S3 para arquivos nos comunicados.
- [ ] **Audit Log**: Rastreabilidade de quem criou/editou cada comunicado.