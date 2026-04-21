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

import { useEffect, type ReactElement } from 'react';
import { useFetcher } from 'react-router';
import { INDEX_USERS_FETCHER, type IndexUsersFetcherInterface } from '../fetchers/indexUsersFetcher';
import { useSeo } from '../lang/seo';
import { useTrans } from '../lang/trans';
import { SuspenseValue } from '../suspenses/SuspenseValue';

export function IndexRoute(): ReactElement {
  const trans = useTrans();

  useSeo({
    title: trans.format('routes.index.seo.title'),
    keywords: trans.format('routes.index.seo.keywords'),
    description: trans.format('routes.index.seo.description'),
  });

  const { load, data } = useFetcher<Awaited<IndexUsersFetcherInterface>>({ key: INDEX_USERS_FETCHER });

  useEffect(() => {
    void load(INDEX_USERS_FETCHER);
  }, [load]);

  return (
    <main>
      <h1>
        {trans.format('routes.index.h1')}
      </h1>
      <section>
        <SuspenseValue
          resolve={data}
        >
          {(resolved) => {
            return resolved.map((user) => {
              return (
                <article
                  key={user.id}
                >
                  <h2>
                    {user.name}
                  </h2>
                </article>
              );
            });
          }}
        </SuspenseValue>
      </section>
    </main>
  );
}
