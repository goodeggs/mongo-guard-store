mongo-guard-store [![NPM version](https://badge.fury.io/js/mongo-guard-store.png)](http://badge.fury.io/js/mongo-guard-store) [![Build Status](https://travis-ci.org/goodeggs/mongo-guard-store.png)](https://travis-ci.org/goodeggs/mongo-guard-store)
=================

MongoDB storage for [connect-guard](https://github.com/goodeggs/connect-guard) caching middleware.

```js
var guard = require('connect-guard'),
    MongoGuardStore = require('mongo-guard-store');

mongoose.connect 'mongodb://...'
guard.configure({store: new MongoGuardStore()})
```