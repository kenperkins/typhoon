# View helpers

Several view helpers are available such as:

  * **markdown(str)** - returns: Markdown encoded string
  * **summary(body, separator = '<!-- more -->', trimmer = '...')** - returns: Content in `body` preceding `<!-- more -->` and trims using trimmer
  * **gravatar(email, size=50)** - returns: URL to gravatar
  * **prettyDate(date)** - returns: Date in format "April 9, 2011"
  * **isoDate(date)** - returns: Date in format "YYYY-MM-DD"
  * **rfc822Date(date)** - returns: Date in RFC822 format (used by RSS feeds)
  * **configs** - returns: Configs object

These helpers can be overrided and extended as such:

    var typhoon = require('typhoon');

    typhoon.helpers.github = function(name) {
      return 'https://github.com/' + name;
    };