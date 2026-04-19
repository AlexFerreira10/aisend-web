# 🚀 Guia Operacional: AiSend

Este guia contém tudo o que você precisa saber para desenvolver, testar e publicar mudanças no sistema AiSend.

---

## 💻 1. Ambiente de Desenvolvimento (Local)
**Onde as mudanças acontecem.**

### Como rodar o App (Frontend)
No VS Code, use o menu **Run and Debug** (ícone de play na lateral):
- **AiSend [AWS Remote]**: O app roda no seu computador, mas usa os dados reais da Amazon. **(Recomendado para testar visual)**.
- **AiSend [Local API]**: O app roda no seu computador e tenta conectar no seu backend local.

### Como saber se estou no ambiente Local?
Olhe a URL no navegador:
- Se começar com `http://localhost:...`, você está vendo as mudanças que **acabou de fazer no código**.

---

## 🌍 2. Ambiente de Produção (AWS)
**Onde o site oficial vive.**

### Como saber se estou na AWS?
Olhe a URL no navegador:
- Se for `http://56.125.23.170:5113`, você está vendo o sistema oficial.

---

## 🛠️ 3. Fluxo de Trabalho (Passo a Passo)

### Cenário A: Mudei algo no Design ou Telas (Frontend)
1.  **Teste:** Aperte o "Play" no VS Code e veja se ficou bom.
2.  **Gere os arquivos:** No terminal (dentro da pasta `aisend`), rode:
    ```bash
    flutter build web
    ```
3.  **Suba para a AWS:**
    ```bash
    scp -i ~/.ssh/aisend-backend-key.pem -r build/web/* ubuntu@56.125.23.170:/home/ubuntu/aisend-publish/wwwroot/
    ```

### Cenário B: Mudei algo nas Regras ou API (Backend)
1.  **Gere os arquivos:** No terminal (na raiz do projeto), rode:
    ```bash
    /usr/local/share/dotnet/dotnet publish aisend-api/aisend-api.csproj -c Release -o aisend-api/publish
    ```
2.  **Suba para a AWS:**
    ```bash
    scp -i ~/.ssh/aisend-backend-key.pem -r aisend-api/publish/* ubuntu@56.125.23.170:/home/ubuntu/aisend-publish/
    ```
3.  **Reinicie o servidor:** (Para a mudança entrar em vigor):
    ```bash
    ssh -i ~/.ssh/aisend-backend-key.pem ubuntu@56.125.23.170 "sudo systemctl restart aisend-api"
    ```

---

## 📋 4. Comandos Essenciais (Cheat-sheet)

| Ação | Comando |
| :--- | :--- |
| **Limpar cache do Flutter** | `flutter clean` |
| **Baixar dependências** | `flutter pub get` |
| **Build de Produção (Front)** | `flutter build web` |
| **Ver status do servidor** | `ssh -i ~/.ssh/aisend-backend-key.pem ubuntu@56.125.23.170 "sudo systemctl status aisend-api"` |

---

## 💡 Dicas de Ouro
- **CORS Error:** Se o app local disser "Sem conexão", dê um Refresh (F5) no Chrome.
- **Cache do Navegador:** Às vezes você sobe a mudança mas o Chrome continua mostrando o antigo. Use `Cmd + Shift + R` no Mac para forçar uma limpeza de cache.
- **Logs:** Se algo der errado no servidor, peça para eu ler os logs usando: `journalctl -u aisend-api -n 100`.
