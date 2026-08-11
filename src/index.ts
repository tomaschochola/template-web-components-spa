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

import '@fontsource-variable/atkinson-hyperlegible-next';
import appTemplateSource from './app.template.html?template';
import appSheet from './index.scss?sheet';
import { compileStaticTemplate, registerGeneratedServiceWorker } from './static-source';

const appTemplate = compileStaticTemplate(appTemplateSource);

document.adoptedStyleSheets = [...document.adoptedStyleSheets, appSheet];
document.body.append(appTemplate.content.cloneNode(true));

function onWindowLoad(callback: () => void): void {
  if (document.readyState === 'complete') {
    callback();
  } else {
    window.addEventListener('load', callback, { once: true });
  }
}

function registerServiceWorker(): void {
  if (process.env.NODE_ENV !== 'production' || !('serviceWorker' in navigator)) {
    return;
  }

  onWindowLoad(() => {
    void registerGeneratedServiceWorker().catch((error: unknown) => {
      console.error('Service Worker registration failed.', error);
    });
  });
}

registerServiceWorker();
