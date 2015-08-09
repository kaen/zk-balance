module.exports =
  attributes:
    date:
      type: 'date'
      index: true
      
    title:
      type: 'string'

    winner:
      model: 'Clan'

    loser:
      model: 'Clan'
