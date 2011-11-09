0.4.1 / 2011-11-08
==================

  * Enabled support for node 0.6.0
  * Updated Express to 2.5.0

0.4.0 / 2011-04-29
==================

  * Added static file folders for articles - closes #8
  * Added tests - closes #3
  * Updated Express to 2.3.2

0.3.3 / 2011-04-17
==================

  * Release to fix NPM package

0.3.2 / 2011-04-17
==================

  * Fixed an issue with Article.permalink relative argument.

0.3.1 / 2011-04-17
==================

  * Added Jade to dependencies
  * Fixed an issue with paging not working properly

0.3.0 / 2011-04-17
==================

  * Complete recode to [Express](http://expressjs.com)
  * Default template engine now [Jade](http://jade-lang.com)

0.2.2 / 2011-04-09
==================

  * Fixed an issue with an uninitialized variable

0.2.1 / 2011-04-09
==================

  * Fixed a typo in `view.coffee`

0.2.0 / 2011-04-09
==================

  * Major rehaul of the API
  * Modified the `summary` helper. Can now specify `delimiter` and `trimmer`
  * Removed `feed.haml` and added optional configuration `configs.rss = true`
  * Helpers are now in their own file `helpers.coffee`
  * Removed `patches.coffee` now `utils.coffee`
  * Added optional configurations: `articlesExt`, `templatesExt`

0.1.2 / 2011-04-05
==================

  * Added date validation for listings - closes #7
  * Added template local variable `title` in archives - closes #2
  * Added gravatar helper `gravatar(email, size = 50)`
  * Template helpers are now exposed in `Typhoon.Helpers`

0.1.1 / 2011-04-03
==================

  * Removed src from published package

0.1.0 / 2011-04-03
==================

  * Initial release
