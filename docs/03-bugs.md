# 3. Bugs encontrados

Entrega **VZS-142 v2.3.0** · Ambiente: https://verzel-store.qa-test-verzel-store.workers.dev · Data: 06/10/2026

Nada abaixo consta em "Sobre este ambiente" da documentação (carrinho por aba, pedidos não armazenados, sem e-mail/cobrança, dados fixos, API sem estado). Foi conferido um a um.

| ID | Título | Severidade | Prioridade | Camada | CA |
|---|---|---|---|---|---|
| BUG-01 | Frete é cobrado quando o subtotal é exatamente R$ 200,00 | **Crítica** | Alta | API (UI reflete) | CA06 |
| BUG-02 | `POST /api/carrinho/calcular` aceita quantidade maior que 5 | **Alta** | Alta | API | CA10 |
| BUG-03 | `POST /api/pedidos` confirma pedido com quantidade maior que 5 | **Alta** | Alta | API | CA10 |
| BUG-04 | Cupom continua aplicado após remover o último item do carrinho | Baixa | Baixa | UI | CA05 / ambíguo |
| BUG-05 | Cupom só com espaços (e não-texto) tratado de forma inconsistente na API | Baixa | Baixa | API | CA02 |

---

## BUG-01: Frete é cobrado quando o subtotal é exatamente R$ 200,00

- **Severidade:** Crítica (cobra R$ 19,90 indevidos ao cliente, na regra central da entrega) · **Prioridade:** Alta
- **Critério violado:** CA06: "O frete é grátis para compras com subtotal a partir de R$ 200,00, **inclusive**."
- **Sintoma adicional:** `valorFaltanteFreteGratis` é 0 e a UI exibe "Faltam R$ 0,00 para o frete grátis.", ou seja, a loja admite que não falta nada e mesmo assim cobra frete.

**Passos (UI)**
1. Abrir a loja e adicionar 2x "Mochila Urbana 20L" (R$ 100,00 cada).
2. Abrir o carrinho.

**Resultado atual:** Subtotal R$ 200,00 · Frete **R$ 19,90** · Total **R$ 219,90** · "Faltam R$ 0,00 para o frete grátis."
**Resultado esperado:** Subtotal R$ 200,00 · Frete **Grátis** · Total **R$ 200,00** · sem aviso de valor faltante.

**Reprodução via API**
```bash
curl -s -X POST https://verzel-store.qa-test-verzel-store.workers.dev/api/carrinho/calcular \
  -H 'content-type: application/json' \
  -d '{"itens":[{"produtoId":"P005","quantidade":2}]}'
# => "subtotal":200,"frete":19.9,"freteGratis":false,"valorFaltanteFreteGratis":0,"total":219.9
```

**Variações confirmadas**
- 4x "Garrafa Térmica" (4 x 50,00 = 200,00): mesmo erro.
- Com cupom BEMVINDO10: subtotal 200 → desconto 20, frete 19,90, total 199,90 (esperado 180,00).
- `POST /api/pedidos` com subtotal 200,00 responde 201 com frete 19,90 (pedido confirmado com o valor errado).
- Subtotais de 219,70 e 219,80 (acima de 200) estão corretos; o erro é específico do valor exato (comparação `>` no lugar de `>=`, provável causa).

**Evidências:** `screenshots/E06-subtotal-200-cobra-frete.png`, `screenshots/E06b-subtotal-200-cupom.png`, `api-probe-1.saida.txt`, `api-probe-2.saida.txt`, `api-varredura-arredondamento.saida.txt`
**Teste automatizado:** AT-06, AT-09

---

## BUG-02: `POST /api/carrinho/calcular` aceita quantidade maior que 5

- **Severidade:** Alta · **Prioridade:** Alta
- **Critério violado:** CA10: "Cada produto pode ter no máximo 5 unidades por pedido. A regra vale para a interface **e para a API**." O código `QUANTIDADE_MAXIMA_EXCEDIDA` (422) está documentado, mas nunca é retornado.

