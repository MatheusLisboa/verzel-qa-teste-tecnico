import { expect, type Page } from '@playwright/test';

export type Resumo = { subtotal: string; desconto: string; frete: string; total: string };

/** Formata como a loja exibe (pt-BR, espaço comum após R$). */
export const brl = (valor: number) =>
  new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor).replace(/ /g, ' ');

export async function adicionarProduto(page: Page, nome: string, vezes = 1) {
  const cartao = page.locator('li.produto', { hasText: nome });
  const botao = cartao.getByRole('button', { name: 'Adicionar ao carrinho' });
  for (let i = 0; i < vezes; i++) await botao.click();
}

export async function irParaCarrinho(page: Page) {
  await page.getByRole('link', { name: /Carrinho/ }).click();
  await expect(page.getByRole('heading', { name: 'Carrinho', level: 1 })).toBeVisible();
}

/** Abre a loja, adiciona os produtos e vai ao carrinho. */
export async function montarCarrinho(page: Page, itens: Array<[nome: string, qtd?: number]>) {
  await page.goto('/');
  for (const [nome, qtd] of itens) await adicionarProduto(page, nome, qtd ?? 1);
  await irParaCarrinho(page);
  await expect(page.locator('[data-valor="subtotal"]')).toBeVisible();
}

export async function aplicarCupom(page: Page, codigo: string) {
  await page.locator('#campo-cupom').fill(codigo);
  await page.getByRole('button', { name: 'Aplicar cupom' }).click();
}

export const valor = (page: Page, campo: 'subtotal' | 'desconto' | 'frete' | 'total') =>
  page.locator(`[data-valor="${campo}"]`);
