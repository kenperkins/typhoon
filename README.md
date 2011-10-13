# Typhoon

The minimalist blog engine for Node.js

# How it works

- Typhoon is built right on top of **[Express](http://expressjs.com)** making it easy to extend
- Content is entirely managed through **git**
- Articles are written in _.txt_ with embedded metadata (in **yaml** format)
- Articles are to be written in **Markdown** format and are compiled with  [node-markdown](//github.com/andris9/node-markdown)
- Templating is done using **Jade**
- Comments are handled by [disqus](http://disqus.com/)
- Typhoon's RSS feed can be used with [FeedBurner](http://feedburner.com/)
- Individual articles can be accessed through urls such as _/2011/03/28/hello-world_
- Archives can be accessed by year, month or day, with the same format as above

# Obtaining Typhoon

The easiest way to obtain Typhoon is through [npm](http://npmjs.org/):

    npm install typhoon

# Setting up your blog

If you are anxious to get started simply clone the repository [cjoudrey/blog.ht4.ca](https://github.com/cjoudrey/blog.ht4.ca) which comes with everything to get you started.

    git clone git@github.com:cjoudrey/blog.ht4.ca.git

Otherwise you can set up your blog manually as follow.

The first thing you will need to get started is the following directory structure:

    blog/
    |-- articles/          # Contains your articles
    |-- public/            # Contains your assets (css, images, favicon)
    |-- views/             # Contains your jade views
      |-- article.jade     # Used to render an article
      |-- error.jade       # Used when there is a http error (404, 500) in production
      |-- layout.jade      # Frame that is used to render each content page
      |-- list.jade        # Used to render a list of articles
      |-- feed.jade        # Used to render the RSS feed (optional)
    |- configs.js          # Typhoon configurations
    |- index.js            # Node entry-point

A full documentation of available locals for each view is available [here](//github.com/cjoudrey/typhoon/blob/master/docs/views.md).

# Node entry-point - index.js

The node entry-point is the script you will be executing with node.

    var typhoon = require('typhoon');
    typhoon.app(__dirname, require('./configs');

# Typhoon configurations - configs.js

The configurations file is a module that exports an object with the following format:

    module.exports = {
      'env': 'production',                          # this can either be 'production' or 'dev'
                                                    # and is used to hide/show errors.

      'title': 'my blog',                           # blog title
      'description': 'just another blog',           # blog description
      'favicon': __dirname + '/public/favicon.ico', # path to the blog's favicon
      'staticDir': __dirname + '/public',           # path to the blog's assets folder
      'viewsDir': __dirname + '/views',             # path to the views
      'articlesDir': __dirname + '/articles',       # path to the articles
      'host': '127.0.0.1',                          # host to listen on
      'port': 8080,                                 # port to listen on
      'baseUrl': 'http://127.0.0.1:8080',           # base url
      'encoding': 'utf8',                           # encoding of the articles
      'perPage': 5,                                 # articles per page

      # Optional configurations
      'articlesExt': '.txt',                        # extension of article files
      'viewsEngine': 'jade',                        # views engine
      'rss': true,                                  # enable the rss feed (requires feed view)

      # Specific to the views used by blog.ht4.ca
      'googleAnalytics': 'UX-XXXXX-X',              # google analytics tracking code
      'disqus': 'myblog',                           # disqus site id
      'feedburner': 'myblog'                        # feedburner site id
    }

# Article structure

Each article placed in the `articles/` folder must have a filename with the following format: `YYYY-MM-DD-slug.txt`.

The filename is used to date the article and to build a link to the article.

The content of the file is formed by a metadata section and the article's body separated by an empty line `/\n\n/`.

The only required metadata is `title`. Additional meta tags can be added and will be accessible in the views.

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

# Article static files

In some situations one may need static files for an article. These are are to be placed within a folder named after the article.

For instance, the static files folder for the article `2011-04-03-lorem-ipsum.txt` is `2011-04-03-lorem-ipsum`.

This folder is to be placed in the `articles/` folder.

All files placed inside the `articles/2011-04-03-lorem-ipsum/` folder can then be accessed through `/2011/04/03/lorem-ipsum/filename`.

# Documentation for Views

  Local variables are documented [here](//github.com/cjoudrey/typhoon/blob/master/docs/views.md).

# View helpers

  Documentation available [here](//github.com/cjoudrey/typhoon/blob/master/docs/helpers.md).

# Blogs using Typhoon

- [http://blog.ht4.ca](http://blog.ht4.ca) ([Source](//github.com/cjoudrey/blog.ht4.ca))
- [http://blog.clipboard.com/](http://blog.clipboard.com/)

# Mentions

Typhoon was inspired by [Toto](//github.com/cloudhead/toto) (Ruby) and [Wheat](//github.com/creationix/wheat) (Node.js). Go check them out!

Copyright (c) 2011 Christian Joudrey. See LICENSE for details.

Node.js is an official trademark of Joyent. This module is not formally related to or endorsed by the official Joyent Node.js open source or commercial project.
