# 🌍 Guia de Ambientes: AiSend

Este guia explica como alternar entre o servidor da **AWS (Remoto)** e o seu servidor **Local (Mac)** durante o desenvolvimento.

## 🚀 Como alternar no VS Code

Agora você tem dois perfis de lançamento configurados no seu VS Code. Para escolher um:

1.  Abra o VS Code na pasta do projeto.
2.  No canto inferior direito (barra de status), ou na aba **Run and Debug** (ícone de play com um besouro), você verá um menu seletor.
3.  Escolha uma das opções:
    *   **AiSend [AWS Remote]:** Conecta o app que roda no seu Mac diretamente ao banco de dados e API que estão na AWS. Use para testar a interface com dados reais.
    *   **AiSend [Local API]:** Conecta o app ao seu backend rodando localmente no Mac (porta 5113). Use para desenvolver novas funcionalidades na API.

## 🛠️ Comandos de Terminal

Se preferir usar o terminal, você pode injetar as variáveis manualmente:

### Para rodar com AWS (Remoto):
```bash
flutter run -d chrome --dart-define=BASE_URL=http://56.125.23.170:5113
```

### Para rodar com Backend Local:
```bash
flutter run -d chrome --dart-define=BASE_URL=http://localhost:5113
```

## 📦 Deploy (Produção)

Para gerar a versão que vai para a web (Produção), o comando padrão já aponta para a AWS. Você não precisa mudar nada:

```bash
flutter build web
```

> [!NOTE]
> O padrão do sistema agora é inteligente: se você não informar nada, ele assume a **AWS** como destino, garantindo que o seu deploy nunca aponte para o localhost por engano.

## ⚠️ Observação sobre CORS
Se ao rodar localmente (`localhost`) conectado na AWS você ver uma mensagem de "Sem conexão", pode ser o navegador bloqueando a requisição por segurança. 
- **Solução:** Tente rodar o app como Desktop (se tiver o SDK do MacOS instalado) ou use uma extensão de "Allow CORS" no Chrome apenas para o teste.
