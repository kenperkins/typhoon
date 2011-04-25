# View helpers

Several view helpers are available such as:

  * String **markdown(str)** - returns the Markdown encoded string
  * String **summary(body, separator = '<!-- more -->', trimmer = '...')** - returns the content in `body` preceding `<!-- more -->` and trims using trimmer
  * String **gravatar(email, size=50)** - returns the URL to gravatar for the given `email`
  * String **prettyDate(date)** - returns the `date` in format `"April 9, 2011"`
  * String **isoDate(date)** - returns the `date` in format `"YYYY-MM-DD"`
  * String **rfc822Date(date)** - returns the `date` in RFC822 format (used by RSS feeds)
  * Object **configs** - returns the `configs` object

These helpers can be overrided and extended as such:

    var typhoon = require('typhoon');

    typhoon.helpers.github = function(name) {
      return 'https://github.com/' + name;
    };