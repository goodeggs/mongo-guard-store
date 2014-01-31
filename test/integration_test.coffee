mongoose = require 'mongoose'
expect = require 'expect.js'
guard = require 'connect-guard'
request = require 'supertest'
express = require 'express'
sinon = require 'sinon'
MongoGuardStore = require '../'

describe 'connect-guard with mongo-guard-store', ->
  before ->
    mongoose.connect 'mongodb://localhost/mongo-guard-store_test'
  after ->
    mongoose.disconnect()

  {store, app, controller, lastModified} = {}
  beforeEach (done) ->
    lastModified = new Date().toUTCString()
    store = new MongoGuardStore()
    store.drop (err) ->
      guard.configure {store}
      controller = sinon.spy (req, res) ->
        res
          .set 'Last-Modified', lastModified
          .send 'Users'
      app = express()
        .use guard.middleware(maxAge: 300)
        .get '/users', controller
      done err

  requestWithIfModified = (done) ->
    request(app)
      .get('/users')
      .set('If-Modified-Since', lastModified)
      .expect(304, done)

  describe 'with no cached headers', ->
    describe 'a request for a guarded url', ->
      beforeEach requestWithIfModified
      it 'hits the controller', ->
        expect(controller.called).to.be.ok()

  describe 'with cached headers', ->
    beforeEach requestWithIfModified
    describe 'a request for a guarded url', ->
      beforeEach (done) ->
        controller.reset()
        requestWithIfModified done

      it 'skips the controller', ->
        expect(controller.called).not.to.be.ok()
