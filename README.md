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

# Blogs using Typhoon

- http://blog.ht4.ca ([Source](//github.com/cjoudrey/blog.ht4.ca))

# Mentions

Typhoon was inspired by [Toto](//github.com/cloudhead/toto) (Ruby) and [Wheat](//github.com/creationix/wheat) (Node.js). Go check them out!
