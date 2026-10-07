# 1. Cenários de teste

Derivados da documentação da entrega **VZS-142 v2.3.0** (`/documentacao`): história, critérios de aceite CA01-CA11, regras de cálculo, contrato da API e códigos de erro.

Os cenários estão escritos em **Gherkin (pt-BR)** em [`/features`](../features). Esta tabela é o índice: cada `CT-xx` é uma tag nos arquivos `.feature`.

**Técnicas usadas:** partição de equivalência (cupom válido / inexistente / expirado / vazio), análise de valor-limite (subtotal 199,80 / 200,00 / acima; quantidade 0, 1, 5, 6), tabela de decisão (cupom × faixa de frete) e teste exploratório (sessão de carrinho, navegação, mobile, entradas atípicas na API).

**Prioridade:** A = regra central da entrega (dinheiro / critério de aceite); M = importante; B = complementar.

| ID | Cenário | CA / regra | Canal | Prio | Feature | Automação |
|---|---|---|---|---|---|---|
| CT-01 | Vitrine lista os 8 produtos com preços corretos | Dados de teste | UI | M | carrinho-e-checkout | - |
| CT-02 | Adicionar produto atualiza contador do carrinho | - | UI | B | carrinho-e-checkout | - |
| CT-03 | Abaixo de R$ 200: frete 19,90 e "faltam" | CA07 | UI/API | A | frete | AT-04 |
| CT-04 | Valor-limite inferior R$ 199,80 | CA06/CA07 | API | A | frete | - |
| CT-05 | Valor-limite exato R$ 200,00 = frete grátis | CA06 | UI/API | A | frete | AT-06, AT-09 |
| CT-06 | Acima de R$ 200: frete grátis | CA06 | UI | A | frete | - |
| CT-07 | BEMVINDO10 aplica 10% | CA01 | UI/API | A | cupom | AT-01, AT-08 |
| CT-08 | Cupom ignora caixa e espaços nas pontas | CA02 | UI/API | A | cupom | AT-01 |
| CT-09 | Cupom inexistente: "Cupom inválido." | CA03 | UI/API | A | cupom | AT-02 |
| CT-10 | Cupom expirado: "Cupom expirado." | CA04 | UI/API | A | cupom | AT-03 |
| CT-11 | Aplicar com campo vazio | - | UI | M | cupom | - |
| CT-12 | Um cupom por vez / remover cupom | CA05 | UI | A | cupom | - |
| CT-13 | Frete grátis considera subtotal antes do cupom | CA08 | UI/API | A | frete | AT-05 |
| CT-14 | Subtotal 200,00 + cupom mantém frete grátis | CA06+CA08 | UI/API | A | frete | AT-09 |
| CT-15 | Desconto não incide no frete | CA09 | UI | A | frete | AT-01 |
| CT-16 | Arredondamento em 2 casas | CA11 | API | M | frete | - |
| CT-17 | Vitrine bloqueia a 6ª unidade | CA10 | UI | A | limite-quantidade | - |
| CT-18 | Carrinho bloqueia "+" na 5ª unidade | CA10 | UI | A | limite-quantidade | - |
| CT-19 | API de cálculo: 5 ok, 6 rejeitado | CA10 | API | A | limite-quantidade | AT-10 |
| CT-20 | API de pedidos: 6 unidades rejeitado | CA10 | API | A | limite-quantidade | AT-11 |
| CT-21 | Quantidades inválidas (0, -1, 1.5, "2", null) | Erros | API | M | limite-quantidade | - |
| CT-22 | Alterar quantidade recalcula mantendo cupom | CA01 | UI | M | carrinho-e-checkout | - |
| CT-23 | Esvaziar carrinho descarta o cupom | (ambíguo) | UI | B | carrinho-e-checkout | - |
| CT-24 | Validações do formulário de entrega | Regras existentes | UI | M | carrinho-e-checkout | - |
| CT-25 | Fluxo completo até confirmação | História | UI | A | carrinho-e-checkout | AT-07 |
| CT-26 | Pedido com cupom inválido/expirado: 422 | Erros | API | A | api | AT-12 |
| CT-27 | Erros padronizados (400/404/405/422) | Erros | API | M | api | - |
| CT-28 | Consulta de produtos | API | API | M | api | - |
| CT-29 | Carrinho por aba (esperado pela doc) | Sobre o ambiente | UI | B | carrinho-e-checkout | - |
| CT-30 | Rotas: 404, checkout vazio, confirmação | - | UI | B | carrinho-e-checkout | - |
| CT-31 | Layout mobile 375 px | - | UI | B | carrinho-e-checkout | - |
| CT-32 | Entradas atípicas de cupom na API | CA02 | API | B | cupom | - |
| CT-33 | CEP com/sem hífen; validação de e-mail | Regras existentes | API | M | carrinho-e-checkout | - |

**Legenda da coluna Automação:** `AT-xx` = teste Playwright (ver `tests/`); `-` = cenário coberto na execução manual/exploratória (ver [`02-execucao.md`](02-execucao.md)). Foram automatizados os cenários de maior risco: regras de dinheiro, limites e o fluxo de compra.

**Fora do escopo (conforme o enunciado):** carga, estresse e segurança. Também fora: login, cadastro, pagamento online e consulta de pedidos (doc, "Sobre este ambiente").
