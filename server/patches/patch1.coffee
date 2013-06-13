Contact = require '../models/contact'
async = require 'async'

module.exports = (callback) ->

    # fix contacts created before vcf import
    Contact.rawRequest 'all', (err, contacts) ->
        return callback err if err

        async.forEachSeries contacts, (contact, cb) ->

            contact = contact.value

            return cb null if contact.fn

            console.log "converting #{contact.name}"

            # this is an old contact
            data = {}
            data.fn   = contact.name
            data.note = contact.notes + "\n"

            # just save the data in note
            for dp in contact.datapoints
                data.note += dp.name + " " + dp.type + " " + dp.value + "\n"

            # create new contact, delete old
            Contact.create data, (err) ->
                return console.log(err.stack) if err

                # raw destroy because we don't have the model
                Contact.find contact._id, (err, contact) ->
                    return console.log(err.stack) if err

                    contact.destroy cb
        , callback
