import { chromium } from '/Users/matheus/Code/verzel/node_modules/playwright/index.mjs';
const B='https://verzel-store.qa-test-verzel-store.workers.dev';
const OUT='/Users/matheus/Code/verzel/docs/evidencias/screenshots/';
const br=await chromium.launch();
const log=(...a)=>console.log(...a);
async function ctx(opts={}){const c=await br.newContext({viewport:{width:1280,height:900},locale:'pt-BR',...opts});const p=await c.newPage();p.on('console',m=>{if(m.type()==='error')log('  [console.error]',m.text())});p.on('pageerror',e=>log('  [pageerror]',e.message));return p}
const txt=async(p,s)=>(await p.locator(s).first().innerText().catch(()=>'<n/a>')).replace(/\s+/g,' ');
const res=async p=>{const o={};for(const k of ['subtotal','desconto','frete','total'])o[k]=await txt(p,`[data-valor=${k}]`);o.aviso=await txt(p,'.aviso-frete');o.contador=await txt(p,'.contador-carrinho');return JSON.stringify(o)};
const add=async(p,nome,n=1)=>{const card=p.locator('li.produto',{hasText:nome});for(let i=0;i<n;i++){const b=card.getByRole('button',{name:'Adicionar ao carrinho'});if(await b.isDisabled())break;await b.click();}};
const settle=p=>p.waitForTimeout(700);

