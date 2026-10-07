# Teste técnico QA Júnior - Verzel

Validação da entrega **VZS-142 v2.3.0: cupom de desconto e frete grátis** da Verzel Store.

- Loja: https://verzel-store.qa-test-verzel-store.workers.dev/
- Documentação: https://verzel-store.qa-test-verzel-store.workers.dev/documentacao
- API: https://verzel-store.qa-test-verzel-store.workers.dev/api

## Resultado em uma olhada

**5 bugs encontrados** em 33 cenários (27 passaram, 2 com observação, 4 falharam):

| ID | Bug | Severidade |
|---|---|---|
| BUG-01 | Frete é cobrado com subtotal **exatamente** R$ 200,00 (CA06 diz "inclusive") | Crítica |
| BUG-02 | `POST /api/carrinho/calcular` aceita quantidade > 5 (CA10) | Alta |
| BUG-03 | `POST /api/pedidos` confirma pedido com quantidade > 5 (CA10) | Alta |
| BUG-04 | Cupom continua aplicado após remover o último item | Baixa |
| BUG-05 | Cupom só com espaços/não-texto tratado de forma inconsistente na API | Baixa |

Detalhes, passos de reprodução e evidências em [`docs/03-bugs.md`](docs/03-bugs.md).

## Onde encontrar cada entrega

| Item do enunciado | Onde está |
|---|---|
| Cenários de teste (Gherkin é diferencial) | [`docs/01-cenarios.md`](docs/01-cenarios.md) (índice) e [`features/*.feature`](features) (Gherkin pt-BR) |
| Execução dos testes, com resultado de cada cenário | [`docs/02-execucao.md`](docs/02-execucao.md) |
| Report dos bugs | [`docs/03-bugs.md`](docs/03-bugs.md) |
| Documento de evidências | [`docs/04-evidencias.md`](docs/04-evidencias.md) e [`docs/evidencias/`](docs/evidencias) |
| Automação Playwright (12 testes) | [`tests/`](tests) |
| Ambiguidades e interpretações | [`docs/05-ambiguidades.md`](docs/05-ambiguidades.md) |
| Uso de IA | [`docs/06-uso-de-ia.md`](docs/06-uso-de-ia.md) |

## Como foi testado

- **UI:** exploração guiada no Chromium (Playwright) com capturas de tela.
- **API:** validação manual no **Postman**, mais scripts `curl` que guardam as saídas em `docs/evidencias/`.
- **Automação:** 12 testes Playwright (UI e API).

## Como rodar a automação

Requisitos: Node.js 18+.

```bash
npm install
npx playwright install chromium

npm test              # tudo (UI + API)
npm run test:ui       # só interface
npm run test:api      # só API
npm run report        # abre o relatório HTML da última execução
```

Para apontar para outro ambiente: `BASE_URL=https://... npm test`.

### O que a suíte cobre

12 testes, escolhidos pelo risco (regras de dinheiro e limites). Os demais cenários estão em Gherkin e foram executados na exploração manual (`docs/02-execucao.md`).

| Arquivo | Testes |
|---|---|
| `tests/ui/loja.spec.ts` | AT-01 a AT-07: cupom (aplicado, inválido, expirado), frete abaixo de 200, frete grátis com cupom, limite de 200,00 exato (BUG-01), fluxo completo até o pedido |
| `tests/api/api.spec.ts` | AT-08 a AT-12: exemplo da documentação, limite de 200,00 (BUG-01), quantidade > 5 em cálculo (BUG-02) e em pedido (BUG-03), cupom inválido/expirado em pedido |
| `tests/support/loja.ts` | Helpers (montar carrinho, aplicar cupom, formatar moeda) |

### Testes de bug (`@bug`)

Os 4 testes que cobrem bugs abertos (AT-06, AT-09, AT-10, AT-11) assertam o **comportamento correto** e usam `test.fail()`. Resultado:

- enquanto o bug existe, o teste aparece como esperado-falha e a suíte fica **verde**;
- quando o bug for corrigido, o teste **passa e o Playwright acusa erro** ("expected to fail, but passed"), sinal para remover o `test.fail()`.

Para ver só esses testes: `npx playwright test --grep @bug`.

## Estrutura

```
docs/                 documentos do teste (01 a 06) e evidências
  evidencias/           capturas de tela, scripts de sondagem e saídas
features/             cenários em Gherkin (pt-BR)
tests/ui, tests/api   automação Playwright
playwright.config.ts  projetos "ui" e "api"
```

## Notas

- O ambiente é compartilhado entre candidatos; os testes não dependem de estado (cada contexto de navegador tem o próprio carrinho; a API não guarda nada) e não fazem carga nem segurança, conforme o enunciado.
- Comportamentos listados em "Sobre este ambiente" da documentação (carrinho por aba, pedidos não armazenados etc.) não foram reportados como bug.
