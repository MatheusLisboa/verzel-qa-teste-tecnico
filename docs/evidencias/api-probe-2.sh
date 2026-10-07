B=https://verzel-store.qa-test-verzel-store.workers.dev/api
p(){ echo "### $1"; shift; curl -s -m 20 -w '\n[HTTP %{http_code}]\n' "$@"; echo; }
J='Content-Type: application/json'
C=$B/carrinho/calcular; P=$B/pedidos
cli='"cliente":{"nome":"Maria Silva","email":"maria@exemplo.com","cep":"01310-100"}'
it='"itens":[{"produtoId":"P005","quantidade":1}]'
p "frete gratis 210 + cupom -> 189 (CA08)" -X POST -H "$J" -d '{"itens":[{"produtoId":"P004","quantidade":1},{"produtoId":"P002","quantidade":1},{"produtoId":"P006","quantidade":1}],"cupom":"BEMVINDO10"}' $C
p "subtotal 219.8? 200.01-like: 189.9+29.9 sem cupom 219.8" -X POST -H "$J" -d '{"itens":[{"produtoId":"P003","quantidade":1},{"produtoId":"P006","quantidade":1}],"cupom":"BEMVINDO10"}' $C
p "subtotal 229.9 + cupom" -X POST -H "$J" -d '{"itens":[{"produtoId":"P007","quantidade":1}],"cupom":"BEMVINDO10"}' $C
p "arredondamento 59.9x3" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001","quantidade":3}],"cupom":"BEMVINDO10"}' $C
p "arredondamento 29.9x3 (89.7)" -X POST -H "$J" -d '{"itens":[{"produtoId":"P006","quantidade":3}],"cupom":"BEMVINDO10"}' $C
p "139.9+49.9+29.9=219.7 cupom" -X POST -H "$J" -d '{"itens":[{"produtoId":"P002","quantidade":1},{"produtoId":"P004","quantidade":1},{"produtoId":"P006","quantidade":1}],"cupom":"BEMVINDO10"}' $C
p "199.9 (P001+P002) sem cupom" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001","quantidade":1},{"produtoId":"P002","quantidade":1}]}' $C
p "pedido ok" -X POST -H "$J" -d "{$cli,$it,\"cupom\":\"BEMVINDO10\"}" $P
p "pedido sem cupom" -X POST -H "$J" -d "{$cli,$it}" $P
p "pedido cupom invalido" -X POST -H "$J" -d "{$cli,$it,\"cupom\":\"XPTO\"}" $P
p "pedido cupom expirado" -X POST -H "$J" -d "{$cli,$it,\"cupom\":\"VERAO2026\"}" $P
p "pedido qtd 6" -X POST -H "$J" -d "{$cli,\"itens\":[{\"produtoId\":\"P005\",\"quantidade\":6}]}" $P
p "pedido 200 exato" -X POST -H "$J" -d "{$cli,\"itens\":[{\"produtoId\":\"P005\",\"quantidade\":2}]}" $P
p "pedido sem cliente" -X POST -H "$J" -d "{$it}" $P
p "nome sem sobrenome" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria\",\"email\":\"m@e.com\",\"cep\":\"01310100\"},$it}" $P
p "nome vazio" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"\",\"email\":\"m@e.com\",\"cep\":\"01310100\"},$it}" $P
p "nome espacos" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"   \",\"email\":\"m@e.com\",\"cep\":\"01310100\"},$it}" $P
p "nome 'A B'" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"A B\",\"email\":\"m@e.com\",\"cep\":\"01310100\"},$it}" $P
p "nome '1 2'" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"1 2\",\"email\":\"m@e.com\",\"cep\":\"01310100\"},$it}" $P
p "nome com espaco duplo" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"  Maria   Silva  \",\"email\":\"m@e.com\",\"cep\":\"01310100\"},$it}" $P
p "email sem @" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria Silva\",\"email\":\"maria.com\",\"cep\":\"01310100\"},$it}" $P
p "email sem dominio" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria Silva\",\"email\":\"maria@\",\"cep\":\"01310100\"},$it}" $P
p "email a@b" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria Silva\",\"email\":\"a@b\",\"cep\":\"01310100\"},$it}" $P
p "email com espaco" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria Silva\",\"email\":\"a b@c.com\",\"cep\":\"01310100\"},$it}" $P
p "email 2 @" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria Silva\",\"email\":\"a@@c.com\",\"cep\":\"01310100\"},$it}" $P
p "email ponto final" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria Silva\",\"email\":\"a@c.\",\"cep\":\"01310100\"},$it}" $P
p "cep 7 digitos" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria Silva\",\"email\":\"m@e.com\",\"cep\":\"0131010\"},$it}" $P
p "cep 9 digitos" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria Silva\",\"email\":\"m@e.com\",\"cep\":\"013101000\"},$it}" $P
p "cep letras" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria Silva\",\"email\":\"m@e.com\",\"cep\":\"0131010a\"},$it}" $P
p "cep hifen errado" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria Silva\",\"email\":\"m@e.com\",\"cep\":\"013-10100\"},$it}" $P
p "cep numero" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria Silva\",\"email\":\"m@e.com\",\"cep\":1310100},$it}" $P
p "cep vazio" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"Maria Silva\",\"email\":\"m@e.com\",\"cep\":\"\"},$it}" $P
p "todos campos invalidos" -X POST -H "$J" -d "{\"cliente\":{\"nome\":\"\",\"email\":\"\",\"cep\":\"\"},$it}" $P
p "cliente string" -X POST -H "$J" -d "{\"cliente\":\"x\",$it}" $P
p "pedido itens vazio" -X POST -H "$J" -d "{$cli,\"itens\":[]}" $P
p "pedido dup" -X POST -H "$J" -d "{$cli,\"itens\":[{\"produtoId\":\"P005\",\"quantidade\":1},{\"produtoId\":\"P005\",\"quantidade\":1}]}" $P
p "pedido GET" $P
p "pedido json invalido" -X POST -H "$J" -d '{' $P
p "pedido numero formato (3x)" -X POST -H "$J" -d "{$cli,$it}" $P
p "pedido numero formato" -X POST -H "$J" -d "{$cli,$it}" $P
p "OPTIONS" -X OPTIONS -i $C
