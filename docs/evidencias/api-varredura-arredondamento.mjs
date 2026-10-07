const B='https://verzel-store.qa-test-verzel-store.workers.dev/api/carrinho/calcular';
const preco={P001:5990,P002:13990,P003:18990,P004:4990,P005:10000,P006:2990,P007:22990,P008:5000};
const ids=Object.keys(preco);let n=0,bad=0;
const post=async(itens,cupom)=>(await fetch(B,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({itens,cupom})})).json();
const cases=[];
for(const a of ids)for(let q=1;q<=5;q++)cases.push([{produtoId:a,quantidade:q}]);
for(let i=0;i<ids.length;i++)for(let j=i+1;j<ids.length;j++)for(const [qa,qb] of [[1,1],[2,3],[3,5],[5,4]])cases.push([{produtoId:ids[i],quantidade:qa},{produtoId:ids[j],quantidade:qb}]);
for(const itens of cases){for(const cupom of [undefined,'BEMVINDO10']){
 const r=await post(itens,cupom);n++;
 const sub=itens.reduce((s,i)=>s+preco[i.produtoId]*i.quantidade,0);
 const desc=cupom?Math.round(sub*0.1):0;
 const frete=sub>=20000?0:1990;
 const tot=sub-desc+frete;
 const falt=Math.max(0,20000-sub);
 const exp={subtotal:sub/100,desconto:desc/100,frete:frete/100,total:tot/100,valorFaltanteFreteGratis:falt/100};
 for(const k in exp){ if(Math.abs(r[k]-exp[k])>1e-9){bad++;console.log('DIVERGE',JSON.stringify(itens),cupom,k,'obtido',r[k],'esperado',exp[k]);break;}}
}}
console.log(`${n} calculos, ${bad} divergencias`);
