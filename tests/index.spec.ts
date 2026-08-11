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

import { expect, test } from '@playwright/test';
import { assertNoAxeViolations, loadPage } from './test';

test('/', async ({ page }) => {
  await loadPage(page, '/');
  await expect(page).toHaveTitle('tomaschochola/template-web-components-spa');
  await expect(page.getByRole('heading', { level: 1, name: 'tomaschochola/template-web-components-spa' })).toBeVisible();
  await expect
    .poll(async () =>
      page.evaluate(() => document.adoptedStyleSheets.some((sheet) => sheet instanceof CSSStyleSheet && [...sheet.cssRules].some((rule) => rule.cssText.includes('--tch-color-background')))),
    )
    .toBe(true);
  await assertNoAxeViolations(page);
});