// E1 home
let p=await ctx();await p.goto(B);await p.screenshot({path:OUT+'E01-home.png',fullPage:true});
log('E01 title',await p.title(),'| produtos:',await p.locator('li.produto').count());
log('E01 precos',(await p.locator('.produto-preco').allInnerTexts()).join(' | '));
// E2 cart basic
await add(p,'Camiseta Essencial');await p.getByRole('link',{name:/Carrinho/}).click();await settle(p);
log('E02 camiseta x1',await res(p));await p.screenshot({path:OUT+'E02-carrinho-abaixo-200.png',fullPage:true});
// E3 coupons
const cupom=async(code)=>{await p.locator('#campo-cupom').fill(code);await p.getByRole('button',{name:'Aplicar cupom'}).click();await settle(p);return await txt(p,'#mensagem-cupom')+' || '+await txt(p,'.cupom-aplicado')+' || '+await res(p)};
log('E03a vazio',await cupom(''));
log('E03b inexistente',await cupom('XPTO'));await p.screenshot({path:OUT+'E03b-cupom-invalido.png',fullPage:true});
log('E03c expirado',await cupom('VERAO2026'));await p.screenshot({path:OUT+'E03c-cupom-expirado.png',fullPage:true});
log('E03d minusc+espacos',await cupom('  bemvindo10  '));await p.screenshot({path:OUT+'E03d-cupom-aplicado.png',fullPage:true});
log('E03e form de cupom visivel com cupom aplicado?',await p.locator('#campo-cupom').count());
await p.getByRole('button',{name:'Remover cupom'}).click();await settle(p);log('E03f removido',await res(p));
log('E03g troca de cupom (VERAO apos BEMVINDO)',await cupom('BEMVINDO10'));
await p.getByRole('button',{name:'Remover cupom'}).click();await settle(p);
log('E03h cupom 10%/arredondamento 59.90',await cupom('BEMVINDO10'));
// quantity +
const mais=p.getByRole('button',{name:/Aumentar quantidade/});
await mais.click();await settle(p);log('E04 qtd2 com cupom',await res(p));
await mais.click();await mais.click();await settle(p);log('E04 qtd4',await res(p));
await mais.click();await settle(p);log('E04 qtd5',await res(p),'| limite msg:',await txt(p,'.item-limite'),'| + disabled:',await mais.isDisabled());
await p.screenshot({path:OUT+'E04-limite-5-unidades.png',fullPage:true});
const menos=p.getByRole('button',{name:/Diminuir quantidade/});
await menos.click();await settle(p);log('E04 volta qtd4',await res(p));
// E5 remove all items -> coupon persists?
await p.getByRole('button',{name:/Remover Camiseta/}).click();await settle(p);
log('E05 vazio h1',await txt(p,'h1'));
await p.goto(B);await add(p,'Boné Aba Curva');await p.getByRole('link',{name:/Carrinho/}).click();await settle(p);
log('E05 novo item apos esvaziar (cupom persiste?)',await txt(p,'.cupom-aplicado'),'||',await res(p));
await p.screenshot({path:OUT+'E05-cupom-persiste-apos-remover-itens.png',fullPage:true});
await p.getByRole('button',{name:'Esvaziar carrinho'}).click();await settle(p);
await p.goto(B);await add(p,'Boné Aba Curva');await p.getByRole('link',{name:/Carrinho/}).click();await settle(p);
log('E05b apos Esvaziar carrinho (cupom?)',await txt(p,'.cupom-aplicado'),'||',await res(p));
// E6 200 exato
await p.getByRole('button',{name:'Esvaziar carrinho'}).click();
await p.goto(B);await add(p,'Mochila Urbana',2);await p.getByRole('link',{name:/Carrinho/}).click();await settle(p);
log('E06 subtotal 200,00 exato',await res(p));await p.screenshot({path:OUT+'E06-subtotal-200-cobra-frete.png',fullPage:true});
log('E06 cupom em 200',await cupom('BEMVINDO10'));await p.screenshot({path:OUT+'E06b-subtotal-200-cupom.png',fullPage:true});
await p.getByRole('button',{name:'Remover cupom'}).click();
await p.getByRole('button',{name:'Esvaziar carrinho'}).click();
// E7 199,80 / 200.x / 219.8 / threshold com cupom
await p.goto(B);await add(p,'Camiseta Essencial');await add(p,'Calça Jeans');await p.getByRole('link',{name:/Carrinho/}).click();await settle(p);
log('E07 199,80',await res(p));
await p.getByRole('button',{name:/Remover Camiseta/}).click();await settle(p);
await p.goto(B);await add(p,'Jaqueta');await p.getByRole('link',{name:/Carrinho/}).click();await settle(p);
log('E07b 229,90+139,90 =',await res(p));
log('E07c cupom CA08',await cupom('BEMVINDO10'));await p.screenshot({path:OUT+'E07c-frete-gratis-com-cupom.png',fullPage:true});
// E8 checkout
await p.getByRole('link',{name:'Finalizar compra'}).click();await settle(p);log('E08 url',p.url());
await p.screenshot({path:OUT+'E08a-checkout.png',fullPage:true});
const sub=async()=>{await p.getByRole('button',{name:'Confirmar pedido'}).click();await settle(p)};
const errs=async()=>(await p.locator('.mensagem-erro').allInnerTexts()).join(' | ');
await sub();log('E08b vazio',await errs());await p.screenshot({path:OUT+'E08b-checkout-vazio.png',fullPage:true});
await p.fill('#campo-nome','Maria');await p.fill('#campo-email','m@x');await p.fill('#campo-cep','123');await sub();log('E08c invalidos',await errs());
await p.fill('#campo-nome','Maria da Silva');await p.fill('#campo-email','maria@exemplo.com');await p.fill('#campo-cep','01310-100');await sub();
log('E08d ok url',p.url(),'| h1',await txt(p,'h1'),'|',await txt(p,'.confirmacao'));await p.screenshot({path:OUT+'E08d-confirmacao.png',fullPage:true});
log('E08e resumo',await res(p));
await p.reload();settle(p);log('E08f reload confirmacao',await txt(p,'h1'));
await p.goto(B+'/checkout');await settle(p);log('E08g checkout vazio redireciona',p.url());
await p.goto(B+'/carrinho');await settle(p);log('E08h carrinho apos pedido',await txt(p,'h1'),'| contador',await txt(p,'.contador-carrinho'));
await p.goto(B+'/rota-x');log('E08i 404',await txt(p,'h1'),'| title',await p.title());
await p.goto(B+'/pedido-confirmado');log('E08j confirmacao direta (sessao ainda tem pedido)',await txt(p,'h1'));
// E9 persistence and tabs
await p.goto(B);await add(p,'Garrafa');await p.reload();await settle(p);log('E09 reload mantem carrinho?',await txt(p,'.contador-carrinho'));
const p2=await ctx();await p2.goto(B);log('E09b outra aba/ctx',await txt(p2,'.contador-carrinho'));
// E10 mobile
const m=await ctx({viewport:{width:375,height:740}});await m.goto(B);await m.screenshot({path:OUT+'E10a-mobile-home.png',fullPage:true});
const card=m.locator('li.produto',{hasText:'Jaqueta'});await card.getByRole('button',{name:'Adicionar ao carrinho'}).click();await m.goto(B+'/carrinho');await m.waitForTimeout(700);await m.screenshot({path:OUT+'E10b-mobile-carrinho.png',fullPage:true});
log('E10 overflow horizontal mobile:',await m.evaluate(()=>document.documentElement.scrollWidth>window.innerWidth));
// E11 doc page
const d=await ctx();await d.goto(B+'/documentacao');await d.screenshot({path:OUT+'E11-documentacao.png',fullPage:true});
await br.close();
