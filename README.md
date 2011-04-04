# Typhoon

The minimalist blog engine for Node.js

# How it works

- Typhoon is built right on top of **[Connect](//github.com/senchalabs/connect)** making it easily to extend
- Content is entirely managed through **git**
- Articles are written in _.txt_ with embedded metadata (in **yaml** format)
- Articles are to be written in **Markdown** format and are compiled with  [node-markdown](//github.com/andris9/node-markdown)
- Templating is done using **HAML** and compiled with [haml.js](//github.com/visionmedia/haml.js)
- Comments are handled by [disqus](http://disqus.com/)
- Typhoon's RSS feed can be used with [FeedBurner](http://feedburner.com/)
- Individual articles can be accessed through urls such as _/2011/03/28/hello-world_
- Archives can be accessed by year, month or day, with the same format as above

# Obtaining Typhoon

The easiest way to obtain Typhoon is through [npm](http://npmjs.org/):

    npm install Typhoon

Alternatively you can build it manually:

    git clone git://github.com/cjoudrey/typhoon.git
    cd typhoon/
    cake build

Keep in mind, if you compile it manually you will need to download the dependencies and devDependencies listed in [package.json](https://github.com/cjoudrey/typhoon/blob/master/package.json).

# Setting up your blog

If you are anxious to get started simply clone the repository [cjoudrey/blog.ht4.ca](https://github.com/cjoudrey/blog.ht4.ca) which comes with everything to get you started.

    git clone git@github.com:cjoudrey/blog.ht4.ca.git

Otherwise you can set up your blog manually as follow.

The first thing you will need to get started is the following directory structure:

    blog/
    |-- articles/          # Contains your articles
    |-- public/            # Contains your assets (css, images, favicon)
    |-- templates/         # Contains your haml template
      |-- article.haml     # Template used to render an article
      |-- error.haml       # Template used when there is a http error (404, 500)
      |-- layout.haml      # Frame that is used to render each content page
      |-- list.haml        # Template used to render a list of articles
    |- configs.js          # Typhoon configurations
    |- index.js            # Node entry-point

# Node entry-point `index.js`

The node entry-point is the script you will be executing with node.

    var typhoon = require('typhoon');
    typhoon.listen(require('./configs'));

# Typhoon configurations `configs.js`

The configurations file is a module that exports an object with the following format:

    module.exports = {
      'env': 'production',                          # this can either be 'production' or 'dev'
                                                    # and is used to hide/show errors.

      'title': 'my blog',                           # blog title
      'description': 'just another blog',           # blog description
      'favicon': __dirname + '/public/favicon.ico', # path to the blog's favicon
      'staticDir': __dirname + '/public',           # path to the blog's assets folder
      'templatesDir': __dirname + '/templates',     # path to the templates
      'articlesDir': __dirname + '/articles',       # path to the articles
      'host': '127.0.0.1',                          # host to listen on
      'port': 8080,                                 # port to listen on
      'baseUrl': 'http://127.0.0.1:8080',           # base url
      'encoding': 'utf8',                           # encoding of the articles and templates
      'perPage': 5,                                 # articles per page
      'googleAnalytics': 'UX-XXXXX-X',              # google analytics tracking code
      'disqus': 'myblog',                           # disqus site id
      'feedburner': 'myblog'                        # feedburner site id
    }

# Article structure

Each article placed in the `articles/` folder must have a filename with the following format: `YYYY-MM-DD-slug.txt`.

The filename is used to date the article and to build a link to the article.

The content of the file is formed by a metadata section and the article's body seperated by an empty line `/\n\n/`.

The only required metadata is `title`. Additional meta tags can be added and will be accessible in the templates.

Example article `2011-04-03-lorem-ipsum.txt`:

    title: Lorem ipsum
    author: chris

    Lorem ipsum dolor sit amet, consectetur adipiscing elit.
    Maecenas justo neque, dictum eget accumsan non, luctus ac lacus.
    Phasellus ac erat metus, et sagittis dolor.

This article can now be accessed through `/2011/04/03/lorem-ipsum`.

One can specify a summary for the article by placing the `<!-- more -->` delimiter in the article's body:

    title: Lorem ipsum
    author: chris

    Lorem ipsum dolor sit amet, consectetur adipiscing elit.<!-- more -->
    Maecenas justo neque, dictum eget accumsan non, luctus ac lacus.
    Phasellus ac erat metus, et sagittis dolor.

# Blogs using Typhoon

- [http://blog.ht4.ca](http://blog.ht4.ca) ([Source](//github.com/cjoudrey/blog.ht4.ca))

# Mentions

Typhoon was inspired by [Toto](//github.com/cloudhead/toto) (Ruby) and [Wheat](//github.com/creationix/wheat) (Node.js). Go check them out!

Copyright (c) 2011 Christian Joudrey. See LICENSE for details.
