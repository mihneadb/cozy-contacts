Contact = require '../server/models/contact'
Task = require '../server/models/task'
PCLog = require '../server/models/phone_communication_log'
ContactLog = require '../server/models/contact_log'
Config = require '../server/models/config'
Client = require('request-json').JsonClient

TESTPORT = process.env.PORT or 8013

module.exports =

    startServer: (done) ->
        @timeout 6000
        start = require '../server.coffee'
        start TESTPORT, (err, app, server) =>
            @server = server
            done err

    killServer: ->
        @server.close()

    clearDb: (done) ->
        Config.requestDestroy "all", ->
            Contact.requestDestroy "all", ->
                PCLog.requestDestroy "all", ->
                    Task.requestDestroy "all", ->
                        ContactLog.requestDestroy "all", done

    createContact: (data) -> (done) ->
        baseContact = new Contact(data)
        Contact.create baseContact, (err, contact) =>
            @contact = contact
            done err

    makeTestClient: (done) ->
        old = new Client "http://localhost:#{TESTPORT}/"

        store = this # this will be the common scope of tests

        callbackFactory = (done) -> (error, response, body) =>
            throw error if(error)
            store.response = response
            store.body = body
            done()

        clean = ->
            store.response = null
            store.body = null

        store.client =
            get: (url, done, parse) ->
                clean()
                old.get url, callbackFactory(done), parse
            post: (url, data, done) ->
                clean()
                old.post url, data, callbackFactory(done)
            put: (url, data, done) ->
                clean()
                old.put url, data, callbackFactory(done)
            del: (url, done) ->
                clean()
                old.del url, callbackFactory(done)
            sendFile: (url, path, done) ->
                old.sendFile url, path, callbackFactory(done)
            saveFile: (url, path, done) ->
                old.saveFile url, path, callbackFactory(done)

        done()
