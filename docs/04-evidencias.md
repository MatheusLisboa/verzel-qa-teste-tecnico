# 4. Evidências da execução

Tudo está em [`docs/evidencias/`](evidencias). As evidências foram geradas em 06/10/2026 contra o ambiente compartilhado.

## Capturas de tela (`evidencias/screenshots/`)

| Arquivo | O que mostra | Relaciona-se com |
|---|---|---|
| E01-home.png | Vitrine com os 8 produtos | CT-01 |
| E02-carrinho-abaixo-200.png | Frete 19,90 e "Faltam R$ 140,10" | CT-03 |
| E03b-cupom-invalido.png | Mensagem "Cupom inválido." | CT-09 |
| E03d-cupom-aplicado.png | Cupom aplicado digitado em minúsculas e com espaços | CT-07, CT-08 |
| E04-limite-5-unidades.png | "+" desabilitado e "Limite de 5 unidades por produto." | CT-18 |
| E05-cupom-persiste-apos-remover-itens.png | Cupom aplicado em carrinho novo | **BUG-04** |
| E06-subtotal-200-cobra-frete.png | Subtotal 200,00 com frete 19,90 e "Faltam R$ 0,00" | **BUG-01** |
| E06b-subtotal-200-cupom.png | Subtotal 200,00 + cupom: total 199,90 | **BUG-01** |
| E07c-frete-gratis-com-cupom.png | Frete grátis com cupom | CT-13 |
| E08a-checkout.png / E08b-checkout-vazio.png | Checkout e validações | CT-24 |
| E08d-confirmacao.png | Pedido confirmado | CT-25 |
| E10a-mobile-home.png / E10b-mobile-carrinho.png | Layout 375 px | CT-31 |
| E12-sessionstorage-qtd-9-aceita.png | Carrinho com 9 unidades aceito (via `sessionStorage`) | **BUG-02** |
| E11-documentacao.png | Documentação como foi testada (v2.3.0) | referência |

## Saídas e scripts

| Arquivo | Conteúdo |
|---|---|
| [exploratorio-ui.mjs](evidencias/exploratorio-ui.mjs) · [saida](evidencias/exploratorio-ui.saida.txt) | Sessão exploratória na UI: valores lidos do resumo em cada passo |
| [api-probe-1.sh](evidencias/api-probe-1.sh) · [saida](evidencias/api-probe-1.saida.txt) | Sondagem da API: produtos, cálculo, cupons, quantidades, estrutura |
| [api-probe-2.sh](evidencias/api-probe-2.sh) · [saida](evidencias/api-probe-2.saida.txt) | Sondagem da API: limite de frete com cupom, pedidos, validação do cliente |
| [api-varredura-arredondamento.mjs](evidencias/api-varredura-arredondamento.mjs) · [saida](evidencias/api-varredura-arredondamento.saida.txt) | 304 cálculos comparados com a regra em centavos inteiros (CA11): só divergiu no BUG-01 |

> **Nota sobre `exploratorio-ui.saida.txt`:** a linha `E03c` mostra "Cupom inválido." para o cupom expirado. É um artefato do script (espera fixa de 700 ms leu a mensagem anterior), **não** um bug da loja: o teste AT-03, com espera adequada, confirma "Cupom expirado.". Detalhes em `03-bugs.md`.

## Resultado da automação (Playwright)

```
Running 12 tests using 5 workers
12 passed
```
Entre eles, 4 testes `@bug` marcados com `test.fail()` (AT-06, AT-09, AT-10, AT-11), que documentam BUG-01, 02 e 03. Para ver o relatório HTML com traces: `npm test && npm run report`.

> **API e Postman:** as saídas guardadas em `evidencias/` vêm dos scripts `curl`. Os mesmos cenários e os bugs de API (BUG-01, 02, 03 e 05) foram reproduzidos e validados manualmente no **Postman**, com as mesmas requisições (método, URL, cabeçalho `Content-Type: application/json` e corpo JSON dos scripts).

> A sessão exploratória foi rodada por script Playwright para ganhar velocidade e reprodutibilidade. A interpretação dos resultados (o que é bug e o que é comportamento esperado) é manual, a partir da documentação.
