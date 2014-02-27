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
  # expand paths to get lenient matching and regex support
  buildQuery: (request) ->
    flatten({request})

  set: (request, cached, callback) ->
    query = @buildQuery(request)
    GuardStoreEntry.update query, {request, cached}, {upsert: true}, callback

  get: (request, callback) ->
    query = @buildQuery(request)
    GuardStoreEntry.findOne(query).lean().exec (err, entry) ->
      return callback(err) if err?
      callback(null, entry?.cached)

  delete: (request, callback) ->
    query = @buildQuery(request)
    GuardStoreEntry.find(query).lean().exec (err, entries) ->
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
