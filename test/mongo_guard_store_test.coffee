mongoose = require 'mongoose'
expect = require 'expect.js'
MongoGuardStore = require '../'

describe 'MongoGuardStore', ->
  before ->
    mongoose.connect 'mongodb://localhost/mongo-guard-store_test'
  after ->
    mongoose.disconnect()

  {store} = {}
  beforeEach (done) ->
    store = new MongoGuardStore()
    store.drop done

  describe 'with nothing cached', ->
    it 'sets cached value', (done) ->
      value = createdAt: Date.now(), headers: {}
      store.set {url: '/users', headers: {}}, value, (err) ->
        store.get {url: '/users', headers: {}}, (err, cached) ->
          expect(cached).to.eql value
          done(err)

    it 'gets nothing', (done) ->
      store.get {url: '/users', headers: {}}, (err, cached) ->
        expect(cached).to.be undefined
        done(err)

    it 'deletes nothing', (done) ->
      store.delete {url: '/users', headers: {}}, (err, cached) ->
        expect(cached).to.be undefined
        done(err)

  describe 'with value cached', ->
    {value} = {}
    beforeEach (done) ->
      value = createdAt: Date.now(), headers: {etag: 'abc'}
      store.set {url: '/users', headers: {}}, value, (err) ->
        store.set {url: '/users/username', headers: {}}, value, done

    it 'gets value', (done) ->
      store.get {url: '/users', headers: {}}, (err, cached) ->
        expect(cached).to.eql value
        done(err)

    it 'deletes value', (done) ->
      store.delete {url: '/users', headers: {}}, (err, cached) ->
        expect(cached).to.eql value
        store.get {url: '/users', headers: {}}, (err, cached) ->
          expect(cached).to.be undefined
          done(err)

    it 'deletes multiple with regex path', (done) ->
      store.delete {url: new RegExp('^/us'), headers: {}}, (err, cached) ->
        expect(cached).to.eql [value, value]
        store.get {url: '/users', headers: {}}, (err, cached) ->
          expect(cached).to.be undefined
          done(err)
