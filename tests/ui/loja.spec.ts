import { test, expect } from '@playwright/test';
import { aplicarCupom, brl, montarCarrinho, valor } from '../support/loja';

// Cada teste cria o próprio carrinho (o carrinho vive na aba), então não há dependência entre eles.

test.describe('Cupom e frete na interface @ui', () => {
  test('AT-01 cupom BEMVINDO10: 10% de desconto, ignora caixa/espaços e não incide no frete [CT-07, CT-08, CT-15]', async ({ page }) => {
    await montarCarrinho(page, [['Camiseta Essencial']]); // R$ 59,90
    await aplicarCupom(page, '  bemvindo10  ');

    await expect(page.locator('.cupom-aplicado')).toContainText('BEMVINDO10');
    await expect(valor(page, 'desconto')).toHaveText(`- ${brl(5.99)}`);
    await expect(valor(page, 'frete')).toHaveText(brl(19.9));
    await expect(valor(page, 'total')).toHaveText(brl(73.81)); // 59,90 - 5,99 + 19,90
  });

  test('AT-02 cupom inexistente é recusado sem desconto [CT-09]', async ({ page }) => {
    await montarCarrinho(page, [['Mochila Urbana']]);
    await aplicarCupom(page, 'XPTO');

    await expect(page.locator('#mensagem-cupom')).toHaveText('Cupom inválido.');
    await expect(valor(page, 'desconto')).toHaveText(brl(0));
  });

  test('AT-03 cupom expirado é recusado sem desconto [CT-10]', async ({ page }) => {
    await montarCarrinho(page, [['Mochila Urbana']]);
    await aplicarCupom(page, 'VERAO2026');

    await expect(page.locator('#mensagem-cupom')).toHaveText('Cupom expirado.');
    await expect(valor(page, 'desconto')).toHaveText(brl(0));
  });

  test('AT-04 abaixo de R$ 200,00 cobra R$ 19,90 e informa quanto falta [CT-03]', async ({ page }) => {
    await montarCarrinho(page, [['Camiseta Essencial']]); // R$ 59,90

    await expect(valor(page, 'frete')).toHaveText(brl(19.9));
    await expect(page.locator('.aviso-frete')).toHaveText(`Faltam ${brl(140.1)} para o frete grátis.`);
  });

  test('AT-05 frete grátis usa o subtotal ANTES do cupom [CT-13]', async ({ page }) => {
    // 189,90 + 29,90 = 219,80; com cupom o total cai para 197,82 (< 200) e o frete segue grátis.
    await montarCarrinho(page, [['Tênis Casual Urbano'], ['Kit 3 Pares de Meias']]);
    await aplicarCupom(page, 'BEMVINDO10');

    await expect(valor(page, 'frete')).toHaveText('Grátis');
    await expect(valor(page, 'total')).toHaveText(brl(197.82));
  });

  // BUG-01. Quando for corrigido, este teste passa e o Playwright acusa "expected to fail, but passed".
  test('AT-06 subtotal de exatamente R$ 200,00 tem frete grátis [CT-05] @bug', async ({ page }) => {
    test.fail(true, 'BUG-01: frete de R$ 19,90 cobrado com subtotal = R$ 200,00');
    await montarCarrinho(page, [['Mochila Urbana', 2]]); // 2 x 100,00

    await expect(valor(page, 'subtotal')).toHaveText(brl(200));
    await expect(valor(page, 'frete')).toHaveText('Grátis');
    await expect(valor(page, 'total')).toHaveText(brl(200));
  });

  test('AT-07 fluxo completo: carrinho + cupom + dados -> pedido confirmado [CT-25]', async ({ page }) => {
    await montarCarrinho(page, [['Mochila Urbana']]);
    await aplicarCupom(page, 'BEMVINDO10');
    await page.getByRole('link', { name: 'Finalizar compra' }).click();

    await page.getByLabel('Nome completo').fill('Maria da Silva');
    await page.getByLabel('E-mail').fill('maria@exemplo.com');
    await page.getByLabel('CEP').fill('01310-100');
    await page.getByRole('button', { name: 'Confirmar pedido' }).click();

    await expect(page).toHaveURL(/\/pedido-confirmado$/);
    await expect(page.locator('.numero-pedido')).toHaveText(/^VZ-\d{6}$/);
    await expect(valor(page, 'desconto')).toHaveText(`- ${brl(10)}`);
    await expect(valor(page, 'total')).toHaveText(brl(109.9));
  });
});
