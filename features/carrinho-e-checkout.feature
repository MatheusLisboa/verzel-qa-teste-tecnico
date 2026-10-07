# language: pt
@carrinho @checkout
Funcionalidade: Vitrine, carrinho e checkout (regressão do fluxo existente)

  @CT-01
  Cenário: A vitrine lista os 8 produtos com os preços da documentação
    Quando acesso a página inicial
    Então vejo 8 produtos com os preços de P001 a P008

  @CT-02
  Cenário: Adicionar produto atualiza o contador do carrinho
    Quando adiciono "Camiseta Essencial" ao carrinho
    Então o contador do carrinho mostra 1

  @CT-22
  Cenário: Alterar a quantidade recalcula o resumo mantendo o cupom
    Dado que o carrinho contém 1x "Camiseta Essencial" com o cupom "BEMVINDO10"
    Quando aumento a quantidade para 4
    Então o subtotal é "R$ 239,60"
    E o desconto é de "- R$ 23,96"
    E o frete é "Grátis"

  @CT-23 @bug-BUG-04
  Cenário: Esvaziar o carrinho também descarta o cupom
    Dado que o carrinho contém 1x "Camiseta Essencial" com o cupom "BEMVINDO10"
    Quando removo o único item pelo botão "Remover"
    E adiciono "Boné Aba Curva" ao carrinho
    Então nenhum cupom está aplicado

  @CT-24
  Cenário: Validações do formulário de entrega
    Dado que estou no checkout com itens no carrinho
    Quando confirmo o pedido com os campos vazios
    Então vejo "Informe o nome completo.", "Informe o e-mail." e "Informe o CEP."
    Quando preencho nome "Maria", e-mail "maria@exemplo" e CEP "1234567"
    Então vejo "Informe nome e sobrenome.", "Informe um e-mail válido." e "Informe um CEP com 8 dígitos."

  @CT-25 @automatizado
  Cenário: Fluxo completo até a confirmação do pedido
    Dado que o carrinho contém 1x "Mochila Urbana 20L" com o cupom "bemvindo10"
    Quando preencho nome "Maria da Silva", e-mail "maria@exemplo.com" e CEP "01310-100"
    E confirmo o pedido
    Então vejo o número do pedido no formato "VZ-000000"
    E o resumo mostra desconto "- R$ 10,00" e total "R$ 109,90"

  @CT-29
  Cenário: O carrinho vive só na aba (comportamento esperado pela documentação)
    Dado que o carrinho contém 1 item
    Quando recarrego a página
    Então o item continua no carrinho
    Quando abro a loja em outro navegador ou janela anônima
    Então o carrinho está vazio

  @CT-30
  Cenário: Navegação e rotas
    Então "/checkout" com carrinho vazio redireciona para "/carrinho"
    E uma rota inexistente mostra "Página não encontrada"
    E recarregar "/pedido-confirmado" mantém o resumo do último pedido

  @CT-31
  Cenário: Layout em tela de celular (375 px)
    Quando acesso a vitrine e o carrinho com 375 px de largura
    Então não há rolagem horizontal na página

  @CT-33 @api
  Cenário: CEP aceita 8 dígitos com ou sem hífen
    Quando envio pedidos com CEP "01310100" e "01310-100"
    Então ambos retornam 201 e o CEP vem normalizado sem hífen
