import { test } from '@playwright/test';
import { assertStandardPage } from '@tomaschochola/tooling-playwright';

test('renders the home page', async ({ page }) => {
    await assertStandardPage(page, {
        heading: 'github.com/tomaschochola/template-web-components-spa',
        title: 'github.com/tomaschochola/template-web-components-spa',
        url: '/',
    });
});
