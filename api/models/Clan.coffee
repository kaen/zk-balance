module.exports =
  attributes:
    name:
      type: 'string'
      required: true
      primaryKey: true
      unique: true

    score:
      type: 'float'

    winRate:
      type: 'float'

    wins:
      type: 'integer'

    losses:
      type: 'integer'

    opponentWinRate:
      type: 'float'

  findAllOpponents: (clan)->
    where =
      or:
        loser: clan
        winner: clan

    ClanMatch.find(where: where)
