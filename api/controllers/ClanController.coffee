module.exports =
  find: (req, res)->
    page = req.param('page') || 0
    Clan.find(sort: 'score DESC', skip: 20 * (page-1), limit: 20)
      .then (clans) ->
        res.json clans
      .error (err) ->
        res.json { error: err.message }, 400