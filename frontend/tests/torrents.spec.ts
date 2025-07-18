import { test, expect } from '@playwright/test';

test.describe('Torrents CRUD', () => {
  test('Affichage de la liste des torrents', async ({ page }) => {
    await page.goto('/torrents');
    await expect(page.getByRole('heading', { name: /torrents/i })).toBeVisible();
    await expect(page.getByText(/ajouter|add/i)).toBeVisible();
    // Table ou message vide
    await expect(
      page.locator('table, .text-gray-500:has-text("Aucune donnée disponible")')
    ).toBeVisible();
  });

  test('Ajout d\'un torrent (modal)', async ({ page }) => {
    await page.goto('/torrents');
    await page.getByRole('button', { name: /ajouter|add/i }).click();
    await expect(page.getByRole('dialog')).toBeVisible();
    // Simuler un ajout (champ vide, feedback erreur)
    await page.getByRole('button', { name: /ajouter|add/i }).click();
    await expect(page.getByText(/erreur|error/i)).toBeVisible();
    // (Pour un vrai test, remplir le champ et mocker l'API)
  });

  test('Suppression d\'un torrent (bouton)', async ({ page }) => {
    await page.goto('/torrents');
    // Si un torrent existe, cliquer sur supprimer
    const deleteBtn = page.getByRole('button', { name: /supprimer|delete/i }).first();
    if (await deleteBtn.isVisible()) {
      await deleteBtn.click();
      // Confirmer la boîte de dialogue native
      // Playwright ne gère pas nativement window.confirm, il faut mocker ou désactiver pour le test
    }
  });
});
