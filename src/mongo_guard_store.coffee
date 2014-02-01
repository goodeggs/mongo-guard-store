mongoose = require 'mongoose'
{flatten} = require 'flat'

schema = new mongoose.Schema
  request:
    url: {type: String, required: true, index: true}
    headers: {}
  cached:
    createdAt: {type: Date, required: true, index: true}
    headers: {}

GuardStoreEntry = mongoose.model 'GuardStoreEntry', schema

class MongoGuardStore

  set: (request, cached, callback) ->
    GuardStoreEntry.update {request}, {request, cached}, {upsert: true}, callback

  get: (request, callback) ->
    GuardStoreEntry.findOne({request}).lean().exec (err, entry) ->
      return callback(err) if err?
      callback(null, entry?.cached)

  delete: (request, callback) ->
    # expand paths to get lenient matching and regex support
    query = flatten({request})
    entries = GuardStoreEntry.find(query).lean().exec (err, entries) ->
      return callback(err) if err?
      return callback(null, undefined) if entries.length == 0

      GuardStoreEntry.remove {_id: {$in: entries}}, (err) ->
        return callback(err) if err?

        values = (entry.cached for entry in entries)
        values = values[0] if values.length is 1
        callback(null, values)

  drop: (callback) ->
    GuardStoreEntry.remove {}, callback

module.exports = MongoGuardStore
MongoGuardStore.Entry = GuardStoreEntry
