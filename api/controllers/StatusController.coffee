###*
# ShipController
#
# @description :: Server-side logic for managing Players
# @help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports =
  significantAttributes: (req, res)->
    res.json sails.config.zk.SIGNIFICANT_ROOT_KEYS

  commitRange: (req, res)->
    oldest = Commit.find(sort: 'date ASC').limit(1)
    newest = Commit.find(sort: 'date DESC').limit(1)
    Promise.all([oldest, newest])
      .spread (oldest, newest)->
        res.json oldest: oldest[0], newest: newest[0]
