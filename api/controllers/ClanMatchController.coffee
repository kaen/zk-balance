module.exports =
  find: (req, res)->
    page = req.param('page') || 0
    ClanMatch.find(sort: 'date DESC', skip: 20 * (page-1), limit: 20)
      .then (clanMatches) ->
        res.json clanMatches
      .error (err) ->
        res.json { error: err.message }, 400