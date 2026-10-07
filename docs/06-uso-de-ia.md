# 6. Uso de IA

Usei o **Claude Code (Anthropic)** como assistente durante todo o teste.

**Onde a IA ajudou**
- Leitura do PDF e da documentação da entrega (a documentação é uma SPA; o texto foi extraído do bundle da aplicação).
- Esqueleto do repositório, scripts de sondagem da API (`curl`), script de exploração da UI e a suíte Playwright.
- Rascunho dos cenários em Gherkin e dos documentos (cenários, execução, bugs, evidências).
- Execução dos testes e da varredura de 304 cálculos de arredondamento.

**O que eu decidi e validei**
- Revisão dos cenários contra os critérios de aceite CA01-CA11.
- Conferência de cada bug contra a seção "Sobre este ambiente" da documentação, para não reportar comportamento esperado.
- Severidade, prioridade e interpretação das ambiguidades.
- Reprodução dos bugs antes de reportar: na tela e, para a API, manualmente no **Postman**.
- Escolha de quais cenários automatizar (12 testes, focados nos de maior risco).

**Um exemplo de verificação:** na primeira rodada exploratória, o script mostrou "Cupom inválido." para um cupom expirado. Ao reproduzir de forma isolada, o comportamento da loja estava correto (era espera fixa do script). O achado foi descartado e está registrado em `03-bugs.md`.
