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

import '@fontsource-variable/google-sans-flex/standard.css';
import './index.scss';

import 'core-js/stable';
import './observability';

function onWindowLoad(callback: () => void): void {
  if (document.readyState === 'complete') {
    callback();
  } else {
    window.addEventListener('load', callback, { once: true });
  }
}

function registerServiceWorker(): void {
  if (process.env.WEBPACK_MODE !== 'production' || !('serviceWorker' in navigator)) {
    return;
  }

  onWindowLoad(() => {
    void navigator.serviceWorker.register('/sw.js').catch((error: unknown) => {
      console.error('Service Worker registration failed.', error);
    });
  });
}

registerServiceWorker();
