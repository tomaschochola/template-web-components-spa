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

async function retireServiceWorker() {
  const cacheNames = await caches.keys();

  await Promise.all(cacheNames.filter((cacheName) => cacheName.startsWith('workbox-precache')).map((cacheName) => caches.delete(cacheName)));
  await globalThis.registration.unregister();

  const windowClients = await globalThis.clients.matchAll({ includeUncontrolled: true, type: 'window' });

  await Promise.all(windowClients.map((client) => client.navigate(client.url)));
}

globalThis.addEventListener('install', (event) => {
  event.waitUntil(globalThis.skipWaiting());
});

globalThis.addEventListener('activate', (event) => {
  event.waitUntil(retireServiceWorker());
});
