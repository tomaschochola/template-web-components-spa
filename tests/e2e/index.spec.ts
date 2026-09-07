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

import { test } from '@playwright/test';
import { assertStandardPage } from '@tomaschochola/tooling-playwright';

test('renders the home page', async ({ page }) => {
    await assertStandardPage(page, {
        heading: 'Web Components SPA Template',
        title: 'Web Components SPA Template',
        url: '/',
    });
});
