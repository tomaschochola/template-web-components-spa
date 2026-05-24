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

import { ESLintConfigBuilder, filePatterns } from '@tomaschochola/tooling-eslint';

const typescriptFiles = filePatterns.allTypeScriptFiles;
const javascriptFiles = filePatterns.allJavaScriptFiles;

// eslint-disable-next-line no-restricted-exports
export default new ESLintConfigBuilder()
  .addNodeGlobalsForConfigFiles()
  .addBrowserGlobals()
  .addGlobalIgnores(filePatterns.defaultIgnorePatterns)
  .addGlobalIgnores(['node_modules', 'dist', 'generated', 'tmp', 'test-results'])
  .addJavaScriptRecommendedRules()
  .addJavaScriptPolicyRules()
  .addTypeScriptStrictTypeCheckedRules({ files: typescriptFiles })
  .enableTypeScriptProjectService({ files: typescriptFiles })
  .addTypeScriptPolicyRules({ files: typescriptFiles })
  .disableTypeScriptTypeChecking({ files: javascriptFiles })
  .toConfig();
