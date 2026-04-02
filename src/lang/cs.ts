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

const cs = {
  'routes.index.h1': 'Ahoj světe!',
  'routes.index.seo.description': 'Úvodní stránka aplikace',
  'routes.index.seo.keywords': 'Domů, úvod, hlavní stránka',
  'routes.index.seo.title': 'Domů',
  'routes.not_found.h1': 'Stránka nenalezena!',
  'routes.not_found.seo.description': 'Stránka nenalezena, chyba 404',
  'routes.not_found.seo.keywords': 'Stránka nenalezena, chyba 404',
  'routes.not_found.seo.title': 'Stránka nenalezena',
};

export type Strings = typeof cs;

export { cs };
