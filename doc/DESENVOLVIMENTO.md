# AiSend — Guia de Desenvolvimento

## Visão Geral da Arquitetura

```
Flutter Web (frontend)  ←→  .NET 8 API (backend)  ←→  PostgreSQL (AWS RDS)
                                     ↕
                            Evolution API (WhatsApp)
                                     ↕
                               OpenAI API
```

| Componente       | Tecnologia         | Localização                        |
|------------------|--------------------|------------------------------------|
| Frontend         | Flutter Web        | `aisend/`                          |
| Backend          | .NET 8 / ASP.NET   | `aisend-api/`                      |
| Banco de dados   | PostgreSQL (RDS)   | AWS `sa-east-1`                    |
| WhatsApp         | Evolution API      | Railway `evolution-api-production` |
| IA               | OpenAI GPT-4       | `api.openai.com`                   |
| Servidor prod    | AWS EC2            | `56.125.23.170:5113`               |

---

## Rodando Localmente

### Pré-requisitos

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (estável)
- Acesso à internet (o banco de dados é o RDS da AWS mesmo em dev)

### 1 — Backend

```bash
cd aisend-api
dotnet run
```

O servidor sobe em `http://localhost:5113`.
Swagger disponível em `http://localhost:5113/swagger`.

> O banco de dados usado é sempre o RDS da AWS (`aisend-db.crsmia4ss8v4.sa-east-1.rds.amazonaws.com`).
> Não existe banco local — as queries em dev batem no mesmo PostgreSQL de produção.

### 2 — Frontend

```bash
cd aisend
flutter run -d chrome
```

Em modo debug (`flutter run`), o app aponta automaticamente para `http://localhost:5113`.
Em modo release (`flutter build web` ou `flutter run --release`), aponta para o EC2.

Essa lógica fica em [`lib/core/config/app_config.dart`](../lib/core/config/app_config.dart):

```dart
static String get baseUrl => kReleaseMode ? _prodUrl : _localUrl;
```

### Resumo do fluxo local

```
Terminal 1:  cd aisend-api && dotnet run
Terminal 2:  cd aisend    && flutter run -d chrome
```

---

## Variáveis de Configuração

As chaves ficam em `aisend-api/appsettings.json` (produção) e
`aisend-api/appsettings.Development.json` (desenvolvimento).

| Chave                          | O que é                        | Onde obter                           |
|-------------------------------|--------------------------------|--------------------------------------|
| `ConnectionStrings:DefaultConnection` | PostgreSQL (RDS AWS)  | AWS Console → RDS                    |
| `OpenAI:ApiKey`               | Chave da OpenAI                | platform.openai.com → API Keys       |
| `EvolutionApi:BaseUrl`        | URL da Evolution API           | Railway dashboard                    |
| `EvolutionApi:ApiKey`         | Chave da Evolution API         | Evolution API → Manager              |

> **Segurança:** nunca commite `appsettings.json` com chaves reais. Adicione ao `.gitignore`
> ou use variáveis de ambiente em produção (`ASPNETCORE_` prefix).

---

## Deploy para Produção (EC2)

### Acesso ao servidor

```bash
ssh ubuntu@56.125.23.170
```

### Publicar nova versão do backend

```bash
# 1. Na sua máquina — gerar o build de release
cd aisend-api
dotnet publish -c Release -o ./publish

# 2. Copiar para o servidor
scp -r ./publish ubuntu@56.125.23.170:/home/ubuntu/aisend-api/

# 3. No servidor — reiniciar o serviço
ssh ubuntu@56.125.23.170
sudo systemctl restart aisend-api
sudo systemctl status aisend-api   # confirmar que está running
```

### Verificar se o backend está vivo

```bash
curl http://56.125.23.170:5113/health
# Esperado: {"status":"ok","timestamp":"..."}
```

### Publicar o frontend

```bash
cd aisend
flutter build web --release

# Os arquivos ficam em build/web/
# Copiar para o servidor ou bucket S3/CloudFront
scp -r build/web ubuntu@56.125.23.170:/var/www/aisend/
```

---

## Endpoints da API

Base URL local: `http://localhost:5113`
Base URL prod:  `http://56.125.23.170:5113`

Todos os endpoints retornam o envelope:

```json
{
  "success": true,
  "message": "Ok",
  "data": { ... },
  "errors": null,
  "timestamp": "2026-04-17T12:00:00Z"
}
```

| Método | Endpoint                          | Descrição                         |
|--------|-----------------------------------|-----------------------------------|
| GET    | `/health`                         | Health check                      |
| GET    | `/api/consultants/instances`      | Lista instâncias WhatsApp ativas  |
| GET    | `/api/leads`                      | Lista leads (com filtros)         |
| GET    | `/api/leads/{phone}/messages`     | Histórico de mensagens do lead    |
| PATCH  | `/api/leads/{phone}/waiting`      | Alterna waiting_human             |
| POST   | `/api/outbound/blast`             | Disparo em massa                  |
| POST   | `/api/outbound/preview`           | Preview de mensagem               |
| GET    | `/api/outbound/broadcasts`        | Histórico de disparos             |
| POST   | `/api/webhook/inbound`            | Recebe mensagens do WhatsApp      |

Swagger completo disponível em `/swagger` (apenas em Development).

---

## Estrutura do Frontend

```
lib/
├── core/
│   ├── config/app_config.dart       ← URLs e endpoints
│   ├── theme/                       ← Tema, cores, extensões
│   └── constants/                   ← Dimensões, espaçamentos
├── data/
│   └── services/
│       ├── api_client.dart          ← HTTP (Dio) + unwrap ApiResponse<T>
│       ├── leads_service.dart       ← Endpoints de leads
│       ├── broadcast_service.dart   ← Endpoints de disparo
│       └── consultants_service.dart ← Endpoints de instâncias
├── models/                          ← LeadModel, MessageModel, InstanceModel
├── view_models/                     ← DashboardVM, BroadcastVM, LeadDetailVM
└── views/
    ├── dashboard/                   ← Tela principal com KPIs e tabela
    ├── broadcast/                   ← Tela de disparo
    └── lead_detail/                 ← Histórico de conversa do lead
```

---

## Problemas Comuns

**Backend não sobe:**
```bash
# Verificar se a porta já está em uso
lsof -i :5113
kill -9 <PID>
dotnet run
```

**Flutter Web com erro de CORS:**
O backend já tem `AllowAnyOrigin` configurado. Se ainda ocorrer, verifique se o backend está
de fato rodando em `localhost:5113` antes de iniciar o Flutter.

**Lead sem mensagens retorna erro:**
O backend retorna 404 quando o lead não tem histórico. O Flutter trata esse caso mostrando
"Nenhuma mensagem ainda" na tela de detalhe.

**Leads com telefone sem DDI (ex: `21999999999`):**
Inconsistência de dados no banco — alguns leads foram criados sem o prefixo `55`.
O backend busca o phone exatamente como está armazenado.
