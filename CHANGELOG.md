# Changes

## vx.x.x - ???

## v2.0.x - ???

  * update Docu
  * switch to writer chain
     * move manifest to it's own writer
     * nested writing
  * add BigSitemap API

## v2.1.0 - 15-07-2012
  * Ping: added yandex support
  * Ping: disabled ask (the seem to be down!?)
  * updated docu for more exmaples

## v2.0.0 - 13-02-2012
  _inital release_

  * restructured gem completely based on BigSitemap gem
  * seperated logic in two major parts:
    * Builder -> creates content
    * Writer -> stores content
  * added several implementations/specifiaction of builder/writer
  * added generator for default setup
  * added specs
  * writer overwrite detection
  * added Index generation
  * don't init new writer all the time
  * move inited status to writer
  * move index build into indexer and resource handling/selection into writer
  * manifest handling:
  * moved Amazon S3 integration to [massive_sitemap-writer-s3](https://github.com/rngtng/massive_sitemap-writer-s3)
  * updated/fixed Ping
  * move LockingFile into MassiveSitemap scope
  * FileManifest -> read all files into streams take that as reference
  * add test for stream_id delete
