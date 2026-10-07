# language: pt
@cupom
Funcionalidade: Cupom de desconto (VZS-142, CA01 a CA05)
  Como cliente da Verzel Store
  Quero aplicar um cupom de desconto no carrinho
  Para pagar menos nas minhas compras

  Contexto:
    Dado que o carrinho contém 1x "Mochila Urbana 20L" (R$ 100,00)

  @CT-07 @automatizado
  Cenário: BEMVINDO10 aplica 10% sobre o subtotal dos produtos
    Quando aplico o cupom "BEMVINDO10"
    Então o desconto é de "- R$ 10,00"
    E o frete continua em "R$ 19,90"
    E o total é "R$ 109,90"

  @CT-08 @automatizado
  Esquema do Cenário: O código do cupom ignora maiúsculas, minúsculas e espaços nas pontas
    Quando aplico o cupom "<digitado>"
    Então o cupom "BEMVINDO10" aparece como aplicado
    E o desconto é de "- R$ 10,00"

    Exemplos:
      | digitado        |
      | bemvindo10      |
      | BemVindo10      |
      |   BEMVINDO10    |
      |   bemvindo10    |

  @CT-09 @automatizado
  Cenário: Cupom inexistente é recusado
    Quando aplico o cupom "XPTO"
    Então vejo a mensagem "Cupom inválido."
    E nenhum desconto é aplicado
    E o total é "R$ 119,90"

  @CT-10 @automatizado
  Cenário: Cupom fora da validade é recusado
    Quando aplico o cupom "VERAO2026"
    Então vejo a mensagem "Cupom expirado."
    E nenhum desconto é aplicado

  @CT-11
  Cenário: Aplicar cupom com o campo vazio
    Quando aplico o cupom ""
    Então vejo a mensagem "Informe um cupom."

  @CT-12
  Cenário: Só um cupom por vez; para trocar é preciso remover o atual
    Dado que o cupom "BEMVINDO10" está aplicado
    Então o campo para digitar outro cupom não é exibido
    Quando removo o cupom
    Então o desconto volta a "R$ 0,00"
    E o campo de cupom é exibido novamente

  @CT-32 @api
  Esquema do Cenário: Entradas atípicas de cupom na API de cálculo
    Quando calculo o carrinho enviando o cupom <valor>
    Então a resposta é 200
    E a regra de CA02 (espaços ignorados) é respeitada

    Exemplos:
      | valor   |
      | ""      |
      | "   "   |
      | 123     |
      | null    |
