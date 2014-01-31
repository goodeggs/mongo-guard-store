mongoose = require 'mongoose'

schema = new mongoose.Schema
  path: {type: String, required: true, index: true}
  cached:
    createdAt: {type: Date, required: true, index: true}
    headers: {}

GuardStoreEntry = mongoose.model 'GuardStoreEntry', schema

class MongoGuardStore

  set: (path, cached, callback) ->
    GuardStoreEntry.update {path}, {path, cached}, {upsert: true}, callback

  get: (path, callback) ->
    GuardStoreEntry.findOne({path}).lean().exec (err, entry) ->
      return callback(err) if err?
      callback(null, entry?.cached)

  delete: (path, callback) ->
    entries = GuardStoreEntry.find({path}).lean().exec (err, entries) ->
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
