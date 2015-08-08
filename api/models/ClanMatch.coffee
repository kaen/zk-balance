module.exports =
  attributes:
    date:
      type: 'date'
      required: true
      index: true
      
    title:
      type: 'string'

    winner:
      model: 'Clan'
      required: true

    loser:
      model: 'Clan'
      required: true
