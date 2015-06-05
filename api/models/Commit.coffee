module.exports =
  attributes:
    sha:
      type: 'string'
      primaryKey: true
      unique: true
      required: true

    message:
      type: 'string'

    author:
      type: 'string'

    date:
      type: 'date'
      required: true
      index: true
