# language: pt
@api
Funcionalidade: Contrato da API (/api)

  @CT-26 @automatizado
  Cenário: Cupom inválido ou expirado em POST /api/pedidos gera erro 422
    Quando envio um pedido válido com o cupom "XPTO"
    Então a resposta é 422 com o código "CUPOM_INVALIDO"
    Quando envio um pedido válido com o cupom "VERAO2026"
    Então a resposta é 422 com o código "CUPOM_EXPIRADO"

  @CT-27
  Esquema do Cenário: Erros padronizados
    Quando faço a requisição "<requisicao>"
    Então a resposta é <status> com o código "<codigo>"

    Exemplos:
      | requisicao                                       | status | codigo                 |
      | POST /api/carrinho/calcular com itens []         | 422    | ITENS_OBRIGATORIOS     |
      | POST /api/carrinho/calcular com itens ["P001"]   | 422    | ITEM_INVALIDO          |
      | POST /api/carrinho/calcular com produto P999     | 422    | PRODUTO_NAO_ENCONTRADO |
      | POST /api/carrinho/calcular com P001 duplicado   | 422    | ITEM_DUPLICADO         |
      | POST /api/carrinho/calcular com corpo "{itens"   | 400    | JSON_INVALIDO          |
      | GET /api/carrinho/calcular                       | 405    | METODO_NAO_PERMITIDO   |
      | GET /api/nao-existe                              | 404    | ROTA_NAO_ENCONTRADA    |

  @CT-28
  Cenário: Consulta de produtos
    Quando consulto GET /api/produtos
    Então recebo 200 com 8 produtos
    Quando consulto GET /api/produtos/P999
    Então recebo 404 com o código "PRODUTO_NAO_ENCONTRADO"
