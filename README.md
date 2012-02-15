# MassiveSitemap [![](http://travis-ci.org/rngtng/massive_sitemap.png)](http://travis-ci.org/rngtng/massive_sitemap)

Build painfree sitemaps for websites with millions of pages

MassiveSitemap is a successor project of [BigSitemap](https://github.com/alexrabarts/big_sitemap), a [Sitemap](http://sitemaps.org) generator for websites with millions of pages.
It implements various generation stategies, e.g. to split large Sitemaps into multiple files, gzip files to minimize bandwidth usage, or incremental updates. It offers API is very similar to _BigSitemap_ and therefor can be set up with just a few lines of code and is compatible with just about any framework.

## Usage

```ruby
require 'massive_sitemap'

index_url = MassiveSitemap.generate(:url => 'test.de/') do
  add "dummy"
end
MassiveSitemap.ping(index_url)

```

* clear structure
* allows extension (S3)

MassiveSitemap - build huge sitemaps painfree. Differential updates keeps generation time short and reduces load on DB. It's heavealy inspired by BigSitemaps and offers compatiable API

## Dependencies

Obviously depends on a S3 library which [S3 gem](https://github.com/qoobaa/s3)


## Contributing

We'll check out your contribution if you:

- Provide a comprehensive suite of tests for your fork.
- Have a clear and documented rationale for your changes.
- Package these up in a pull request.

We'll do our best to help you out with any contribution issues you may have.


## License

The license is included as LICENSE in this directory.
