# Article

Properties:

  * Object **meta** - meta data of the article
  * String **body** - body of the article
  * String **title** - title of the article (eq to `meta.title`)
  * String **slug** - typically what follows the date in the filename (eq to `meta.slug`)
  * Date **date** - date of the article, typically what precedes the slug in the filename (eq to `meta.date`)

Methods:

  * String **permalink(relative = false)** - returns the permalink of the article