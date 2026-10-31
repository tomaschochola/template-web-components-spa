import { test } from '@playwright/test';
import { assertStandardPage } from '@tomaschochola/tooling-playwright';

test('renders the home page', async ({ page }) => {
    await assertStandardPage(page, {
        heading: 'tomaschochola/template-web-components-spa',
        title: 'tomaschochola/template-web-components-spa',
        url: '/',
    });
});
