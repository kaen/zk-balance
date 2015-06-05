###*
# ShipController
#
# @description :: Server-side logic for managing Players
# @help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports =
  findOne: (req, res)->
    name = req.param 'name'
    Unit.findOne(name: name)
      .then (unit)->
        BalanceChange.find(unit: unit.name).populate('commit')
          .then (balanceChanges)->
            unit = unit.toJSON()
            unit.balanceChanges = (change.toJSON() for change in balanceChanges)
            unit
      .then (unit)->
        res.json unit
      .error (err)->
        res.json { error: err.message }, 400

  find: (req, res)->
    Unit.find()
      .then (units) ->
        res.json units
      .error (err) ->
        res.json { error: err.message }, 400
