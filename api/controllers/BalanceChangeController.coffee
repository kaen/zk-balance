###*
# ShipController
#
# @description :: Server-side logic for managing Players
# @help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports =
  find: (req, res)->
    page = req.param('page') || 0
    BalanceChange.find(sort: 'date DESC', skip: 20 * (page-1), limit: 20).populate('commit').populate('unit')
      .then (balanceChanges) ->
        res.json balanceChanges
      .error (err) ->
        res.json { error: err.message }, 400
