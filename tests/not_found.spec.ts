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
import { en } from '../src/lang/en';
import { assertPage } from './test';

test('/not_found', async ({ page }) => {
  await assertPage(page, '/not_found');

  await expect(page).toHaveURL('/not_found');

  await expect(page).toHaveTitle(en['routes.not_found.seo.title']);
});
