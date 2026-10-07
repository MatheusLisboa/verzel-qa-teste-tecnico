# 2. Execução dos testes

**Data:** 06/10/2026 · **Ambiente:** https://verzel-store.qa-test-verzel-store.workers.dev · **Entrega:** VZS-142 v2.3.0
**Navegador:** Chromium (Playwright) desktop 1280x900 e mobile 375x740 · **API:** Postman (validação manual), curl (scripts de sondagem) e Playwright `request` (automação)

Tipos de execução:
- **Manual/exploratória (UI):** sessão guiada por script de apoio ([`exploratorio-ui.mjs`](evidencias/exploratorio-ui.mjs), saída em [`exploratorio-ui.saida.txt`](evidencias/exploratorio-ui.saida.txt)) com capturas de tela.
- **Manual/exploratória (API):** ~90 requisições com `curl` ([`api-probe-1.sh`](evidencias/api-probe-1.sh), [`api-probe-2.sh`](evidencias/api-probe-2.sh)), com saídas guardadas. Os cenários de API e os bugs foram também **reproduzidos e validados manualmente no Postman**.
- **Automatizada:** 12 testes Playwright (`npm test`), focados nos critérios de maior risco.

Legenda: ✅ passou · ❌ falhou (bug) · ⚠️ passou com observação

| ID | Resultado | Como foi executado | Observado | Evidência / Bug |
|---|---|---|---|---|
| CT-01 | ✅ | UI | 8 produtos, preços batem com a documentação | E01-home.png |
| CT-02 | ✅ | UI | Contador sobe a cada adição | exploratorio-ui.saida.txt (E02) |
| CT-03 | ✅ | UI + API + auto | Camiseta 59,90: frete 19,90, "Faltam R$ 140,10", total 79,80 | E02-carrinho-abaixo-200.png |
| CT-04 | ✅ | API | 199,80: frete 19,90 e falta 0,20; 199,60: falta 0,40 | api-probe-1/2 |
| CT-05 | ❌ | UI + API + auto | Subtotal = 200,00 cobra frete 19,90, total 219,90; aviso "Faltam R$ 0,00 para o frete grátis" | E06-subtotal-200-cobra-frete.png · **BUG-01** |
| CT-06 | ✅ | UI | 229,90: frete "Grátis" | exploratorio-ui.saida.txt (E04, E07b) |
| CT-07 | ✅ | UI + API + auto | 59,90 → desconto 5,99, total 73,81; exemplo da doc bate (215,73) | E03d-cupom-aplicado.png |
| CT-08 | ✅ | UI + API + auto | `bemvindo10`, `  bemvindo10  ` aceitos | E03d |
| CT-09 | ✅ | UI + API + auto | "Cupom inválido.", sem desconto | E03b-cupom-invalido.png |
| CT-10 | ✅ | UI + API + auto | "Cupom expirado." (também em minúsculas) | AT-03 |
| CT-11 | ✅ | UI | "Informe um cupom." | exploratorio-ui.saida.txt (E03a) |
| CT-12 | ✅ | UI | Com cupom aplicado o campo some; "Remover cupom" restaura | exploratorio-ui.saida.txt (E03d-E03f) |
| CT-13 | ✅ | UI + API + auto | 219,80 com cupom: desconto 21,98, frete grátis, total 197,82 | E07c-frete-gratis-com-cupom.png |
| CT-14 | ❌ | UI + API + auto | 200,00 + cupom: frete 19,90, total 199,90 (esperado 180,00) | E06b-subtotal-200-cupom.png · **BUG-01** |
| CT-15 | ✅ | UI + auto | Desconto só sobre produtos | AT-01 |
| CT-16 | ✅ | API | 304 cálculos (todos os produtos 1-5 un. e pares, com/sem cupom): nenhuma divergência de arredondamento além do BUG-01 | api-varredura-arredondamento.saida.txt |
| CT-17 | ✅ | UI | Botão desabilitado e "Limite de 5 unidades atingido." | exploratorio-ui.saida.txt (E04) |
| CT-18 | ✅ | UI | "+" desabilitado em 5, mensagem exibida, subtotal 299,50 | E04-limite-5-unidades.png |
| CT-19 | ❌ | API + auto | 5 ok (200). **6 → 200** e 99.999.999.999 → 200 com total de R$ 5,98 trilhões; esperado 422 `QUANTIDADE_MAXIMA_EXCEDIDA` | api-probe-1.saida.txt · **BUG-02** |
| CT-20 | ❌ | API + auto | `POST /api/pedidos` com 6 un. responde **201** e gera pedido | api-probe-2.saida.txt · **BUG-03** |
| CT-21 | ✅ | API | 0, -1, 1.5, "2", null, ausente → 422 `QUANTIDADE_INVALIDA` com `campo` | api-probe-1.saida.txt |
| CT-22 | ✅ | UI | Qtd 1→2→4→5 recalcula subtotal/desconto/frete; frete vira "Grátis" em 239,60 | exploratorio-ui.saida.txt (E04) |
| CT-23 | ⚠️ | UI | "Esvaziar carrinho" limpa o cupom; remover o **último item** pelo "Remover" mantém o cupom, e ele reaparece aplicado num carrinho novo | E05-cupom-persiste-apos-remover-itens.png · **BUG-04** |
| CT-24 | ✅ | UI | Mensagens corretas para vazio / sem sobrenome / e-mail / CEP | E08b-checkout-vazio.png |
| CT-25 | ✅ | UI + auto | Pedido `VZ-493457` (formato ok), resumo coerente, "Obrigado, Maria." | E08d-confirmacao.png |
| CT-26 | ✅ | API + auto | 422 `CUPOM_INVALIDO` / `CUPOM_EXPIRADO` | api-probe-2.saida.txt |
| CT-27 | ✅ | API | 400/404/405/422 com códigos e `campo` conforme a tabela da doc | api-probe-1.saida.txt |
| CT-28 | ✅ | API | 200 com 8 produtos; 404 `PRODUTO_NAO_ENCONTRADO`; id em minúsculas = 404 | api-probe-1.saida.txt |
| CT-29 | ✅ | UI | Recarregar mantém o carrinho; outro contexto começa vazio (esperado pela doc, não é bug) | exploratorio-ui.saida.txt (E09) |
| CT-30 | ✅ | UI | `/checkout` vazio → `/carrinho`; rota inválida → "Página não encontrada"; `/pedido-confirmado` persiste na sessão | exploratorio-ui.saida.txt (E08) |
| CT-31 | ✅ | UI | Sem rolagem horizontal em 375 px | E10a / E10b |
| CT-32 | ⚠️ | API | `""` e `null` → sem cupom; `"   "` → `cupom.codigo:""` "Cupom inválido."; `123` → aceito como `"123"` | api-probe-1.saida.txt · **BUG-05** |
| CT-33 | ✅ | API | CEP com/sem hífen → 201 e normalizado; `a@b`, `a@@c.com`, `maria@` → 422 | api-probe-2.saida.txt |

## Resumo

| Resultado | Qtd |
|---|---|
| ✅ Passou | 27 |
| ⚠️ Passou com observação | 2 |
| ❌ Falhou | 4 |
| **Total** | **33** |

**Suíte automatizada:** 12 testes, 100% verde. Os 4 testes que cobrem bugs abertos (BUG-01, 02 e 03) usam `test.fail()`: eles "passam" enquanto o bug existe e **falham sozinhos assim que o bug for corrigido**, avisando para remover a marcação.

**Não coberto (limitações):** acessibilidade (leitor de tela / teclado) e outros navegadores além do Chromium; segurança, carga e estresse por estarem fora do escopo.
