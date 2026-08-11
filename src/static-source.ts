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

const trustedTypeFactory = window.trustedTypes;

if (trustedTypeFactory === undefined) {
  throw new Error('Trusted Types is unavailable.');
}

const staticSourcePolicy = trustedTypeFactory.createPolicy('app-static-source', {
  createHTML(source: string): string {
    return source;
  },

  createScriptURL(source: string): string {
    const url = new URL(source, document.baseURI);

    if (url.origin !== location.origin || url.username !== '' || url.password !== '') {
      throw new TypeError('Executable source URL must be credential-free and same-origin.');
    }

    return url.toString();
  },
});

const generatedServiceWorkerPath = '/sw.js';

declare const staticHtmlSourceBrand: unique symbol;

export type StaticHtmlSource = string & {
  readonly [staticHtmlSourceBrand]: 'StaticHtmlSource';
};

type TrustedTemplateHtml = ReturnType<typeof staticSourcePolicy.createHTML>;

type TrustedTemplateSink = {
  innerHTML: TrustedTemplateHtml;
};

function setTrustedTemplateHtml(template: HTMLTemplateElement, trustedHtml: TrustedTemplateHtml): void {
  (template as unknown as TrustedTemplateSink).innerHTML = trustedHtml;
}

export function compileStaticTemplate(source: StaticHtmlSource): HTMLTemplateElement {
  const template = document.createElement('template');
  const trustedHtml = staticSourcePolicy.createHTML(source);
  setTrustedTemplateHtml(template, trustedHtml);

  return template;
}

type TrustedExecutableScriptUrl = ReturnType<typeof staticSourcePolicy.createScriptURL>;

type TrustedServiceWorkerContainer = {
  register(scriptUrl: TrustedExecutableScriptUrl): Promise<ServiceWorkerRegistration>;
};

export function registerGeneratedServiceWorker(): Promise<ServiceWorkerRegistration> {
  const trustedScriptUrl = staticSourcePolicy.createScriptURL(generatedServiceWorkerPath);
  const serviceWorkerContainer = navigator.serviceWorker as unknown as TrustedServiceWorkerContainer;

  return serviceWorkerContainer.register(trustedScriptUrl);
}
