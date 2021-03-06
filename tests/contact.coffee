Task = require '../server/models/task'

fixtures = require './fixtures/data'
fs = require 'fs'
helpers = require './helpers'
expect = require('chai').expect

describe 'Contacts', ->

    before helpers.startServer
    before helpers.clearDb
    before helpers.createContact fixtures.contact1

    before helpers.makeTestClient
    after  helpers.killServer

    describe 'Index - GET /', ->

        it 'should allow requests', (done) ->
            # getLocale is very long, this need to be fixed
            @timeout 10000
            @client.get '/', done, false

        it 'should reply with the index.html file', ->
            expect(@err).to.not.exist
            expect(@body).to.have.string 'window.locale = '

    describe 'List - GET /contacts', ->

        it 'should allow requests', (done) ->
            @client.get 'contacts', done

        it 'should reply with the list of contacts', ->
            expect(@body).to.be.an 'array'
            expect(@body).to.have.length 1
            expect(@body[0].id).to.exist
            expect(@body[0].fn).to.equal fixtures.contact1.fn
            @id = @body[0].id

    describe 'Read - GET /contacts/:id', ->

        it 'should allow requests', (done) ->
            @client.get "contacts/#{@id}", done

        it 'should reply with one contact', ->
            expect(@body.fn).to.equal fixtures.contact1.fn
            expect(@body.note).to.equal fixtures.contact1.note
            expect(@body.id).to.exist

    describe 'Create - POST /contacts', ->

        contact =
            name: 'Jane Smith'

        it 'should allow requests', (done) ->
            @client.post 'contacts', contact, done

        it 'should reply with the created contact', ->
            expect(@body.fn).to.equal contact.fn
            expect(@body.id).to.exist
            @id = @body.id

    describe 'Update - PUT /contacts/:id', ->

        update =
            note: 'funny guy'

        it 'should allow requests', (done) ->
            @client.put "contacts/#{@id}", update, done

        it 'should reply with the updated album', ->
            expect(@body.note).to.equal update.note

        it 'when I GET the album', (done) ->
            @client.get "contacts/#{@id}", done

        it 'then it is changed', ->
            expect(@body.note).to.equal update.note

    describe 'Create task - POST /contacts/:id/new-call-task', ->

        it 'should allow requests', (done) ->
            @client.post "contacts/#{@id}/new-call-task", {}, done

        it 'should reply with 201 status', ->
            expect(@response.statusCode).to.equal 201

        it 'when I fetch tasks', (done) ->
            Task.all (err, tasks) =>
                @task = tasks[0]
                done()

        it 'then i get one with correct description', ->
            expect(@task.description).to.equal "Contact undefined #followup"

    describe 'Delete - DELETE /contacts/:id', ->

        it 'should allow requests', (done) ->
            @client.del "contacts/#{@id}", done

        it 'should reply with 204 status', ->
            expect(@response.statusCode).to.equal 204

        it 'when I GET the contact', (done) ->
            @client.get "contacts/#{@id}", done

        it 'then i get an error', ->
            expect(@response.statusCode).to.equal 404


