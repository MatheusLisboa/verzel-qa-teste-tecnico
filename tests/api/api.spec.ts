import { test, expect } from '@playwright/test';

const cliente = { nome: 'Maria Silva', email: 'maria@exemplo.com', cep: '01310-100' };

test.describe('API de carrinho e pedidos @api', () => {
  test('AT-08 exemplo da documentação: cupom 10% e frete grátis [CT-07]', async ({ request }) => {
    const r = await request.post('/api/carrinho/calcular', {
      data: { itens: [{ produtoId: 'P002', quantidade: 1 }, { produtoId: 'P004', quantidade: 2 }], cupom: 'BEMVINDO10' },
    });

    expect(r.status()).toBe(200);
    expect(await r.json()).toMatchObject({
      subtotal: 239.7, desconto: 23.97, frete: 0, freteGratis: true, total: 215.73,
      cupom: { codigo: 'BEMVINDO10', aplicado: true },
    });
  });

  // BUG-01 (com e sem cupom)
  test('AT-09 subtotal de exatamente R$ 200,00 tem frete grátis [CT-05, CT-14] @bug', async ({ request }) => {
    test.fail(true, 'BUG-01: API cobra frete 19,90 com subtotal = 200');
    const itens = [{ produtoId: 'P005', quantidade: 2 }];

    const sem = await (await request.post('/api/carrinho/calcular', { data: { itens } })).json();
    expect(sem).toMatchObject({ subtotal: 200, frete: 0, freteGratis: true, total: 200 });

    const com = await (await request.post('/api/carrinho/calcular', { data: { itens, cupom: 'BEMVINDO10' } })).json();
    expect(com).toMatchObject({ desconto: 20, frete: 0, total: 180 });
  });

  // BUG-02
  test('AT-10 cálculo rejeita quantidade acima de 5 com 422 [CT-19] @bug', async ({ request }) => {
    test.fail(true, 'BUG-02: API aceita quantidade > 5 e responde 200');
    const r = await request.post('/api/carrinho/calcular', { data: { itens: [{ produtoId: 'P001', quantidade: 6 }] } });

    expect(r.status()).toBe(422);
    expect((await r.json()).erro.codigo).toBe('QUANTIDADE_MAXIMA_EXCEDIDA');
  });

  // BUG-03
  test('AT-11 pedido com mais de 5 unidades não é confirmado [CT-20] @bug', async ({ request }) => {
    test.fail(true, 'BUG-03: POST /api/pedidos confirma pedido com quantidade > 5 (201)');
    const r = await request.post('/api/pedidos', { data: { cliente, itens: [{ produtoId: 'P005', quantidade: 6 }] } });

    expect(r.status()).toBe(422);
    expect((await r.json()).erro.codigo).toBe('QUANTIDADE_MAXIMA_EXCEDIDA');
  });

  test('AT-12 pedido com cupom inválido ou expirado dá 422 (diferente do cálculo) [CT-26]', async ({ request }) => {
    const itens = [{ produtoId: 'P005', quantidade: 1 }];

    const invalido = await request.post('/api/pedidos', { data: { cliente, itens, cupom: 'XPTO' } });
    expect(invalido.status()).toBe(422);
    expect((await invalido.json()).erro.codigo).toBe('CUPOM_INVALIDO');

    const expirado = await request.post('/api/pedidos', { data: { cliente, itens, cupom: 'VERAO2026' } });
    expect(expirado.status()).toBe(422);
    expect((await expirado.json()).erro.codigo).toBe('CUPOM_EXPIRADO');
  });
});
