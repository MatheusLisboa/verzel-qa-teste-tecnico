# 5. Ambiguidades e interpretações adotadas

Conforme o enunciado, onde a documentação não deixou claro registrei a interpretação e segui em frente.

| ID | Ponto ambíguo | Interpretação adotada | Impacto |
|---|---|---|---|
| A-01 | CA06 diz "a partir de R$ 200,00, inclusive" mas CA08 fala em "subtotal antes do desconto". O subtotal de 200 com cupom deve ter frete grátis? | Sim: a regra olha só o subtotal bruto; com cupom, subtotal 200,00 também tem frete grátis (total 180,00). | Base do CT-14 / BUG-01 |
| A-02 | O que significa `cupom: ""` ou só espaços? CA02 diz que espaços nas pontas são ignorados. | Cupom vazio ou só espaços = "sem cupom", sem erro. | BUG-05 (baixa) |
| A-03 | O cupom deve ser descartado quando o carrinho fica vazio? | Sim: carrinho vazio = estado inicial, como "Esvaziar carrinho" já faz. Se o time decidir que o cupom persiste de propósito, BUG-04 vira "melhoria". | BUG-04 (baixa) |
| A-04 | "Faltante para frete grátis" mostra "R$ 0,00" quando o subtotal é 200,00? | A fórmula da doc (200 menos subtotal, mínimo 0) dá 0, correto. O aviso só deve sumir porque o frete passa a ser grátis. | Parte do BUG-01 |
| A-05 | CA10 diz "por pedido"; o limite vale por produto ou pelo total de unidades? | Por produto (a UI e a doc dizem "por produto"); o total de unidades do carrinho não tem limite. | CT-17 a CT-20 |
| A-06 | Em `/api/carrinho/calcular` cupom inválido é 200 com mensagem; em `/api/pedidos` é 422. | Intencional: documentado em cada endpoint. Testado como está. | CT-26 |
| A-07 | O desconto é calculado sobre o subtotal inteiro ou item a item? Isso muda o arredondamento. | Sobre o subtotal, como diz CA01 ("sobre o subtotal dos produtos"). A varredura confirma. | CT-16 |
| A-08 | Comportamento do `Content-Type` ausente e de nomes com espaços internos. | Não definidos na doc; registrados como observação, sem abrir bug. | - |
