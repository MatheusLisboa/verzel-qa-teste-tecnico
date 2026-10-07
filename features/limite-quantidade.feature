# language: pt
@limite
Funcionalidade: Limite de 5 unidades por produto (VZS-142, CA10)
  A regra vale para a interface e para a API.

  @CT-17
  Cenário: A vitrine bloqueia a 6ª unidade
    Dado que adicionei 5x "Camiseta Essencial" pela vitrine
    Então o botão "Adicionar ao carrinho" desse produto fica desabilitado
    E vejo "Limite de 5 unidades atingido."

  @CT-18
  Cenário: O carrinho bloqueia o botão "+" na 5ª unidade
    Dado que o carrinho contém 5x "Camiseta Essencial"
    Então o botão "Aumentar quantidade" está desabilitado
    E vejo "Limite de 5 unidades por produto."
    E o subtotal é "R$ 299,50"

  @CT-19 @automatizado @bug-BUG-02
  Esquema do Cenário: A API de cálculo valida a quantidade máxima
    Quando calculo o carrinho com <quantidade> unidades de "P001"
    Então a resposta é <status> com o código "<codigo>"

    Exemplos:
      | quantidade | status | codigo                     |
      | 5          | 200    |                            |
      | 6          | 422    | QUANTIDADE_MAXIMA_EXCEDIDA |
      | 99999      | 422    | QUANTIDADE_MAXIMA_EXCEDIDA |

  @CT-20 @automatizado @bug-BUG-03
  Cenário: A API de pedidos não confirma pedido com mais de 5 unidades
    Quando envio um pedido válido com 6 unidades de "P005"
    Então a resposta é 422 com o código "QUANTIDADE_MAXIMA_EXCEDIDA"

  @CT-21
  Esquema do Cenário: Quantidades inválidas são recusadas
    Quando calculo o carrinho com a quantidade <valor>
    Então a resposta é 422 com o código "QUANTIDADE_INVALIDA"

    Exemplos:
      | valor |
      | 0     |
      | -1    |
      | 1.5   |
      | "2"   |
      | null  |
