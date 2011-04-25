# layout.jade

This template is used to render an entire page.

Locals:

  * String **body** - the content of the page

# list.jade

Used to render a listing of articles. This template is also used for article archives.

Locals:

  * Array **articles** - array of [Article](//github.com/cjoudrey/typhoon/blob/master/docs/models/article.md) objects
  * Number **page** - the number of the current page
  * Object **paging** - object with paging information
      * String **paging.next** - when available, contains the URL to the next page
      * String **paging.previous** - when available, contains the URL to the previous page
  * String **action** - either `'archives'` or `'listing'`
  * String **archivesType** - when `action` is `'archives'`, contains either: `'Yearly'`, `'Monthly'` or `'Daily'`
  * String **archivesLabel** - when `action` is `'archives'`, contains a textual representation of the archives date
  * Array **filter** - when listing archives, contains an array of params used to filter the articles
  
# article.jade

Used to render a specific article.

Locals:

  * [Article](//github.com/cjoudrey/typhoon/blob/master/docs/models/article.md) **article** - a [Article](//github.com/cjoudrey/typhoon/blob/master/docs/models/article.md) object
  * String **title** - the title of the article (eq to `article.title`)
  
# feed.jade

Used to render the RSS feed.

Locals:

  * Array **articles** - array of [Article](//github.com/cjoudrey/typhoon/blob/master/docs/models/article.md) objects (maximum of `configs.perPage`)
  * Date **lastBuild** - the date of the last build (currently `new Date()`)

# error.jade

This template is used whenever an error occurs while in production (`NODE_ENV=production`).

This template is not rendered with `layout.jade`.

Locals:

  * Number **errorCode** - the error code either `404` or `500`
