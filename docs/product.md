📄 Doc 1: Especificação de Negócio (AiSend MVP - Foco Consultor)

1. Objetivo do MVP

Substituir o processo manual de disparo por uma interface inteligente. O foco único é permitir que o Consultor carregue contatos e inicie uma campanha de mensagens onde o conteúdo é gerado por contexto (IA).

2. Ator Único: Consultor

Função: Operar a máquina de vendas.

Fluxo: Entrar -> Ver saúde da base -> Selecionar leads -> Definir Motivo -> Disparar.

3. Funcionalidades do MVP (Mocado)

Dashboard de Resultados: Visualizar estatísticas simuladas (Total, Taxa de Resposta, Leads Quentes) para validar o layout.

Tabela de Atividade: Lista de contatos com status fictícios (Frio, Morno, Quente) gerados localmente.

Fluxo de Disparo:

Seleção de instância (estático).

Input de texto para o "Motivo do Contato".

Simulação de progresso de envio (Barra de progresso que avança via timer).

4. Regra de Negócio Central

Ação de Disparo: Ao clicar em "Iniciar", o sistema deve simular o envio de mensagens uma a uma, alterando o status dos leads na memória local (mock) até completar 100%.

📄 Doc 2: Arquitetura e Estrutura Técnica (AiSend Mock Edition)

1. Padrão de Projeto

Framework: Flutter Web.

Gerenciamento de Estado: Nativo com ChangeNotifier.

Mock Strategy: Os dados não virão de API, mas de uma lista estática do sources, por enquanto, .

Todo codigo em ingles

2. Estrutura de Pastas (lib/)

lib/
├── core/            # Cores, temas e constantes.
├── models/          # Classes de dados puras (LeadModel).
├── data/            # CAMADA DE DADOS (Nova)
│   ├── sources/     # Onde o dado "nasce" (Mock ou API futuramente).
│   └── repositories/# Onde a lógica de busca reside (Abstração).
├── view_models/     # Consome o Repository, não o dado direto.
├── views/           # UI pura.
└── widgets/         # Componentes.


Aqui está o documento focado exclusivamente na inteligência por trás do **AiSend**. Este é o guia que define como o sistema se comporta e quais problemas ele resolve para o consultor.

---

# 📄 Documento: Casos de Uso e Regras de Negócio – AiSend MVP

**Produto:** AiSend (Agente de IA para Prospecção Inteligente)  
**Versão:** 1.0 (MVP – Foco em Operação de Disparo)  
**Ator Principal:** Consultor (Operador de Vendas)

---

## 1. Casos de Uso (UC)

### UC01: Visualizar Saúde da Base (Dashboard)
* **Ação:** O Consultor acessa a página "Central de Resultados".
* **Fluxo:**
    1. O sistema carrega os dados consolidados (mocado via Data Layer).
    2. Exibe KPIs: Total de leads, Taxa de Resposta e Leads Quentes (Interessados).
    3. Exibe a tabela de "Atividade Recente" com as últimas mensagens recebidas.
* **Objetivo:** Permitir que o consultor decida se precisa iniciar um novo disparo ou focar no atendimento manual.

### UC02: Configurar Novo Disparo (Ação de Prospecção)
* **Ação:** O Consultor acessa o "Motor de Disparo".
* **Fluxo:**
    1. O Consultor realiza o upload de uma lista (CSV/XLSX) ou seleciona um segmento (ex: "Leads Frios").
    2. O Consultor seleciona a instância de disparo (Alex ou Davi).
    3. O Consultor descreve o **"Motivo do Contato"** (Ex: "Oferecer upgrade de plano").
* **Objetivo:** Preparar o motor para agir com inteligência, sem necessidade de escrever scripts fixos.

### UC03: Executar e Monitorar Campanha
* **Ação:** O Consultor clica em "Iniciar Disparo".
* **Fluxo:**
    1. O sistema inicia a simulação de envio (mocado com Timer).
    2. A barra de progresso avança conforme as mensagens "saem".
    3. O sistema exibe métricas em tempo real: Enviados, Respondidos e Erros.
* **Objetivo:** Dar transparência ao processo e garantir que o consultor saiba quando a tarefa for concluída.

---

## 2. Regras de Negócio (RN)

### RN01: O Diferencial do "Motivo" (Variabilidade de IA)
* O sistema **não permite** o envio de mensagens estáticas (o mesmo texto para todos).
* **Regra:** O usuário fornece o *Contexto/Motivo*. O motor de IA (futuramente via n8n) deve gerar uma variação única para cada lead. 
* No MVP mocado, o sistema deve simular que cada mensagem enviada é ligeiramente diferente para evitar o padrão detectável pelo WhatsApp (Anti-Ban).

### RN02: Saneamento de Dados (Data Integrity)
* Ao carregar uma lista, o sistema deve:
    1. Remover números duplicados.
    2. Validar se o número possui o formato de DDI+DDD+Número (ex: 55219...).
    3. Ignorar linhas com dados incompletos.

### RN03: Classificação de Temperatura (Status IA)
* O sistema deve categorizar os leads automaticamente com base na resposta recebida:
    * **Quente (Hot):** Demonstrou interesse claro, pediu preço ou catálogo.
    * **Morno (Warm):** Respondeu, mas tem dúvidas ou pediu para ser contatado em outro momento.
    * **Frio (Cold):** Não respondeu ou solicitou a remoção da lista (Opt-out).

### RN04: Intervalo Caótico (Simulação Humana)
* As mensagens não podem ser enviadas em intervalos fixos (ex: 1 a cada 10 segundos).
* **Regra:** O intervalo entre disparos deve ser **aleatório** (ex: entre 30 a 90 segundos) para simular o comportamento de digitação humana e proteger a saúde da conta (instância).

### RN05: Governança de Instâncias
* Uma campanha só pode ser iniciada se a instância selecionada estiver com o status **"Conectado"**. 
* Se a instância cair durante o disparo, o sistema deve pausar a campanha automaticamente e notificar o usuário.

---

### 3. Matriz de Status (Referência para a UI)

| Status | Cor na UI | Significado |
| :--- | :--- | :--- |
| **Quente** | Laranja/Fogo | Lead pronto para fechamento. |
| **Morno** | Amarelo | Lead precisa de nutrição/esclarecimento. |
| **Frio** | Azul/Cinza | Lead sem interação ou sem interesse. |

---

**Próximo Passo:** Com este documento e o de **Arquitetura Técnica** em mãos, o seu prompt para a IA (como o Claude ou o Antigravity) ficará infalível. Você está pronto para gerar o código ou quer refinar alguma dessas regras de intervalo ou classificação?