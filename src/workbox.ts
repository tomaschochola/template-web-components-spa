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

function onWindowLoad(callback: () => void): void {
  if (document.readyState === 'complete') {
    callback();
  } else {
    window.addEventListener('load', callback, { once: true });
  }
}

function registerServiceWorker(): void {
  if (process.env.NODE_ENV !== 'production' || process.env.APP_ENV !== 'production' || !('serviceWorker' in navigator)) {
    return;
  }

  onWindowLoad(() => {
    void navigator.serviceWorker.register('/sw.js').catch((error: unknown) => {
      console.error('Service Worker registration failed.', error);
    });
  });
}

registerServiceWorker();
