B=https://verzel-store.qa-test-verzel-store.workers.dev/api
p(){ echo "### $1"; shift; curl -s -m 20 -w '\n[HTTP %{http_code}]\n' "$@"; echo; }
J='Content-Type: application/json'
C=$B/carrinho/calcular
p "produtos" $B/produtos
p "produto P001" $B/produtos/P001
p "produto inexistente" $B/produtos/P999
p "produto minusculo" $B/produtos/p001
p "rota inexistente" $B/xyz
p "POST produtos" -X POST $B/produtos
p "GET calcular" $C
p "ok BEMVINDO10 239.70" -X POST -H "$J" -d '{"itens":[{"produtoId":"P002","quantidade":1},{"produtoId":"P004","quantidade":2}],"cupom":"BEMVINDO10"}' $C
p "limite 200 exato (P005x2)" -X POST -H "$J" -d '{"itens":[{"produtoId":"P005","quantidade":2}]}' $C
p "199.99? P008x4=200" -X POST -H "$J" -d '{"itens":[{"produtoId":"P008","quantidade":4}]}' $C
p "199.80 P004x4 (49.9*4)" -X POST -H "$J" -d '{"itens":[{"produtoId":"P004","quantidade":4}]}' $C
p "199.90 P003+P008? 189.9+... P006x?"  -X POST -H "$J" -d '{"itens":[{"produtoId":"P003","quantidade":1},{"produtoId":"P006","quantidade":1}]}' $C
p "200 exato com cupom (P005x2 + BEMVINDO10)" -X POST -H "$J" -d '{"itens":[{"produtoId":"P005","quantidade":2}],"cupom":"BEMVINDO10"}' $C
p "cupom minusculo+espacos" -X POST -H "$J" -d '{"itens":[{"produtoId":"P005","quantidade":1}],"cupom":"  bemvindo10 "}' $C
p "cupom inexistente" -X POST -H "$J" -d '{"itens":[{"produtoId":"P005","quantidade":1}],"cupom":"XPTO"}' $C
p "cupom expirado" -X POST -H "$J" -d '{"itens":[{"produtoId":"P005","quantidade":1}],"cupom":"VERAO2026"}' $C
p "cupom expirado minusculo" -X POST -H "$J" -d '{"itens":[{"produtoId":"P005","quantidade":1}],"cupom":"verao2026"}' $C
p "cupom vazio" -X POST -H "$J" -d '{"itens":[{"produtoId":"P005","quantidade":1}],"cupom":""}' $C
p "cupom so espacos" -X POST -H "$J" -d '{"itens":[{"produtoId":"P005","quantidade":1}],"cupom":"   "}' $C
p "cupom null" -X POST -H "$J" -d '{"itens":[{"produtoId":"P005","quantidade":1}],"cupom":null}' $C
p "cupom numero" -X POST -H "$J" -d '{"itens":[{"produtoId":"P005","quantidade":1}],"cupom":123}' $C
p "qtd 5" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001","quantidade":5}]}' $C
p "qtd 6" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001","quantidade":6}]}' $C
p "qtd 0" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001","quantidade":0}]}' $C
p "qtd -1" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001","quantidade":-1}]}' $C
p "qtd 1.5" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001","quantidade":1.5}]}' $C
p "qtd string" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001","quantidade":"2"}]}' $C
p "qtd null" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001","quantidade":null}]}' $C
p "qtd ausente" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001"}]}' $C
p "qtd 1e0" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001","quantidade":1e0}]}' $C
p "qtd 99999999999" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001","quantidade":99999999999}]}' $C
p "itens vazio" -X POST -H "$J" -d '{"itens":[]}' $C
p "itens ausente" -X POST -H "$J" -d '{}' $C
p "itens nao array" -X POST -H "$J" -d '{"itens":"x"}' $C
p "item nao objeto" -X POST -H "$J" -d '{"itens":["P001"]}' $C
p "item null" -X POST -H "$J" -d '{"itens":[null]}' $C
p "produto inexistente" -X POST -H "$J" -d '{"itens":[{"produtoId":"P999","quantidade":1}]}' $C
p "produto minusculo" -X POST -H "$J" -d '{"itens":[{"produtoId":"p001","quantidade":1}]}' $C
p "duplicado" -X POST -H "$J" -d '{"itens":[{"produtoId":"P001","quantidade":1},{"produtoId":"P001","quantidade":1}]}' $C
p "json invalido" -X POST -H "$J" -d '{itens' $C
p "json array" -X POST -H "$J" -d '[]' $C
p "json null" -X POST -H "$J" -d 'null' $C
p "corpo vazio" -X POST -H "$J" $C
p "sem content-type" -X POST -d '{"itens":[{"produtoId":"P001","quantidade":1}]}' $C
