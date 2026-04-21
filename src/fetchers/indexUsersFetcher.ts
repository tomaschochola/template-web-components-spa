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

import type { LoaderFunctionArgs } from 'react-router';

interface User {
  readonly id: string;
  readonly name: string;
  readonly username: string;
  readonly email: string;
  readonly phone: string;
  readonly website: string;
}

function assertUserArray(un: unknown): un is User[] {
  return Array.isArray(un);
}

export type IndexUsersFetcherInterface = Promise<User[]>;

export const INDEX_USERS_FETCHER = '/index_users';

export async function indexUsersFetcher({ request }: LoaderFunctionArgs): IndexUsersFetcherInterface {
  return fetch('https://jsonplaceholder.typicode.com/users', {
    method: 'GET',
    signal: request.signal,
  }).then(async (response) => {
    if (response.status !== 200) {
      throw new Error('indexUsersFetcher: invalid status ' + response.status.toFixed() + ':' + response.statusText);
    }

    if (response.headers.get('Content-Type')?.startsWith('application/json') !== true) {
      throw new Error('indexUsersFetcher: invalid content-type ' + (response.headers.get('Content-Type') ?? 'undefined'));
    }

    const json = await response.json() as unknown;

    if (!assertUserArray(json)) {
      throw new Error('indexUsersFetcher: invalid response structure');
    }

    return json;
  });
}
