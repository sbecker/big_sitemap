# Changes

## vx.x.x - ???

  * Amazon S3 integration
  * manifest handling

## v2.0.x - ???

  * updated/fixed Ping
  * updated Docu
  * switch to writer chain

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
