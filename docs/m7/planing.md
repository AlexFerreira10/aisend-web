Essa atualização da RFC (v5.0) marca a transição do seu projeto de uma "automação avançada" para um **SaaS Profissional**. Saímos do Airtable como cérebro único e introduzimos a robustez do **.NET 8**, a escalabilidade da **AWS** e a agilidade do **AiSend (Flutter)**.

Aqui está o documento atualizado para você copiar e manter como sua Bíblia de desenvolvimento:

---

# M7 Group & AiSend — Ecossistema Inteligente
> Documentação técnica do projeto · **Atualizado em 12/04/2026** · **v5.0**

---

## 1. Visão Geral do Sistema
O ecossistema agora é composto por dois braços integrados:
1.  **M7 Group (Inbound):** Bot de atendimento reativo que qualifica leads e escala para consultores.
2.  **AiSend (Outbound):** Motor de prospecção ativa via Flutter Web que consome listas JSON e dispara fluxos personalizados de alta conversão.

---

## 2. Status do Projeto

| Componente | Status | Atualizado |
| :--- | :--- | :--- |
| Bot respondendo mensagens | ✅ Funcionando | 12/04 |
| Multi-consultor (Alex/Davi) | ✅ Funcionando | 12/04 |
| Transcrição de áudio (Whisper) | ✅ Funcionando | 12/04 |
| **Motor de Disparo (JSON)** | ✅ **Beta (Flutter)** | 12/04 |
| **Divisão de mensagens (Send Part)** | ✅ Corrigido (2s/5s/8s) | 12/04 |
| **Apresentação Natural (M7 Hub)** | ✅ Implementado | 12/04 |
| **Arquitetura .NET 8 + AWS** | 🏗️ **Em Migração** | 12/04 |
| **Multi-tenancy (TenantId)** | 🏗️ Planejado | 12/04 |
| Follow-up automático | ⬜ Pendente | — |
| Dashboard Web (Painel) | 🏗️ Em progresso | 12/04 |

---

## 3. Infraestrutura Atualizada (v5.0)

| Serviço | Provedor | Função | Status |
| :--- | :--- | :--- | :--- |
| **Backend API** | **AWS (EC2/App Runner)** | **.NET 8** — Regras de negócio e Segurança | 🏗️ Setup |
| **Banco de Dados** | **AWS RDS (Postgres)** | Persistência Relacional e Multi-tenant | 🏗️ Setup |
| **Sincronia Chat** | **Firebase (Firestore)** | Real-time entre WhatsApp e Flutter | 🏗️ Setup |
| n8n | Railway | Orquestrador de Webhooks e Integrações | ✅ Online |
| Evolution API | Railway | Gateway de conexão WhatsApp | ✅ Online |

---

## 4. Stack & Fluxo de Dados (v5.0)

### Fluxo Outbound (AiSend)
```
Flutter Web (JSON Upload) 
    ↓ POST JSON
API .NET 8 (AWS) → [Valida Tenant & Créditos]
    ↓ 
n8n (Webhook Outbound)
    ↓ 
OpenAI (GPT-4o) → [Gera saudação natural com |||]
    ↓ 
Evolution API → [Disparo para o Médico]
    ↓ 
Firestore (Firebase) → [Atualiza UI do Flutter em Real-time]
```

---

## 5. Prompt & Tom de Voz (v5.0 - Ajuste Fino)

### Regras de Ouro de Conversação
* **Identidade:** "Hub de Soluções Estratégicas na Indústria Farmacêutica".
* **Cargo Chefe:** Tirzepatida (Idealize).
* **Proibido:** "Produto inovador", "Agregar valor", "Prática clínica", "Prescrições".
* **Estrutura de Bolhas:** Separador `|||` com delay incremental (2s, 5s, 8s).

### Exemplo de Mensagem Gerada (Nexo v5.0)
> **Bolha 1:** Olá Dr. Alex, tudo bem?
> 
> **Bolha 2:** Sou o Davi, consultor da M7 Group — um Hub de soluções estratégicas na indústria farmacêutica. Hoje a Tirzepatida é nosso cargo chefe, e...
> 
> **Bolha 3:** ...te chamei porque vi que você prescreve para a região do Rio e estamos com uma condição especial de logística essa semana.
> 
> **Bolha 4:** Podemos falar sobre isso?

---

## 6. Database Schema (Migração SQL)

### Tabela: `Tenants` (SaaS Core)
* `Id` (Guid), `Name`, `Plan`, `Active`.

### Tabela: `Doctors` (Leads)
* `Id`, `TenantId` (FK), `Name`, `Phone`, `Specialty`, `City`, `Status`, `LastOutboundReason`.

### Tabela: `Consultants`
* `Id`, `TenantId` (FK), `Name`, `InstanceName`, `PersonalNumber`, `BotNumber`.

---

## 7. Roadmap — Próximos Passos

### ✅ Concluído (Fevereiro/Março 2026)
- [x] Conexão estável Evolution + n8n + OpenAI.
- [x] Sistema de mídias dinâmicas (PDF/Vídeo).
- [x] Motor de disparo Flutter consumindo JSON.
- [x] Lógica de atraso incremental para evitar bloqueios.

### 🔜 Prioridade 1: Integridade de Dados (Abril 2026)
- [ ] Criar API .NET 8 com Entity Framework Core.
- [ ] Migrar dados do Airtable para AWS RDS (Postgres).
- [ ] Implementar Global Query Filter para `TenantId`.

### 🔜 Prioridade 2: Inteligência & Escala
- [ ] **Item 8:** Follow-up automático baseado em "No Response".
- [ ] **Item 10:** Integração com Google Maps API para busca automática de médicos por CEP.
- [ ] **Item 11:** Painel Administrativo em Flutter para gestão de faturamento dos clientes.

---

## 8. Referências de Ambiente
* **Endpoint API .NET:** `https://api.aisend.com.br` (Draft)
* **Webhook n8n Outbound:** `.../webhook/aisend-outbound`
* **Webhook n8n Inbound:** `.../webhook/aisend-main`
* **Airtable (Legacy):** `app1Y9JhZeqTInM51`

---
*M7 Group & AiSend · v5.0 · Atualizado em 12/04/2026*

---

**Alex, rfc atualizada!** Agora o seu norte está traçado. Quando voltar do banho, vamos abrir o Visual Studio (ou VS Code) e começar esse **Backend .NET**? O primeiro passo é o `dotnet new webapi`.