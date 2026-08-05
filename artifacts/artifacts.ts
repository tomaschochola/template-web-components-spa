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

import image from '../assets/icon.svg?inline';
import {
  BROWSER_ARTIFACT_PRINT_PAGE_TAG_NAME,
  BROWSER_ARTIFACT_SOCIAL_CARD_TAG_NAME,
  defineBrowserArtifactPrintPage,
  defineBrowserArtifactSocialCard,
  defineBrowserArtifacts,
} from '@tomaschochola/tooling-browser-artifacts/browser';

defineBrowserArtifactPrintPage(customElements);
defineBrowserArtifactSocialCard(customElements);

defineBrowserArtifacts(({ pdf, png }) => {
  png('open-graph.png', {
    height: 630,
    width: 1200,
  }, (root) => {
    const card = root.ownerDocument.createElement(BROWSER_ARTIFACT_SOCIAL_CARD_TAG_NAME);

    card.imageSource = image;
    card.heading = 'Template';
    root.replaceChildren(card);
  });

  png('facebook-page-cover.png', {
    height: 315,
    width: 851,
  }, (root) => {
    const card = root.ownerDocument.createElement(BROWSER_ARTIFACT_SOCIAL_CARD_TAG_NAME);

    card.imageSource = image;
    card.heading = 'Template';
    root.replaceChildren(card);
  });

  png('facebook-group-cover.png', {
    height: 856,
    width: 1640,
  }, (root) => {
    const card = root.ownerDocument.createElement(BROWSER_ARTIFACT_SOCIAL_CARD_TAG_NAME);

    card.imageSource = image;
    card.heading = 'Template';
    root.replaceChildren(card);
  });

  pdf(
    'sample-a4.pdf',
    {
      height: 1123,
      width: 794,
    },
    (root) => {
      const document = root.ownerDocument;
      const page = document.createElement(BROWSER_ARTIFACT_PRINT_PAGE_TAG_NAME);
      const title = document.createElement('h1');

      title.textContent = 'Sample A4 document';
      page.append(title);

      for (const text of [
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere, neque vitae faucibus tincidunt, justo sem consequat nibh, vel feugiat augue erat sed lectus.',
        'Suspendisse potenti. Curabitur dignissim, mauris et malesuada tincidunt, purus sapien volutpat tortor, quis posuere nulla lorem vitae nisl.',
        'Praesent vitae justo sed enim hendrerit tristique. Aliquam erat volutpat. Nulla facilisi.',
      ]) {
        const paragraph = document.createElement('p');

        paragraph.textContent = text;
        page.append(paragraph);
      }

      root.replaceChildren(page);
    },
    {
      format: 'A4',
    },
  );
});
