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

import { use, useEffect, useState, type ReactElement } from 'react';
import { I18nProvider, useLocale, useLocalizedStringFormatter } from 'react-aria';
import { wrapPromise } from '../helpers/promises';
import type { Strings } from './en';
import { useDocumentLang } from './seo';

const cache = new Map<string, Promise<Strings>>();

type LocaleEvent = CustomEvent<{
  locale: string | null;
}>;

function isLocaleEvent(event: Event): event is LocaleEvent {
  return event.type === 'changeLocale' && 'detail' in event && typeof event.detail === 'object' && event.detail !== null && 'locale' in event.detail;
}

export function changeLocale(locale: string | null): void {
  const event: LocaleEvent = new CustomEvent('changeLocale', { detail: { locale: locale } });

  window.dispatchEvent(event);
}

function getStrings(locale: string): Promise<Strings> {
  const cached = cache.get(locale);

  if (cached !== undefined) {
    return cached;
  }

  let loader;

  if (locale === 'en') {
    loader = import('./en').then((module) => module.en);
  } else if (locale === 'cs') {
    loader = import('./cs').then((module) => module.cs);
  } else {
    throw new Error(`Locale ${locale} not found`);
  }

  const promise = wrapPromise(loader);

  cache.set(locale, promise);

  return promise;
}

export function changeStrings(locale: string): Promise<Strings> {
  return getStrings(locale).then((strings) => {
    changeLocale(locale);

    return strings;
  });
}

export function useTrans() {
  const { locale } = useLocale();

  const promise = getStrings(locale);

  return useLocalizedStringFormatter({ [locale]: use(promise) });
}

export function filterLocale(locale: string | null): string | null {
  if (locale?.startsWith('en') === true) return 'en';

  if (locale?.startsWith('cs') === true) return 'cs';

  if (locale?.startsWith('sk') === true) return 'cs';

  return null;
}

interface LocaleProviderProps {
  readonly children: ReactElement;
}

export function LocaleProvider({ children }: Readonly<LocaleProviderProps>): ReactElement {
  const { locale: defaultLocale } = useLocale();

  const [locale, setLocale] = useState<string | null>(() => filterLocale(localStorage.getItem('locale')));

  useEffect(() => {
    const handler = (event: Event) => {
      if (!isLocaleEvent(event)) {
        return;
      }

      const filteredLocale = filterLocale(event.detail.locale);

      setLocale(filteredLocale);

      if (filteredLocale !== null) {
        try {
          localStorage.setItem('locale', filteredLocale);
        } catch {
          localStorage.removeItem('locale');
        }
      } else {
        localStorage.removeItem('locale');
      }
    };

    window.addEventListener('changeLocale', handler);

    return () => {
      window.removeEventListener('changeLocale', handler);
    };
  }, [setLocale]);

  useEffect(() => {
    if (typeof requestIdleCallback === 'function' && typeof cancelIdleCallback === 'function') {
      const requestIdleTimeout = requestIdleCallback(
        () => {
          void getStrings('en');
          void getStrings('cs');
        },
        { timeout: 10000 },
      );

      return () => {
        cancelIdleCallback(requestIdleTimeout);
      };
    }

    const timeout = setTimeout(() => {
      void getStrings('en');
      void getStrings('cs');
    }, 10000);

    return () => {
      clearTimeout(timeout);
    };
  }, []);

  const final = filterLocale(locale) ?? filterLocale(defaultLocale) ?? 'en';

  useDocumentLang(final);

  return (
    <I18nProvider
      locale={final}
    >
      {children}
    </I18nProvider>
  );
}
