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
import './sample-a4.scss';

const paragraphs = [
  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere, neque vitae faucibus tincidunt, justo sem consequat nibh, vel feugiat augue erat sed lectus.',
  'Suspendisse potenti. Curabitur dignissim, mauris et malesuada tincidunt, purus sapien volutpat tortor, quis posuere nulla lorem vitae nisl.',
  'Praesent vitae justo sed enim hendrerit tristique. Aliquam erat volutpat. Nulla facilisi.',
] as const;

class SampleA4DocumentElement extends HTMLElement {
  public connectedCallback(): void {
    const document = this.ownerDocument;
    const main = document.createElement('main');
    const title = document.createElement('h1');

    title.textContent = 'Sample A4 document';
    main.append(title);

    for (const text of paragraphs) {
      const paragraph = document.createElement('p');

      paragraph.textContent = text;
      main.append(paragraph);
    }

    this.classList.add('sample-a4-document');
    this.replaceChildren(main);
  }
}

const tagName = 'sample-a4-document';

customElements.define(tagName, SampleA4DocumentElement);
document.body.replaceChildren(document.createElement(tagName));
