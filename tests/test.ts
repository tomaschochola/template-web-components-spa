/**
 * @file
 * @author Tomáš Chochola <tomaschochola@tomaschochola.cz>
 * @copyright © 2026 Tomáš Chochola <tomaschochola@tomaschochola.cz>
 *
 * @license CC-BY-ND-4.0
 *
 * @see {@link https://creativecommons.org/licenses/by-nd/4.0/} License
 * @see {@link https://github.com/tomaschochola} GitHub Profile
 * @see {@link https://github.com/sponsors/tomaschochola} GitHub Sponsors
 */

import AxeBuilder from '@axe-core/playwright';
import { expect, type Page } from '@playwright/test';

export async function waitForIdle(page: Page): Promise<void> {
  await page.waitForLoadState('load');
  await page.waitForLoadState('domcontentloaded');
  await page.waitForLoadState('networkidle');
}

export async function assertAxe(page: Page): Promise<void> {
  expect((await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa', 'best-practice', 'ACT', 'EN-301-549']).analyze()).violations).toEqual([]);
}

export async function loadPage(page: Page, url: string): Promise<void> {
  await page.goto(url);
  await waitForIdle(page);
  await expect(page).toHaveURL(url);
  await expect(page.locator('#webpack-dev-server-client-overlay')).not.toBeAttached();
}
