# language: pt
@frete
Funcionalidade: Frete grátis (VZS-142, CA06 a CA09)
  O frete é grátis a partir de R$ 200,00 (inclusive), considerando o subtotal antes do cupom.
  Abaixo disso o frete é R$ 19,90.

  @CT-03 @automatizado
  Cenário: Abaixo de R$ 200,00 cobra frete fixo e informa quanto falta (CA07)
    Dado que o carrinho contém 1x "Camiseta Essencial" (R$ 59,90)
    Então o frete é "R$ 19,90"
    E vejo "Faltam R$ 140,10 para o frete grátis."
    E o total é "R$ 79,80"

  @CT-04 @api
  Cenário: Valor-limite inferior, R$ 199,80
    Dado que o carrinho contém 1x "Camiseta Essencial" e 1x "Calça Jeans Slim"
    Então o subtotal é "R$ 199,80"
    E o frete é "R$ 19,90"
    E vejo "Faltam R$ 0,20 para o frete grátis."

  @CT-05 @automatizado @bug-BUG-01
  Cenário: Valor-limite exato, R$ 200,00, tem frete grátis (CA06, "inclusive")
    Dado que o carrinho contém 2x "Mochila Urbana 20L" (R$ 100,00 cada)
    Então o subtotal é "R$ 200,00"
    E o frete é "Grátis"
    E o total é "R$ 200,00"
    E não vejo o aviso de valor faltante

  @CT-06
  Cenário: Acima de R$ 200,00 o frete é grátis
    Dado que o carrinho contém 1x "Jaqueta Corta-Vento" (R$ 229,90)
    Então o frete é "Grátis"
    E o total é "R$ 229,90"

  @CT-13 @automatizado
  Cenário: A regra considera o subtotal antes do cupom (CA08)
    Dado que o carrinho contém 1x "Tênis Casual Urbano" e 1x "Kit 3 Pares de Meias"
    Quando aplico o cupom "BEMVINDO10"
    Então o subtotal é "R$ 219,80"
    E o desconto é de "- R$ 21,98"
    E o frete é "Grátis"
    E o total é "R$ 197,82"

  @CT-14 @automatizado @bug-BUG-01
  Cenário: Subtotal de R$ 200,00 com cupom mantém o frete grátis (CA06 + CA08)
    Dado que o carrinho contém 2x "Mochila Urbana 20L"
    Quando aplico o cupom "BEMVINDO10"
    Então o desconto é de "- R$ 20,00"
    E o frete é "Grátis"
    E o total é "R$ 180,00"

  @CT-15 @automatizado
  Cenário: O desconto do cupom não incide sobre o frete (CA09)
    Dado que o carrinho contém 1x "Camiseta Essencial" (R$ 59,90)
    Quando aplico o cupom "BEMVINDO10"
    Então o desconto é de "- R$ 5,99"
    E o frete continua em "R$ 19,90"
    E o total é "R$ 73,81"

  @CT-16 @api
  Cenário: Todos os valores são arredondados em 2 casas (CA11)
    Dado qualquer combinação de produtos de 1 a 5 unidades, com e sem cupom
    Então subtotal, desconto, frete, total e valor faltante têm no máximo 2 casas decimais
    E o desconto é 10% do subtotal arredondado
