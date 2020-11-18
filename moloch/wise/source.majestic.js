/******************************************************************************/
/*
 *
 * Copyright 2012-2016 AOL Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this Software except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

var fs             = require('fs')
  , wiseSource     = require('./wiseSource.js')
  , util           = require('util')
//  , HashTable      = require('hashtable')
  , csv            = require('csv')
  ;
//////////////////////////////////////////////////////////////////////////////////
function MajesticSource (api, section) {
  MajesticSource.super_.call(this, api, section);
  this.url          = api.getConfig("majestic", "url");

  if (this.url === undefined) {
    console.log(this.section, "- No url defined");
    return;
  }


  this.domains      = [];
  this.cacheTimeout = -1;

  this.tagsSetting();

  setImmediate(this.loadFile.bind(this));
  setInterval(this.loadFile.bind(this), 24*60*60*1000); // Reload file every 24 hours

  this.api.addSource("majestic", this);
}
util.inherits(MajesticSource, wiseSource);
//////////////////////////////////////////////////////////////////////////////////
MajesticSource.prototype.parseFile = function()
{
  this.domains = [];

  var count = 0;

  var parser = csv.parse({skip_empty_lines:true},(err,data) =>{
    if (err) {
      console.log(this.section, "- Couldn't parse", '/tmp/majestic.csv', "csv", err);
      return;
    }

    for(var i = 0; i < data.length; i++) {
      if (data[i].length < 3){
        continue;
      }

      this.domains.push(data[i][2]);

    }

    console.log(this.section, "- Loaded");
  });

  fs.createReadStream('/tmp/majestic.csv').pipe(parser);
};
//////////////////////////////////////////////////////////////////////////////////
MajesticSource.prototype.loadFile = function() {
  console.log(this.section, "- Downloading files");
  wiseSource.request(this.url ,  '/tmp/majestic.csv', (statusCode) => {
    if (statusCode === 200 || !this.loaded) {
      this.loaded = true;
      this.parseFile();
    }
  });
};
//////////////////////////////////////////////////////////////////////////////////
MajesticSource.prototype.getDomain = function(domain, cb) {
  var domains = this.domains;
  // Is domain in list?
  var res = domains.find((el)=>{
    if(domain.length > el.length){
       if(domain.substring(domain.length-el.length) == el && domain[domain.length-el.length-1] == '.')
       { return true; }
    } else {
      if(domain == el){ return true; }
    }
  });

  // No results - No Match
  if(!res){
    return cb(null, this.tagsResult);
  }

  if(res != ''){
    // Match
    return cb(null, this.tagsResult);
  }else{
    // No Match
    return cb(null, this.tagsResult);
  }
};
//////////////////////////////////////////////////////////////////////////////////
MajesticSource.prototype.dump = function(res) {
  ["domains"].forEach((ckey) => {
    res.write(`${ckey}:\n`);
    this[ckey].forEach((key, value) => {
      var str = `{key: "${key}", ops:\n` +
        wiseSource.result2Str(wiseSource.combineResults([this.tagsResult, value])) + "},\n";
      res.write(str);
    });
  });
  res.end();
};
//////////////////////////////////////////////////////////////////////////////////
exports.initSource = function(api) {
  return new MajesticSource(api, "majestic");
};