**Passos**
```bash
curl -s -X POST https://verzel-store.qa-test-verzel-store.workers.dev/api/carrinho/calcular \
  -H 'content-type: application/json' \
  -d '{"itens":[{"produtoId":"P001","quantidade":6}]}'
```
**Resultado atual:** `200` com subtotal 359,40, frete grátis. Com `quantidade: 99999999999` também responde 200, total de `5989999999940.1`.
**Resultado esperado:** `422` com `{"erro":{"codigo":"QUANTIDADE_MAXIMA_EXCEDIDA","campo":"itens[0].quantidade", ...}}`.
**Impacto:** a regra só é garantida pelos botões da UI; qualquer cliente da API contorna o limite. Também na UI: gravando `verzel-store:itens` com `quantidade: 9` no `sessionStorage` e abrindo `/carrinho`, a loja exibe 9 unidades, item de R$ 539,10 e total de R$ 539,10, sem nenhuma recusa.
**Evidências:** `api-probe-1.saida.txt` (casos "qtd 6", "qtd 99999999999"), `screenshots/E12-sessionstorage-qtd-9-aceita.png` · **Teste:** AT-10

---

## BUG-03: `POST /api/pedidos` confirma pedido com quantidade maior que 5

- **Severidade:** Alta · **Prioridade:** Alta · **Critério violado:** CA10 (API)

**Passos**
```bash
curl -s -X POST https://verzel-store.qa-test-verzel-store.workers.dev/api/pedidos \
  -H 'content-type: application/json' \
  -d '{"cliente":{"nome":"Maria Silva","email":"maria@exemplo.com","cep":"01310-100"},"itens":[{"produtoId":"P005","quantidade":6}]}'
```
**Resultado atual:** `201` com número `VZ-xxxxxx`, subtotal 600,00, total 600,00.
**Resultado esperado:** `422 QUANTIDADE_MAXIMA_EXCEDIDA`; nenhum pedido confirmado.
**Observação:** é a mesma regra do BUG-02, mas em outro endpoint, e este **confirma o pedido**. Por isso foi aberto separado: a correção precisa cobrir os dois.
**Evidências:** `api-probe-2.saida.txt` (caso "pedido qtd 6") · **Teste:** AT-11

---

## BUG-04: Cupom continua aplicado após remover o último item do carrinho

- **Severidade:** Baixa · **Prioridade:** Baixa · **Camada:** UI
- **Observação:** a documentação não descreve o ciclo de vida do cupom ao esvaziar o carrinho (ver `ambiguidades.md`, A-03). Interpretação adotada: um carrinho vazio deveria voltar ao estado inicial, como já acontece em "Esvaziar carrinho".

**Passos**
1. Adicionar "Camiseta Essencial", aplicar `BEMVINDO10`.
2. No carrinho, clicar em **Remover** no único item (aparece "Seu carrinho está vazio").
3. Voltar à vitrine, adicionar "Boné Aba Curva" e abrir o carrinho.

**Resultado atual:** "Cupom BEMVINDO10 aplicado." já aparece, com desconto de R$ 4,99, sem o cliente ter digitado nada.
**Resultado esperado:** carrinho novo sem cupom (como após "Esvaziar carrinho", que limpa o cupom: comportamento inconsistente entre as duas ações).
**Evidência:** `screenshots/E05-cupom-persiste-apos-remover-itens.png`

---

## BUG-05: Cupom só com espaços (e valores não-texto) tratado de forma inconsistente na API

- **Severidade:** Baixa · **Prioridade:** Baixa · **Critério:** CA02 ("espaços no início e no fim são ignorados")

| Entrada `cupom` | Resposta de `/api/carrinho/calcular` |
|---|---|
| `""` | `cupom: null` (tratado como "sem cupom") |
| `"   "` | `cupom: {"codigo":"","aplicado":false,"mensagem":"Cupom inválido."}` |
| `123` (número) | `cupom: {"codigo":"123","aplicado":false,"mensagem":"Cupom inválido."}` |
| `null` | `cupom: null` |

**Resultado esperado:** se os espaços são ignorados (CA02), `"   "` deve se comportar como `""`, ou seja, sem cupom. Um número deveria ser rejeitado ou ignorado, e não convertido para texto.
**Impacto:** baixo: a UI já barra o campo vazio ("Informe um cupom."), então só afeta consumidores diretos da API.
**Evidência:** `api-probe-1.saida.txt` (casos "cupom vazio", "cupom so espacos", "cupom numero")

---

## Observações que NÃO foram abertas como bug

- Nome com espaços internos repetidos ("Maria   Silva") é aceito e devolvido sem normalizar; a documentação só exige "nome e sobrenome".
- `Content-Type` ausente é aceito pela API; a doc pede o cabeçalho, mas não define erro para a falta dele.
- Um achado inicial de "Cupom inválido." no lugar de "Cupom expirado." na UI foi **descartado**: era timing do meu script de exploração (espera fixa); o teste automatizado AT-03, com espera adequada, passa. Registrado aqui por transparência.
