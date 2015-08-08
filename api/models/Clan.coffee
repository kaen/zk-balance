module.exports =
  attributes:
    name:
      type: 'string'
      required: true
      primaryKey: true
      unique: true

    score:
      type: 'integer'
      default: 0
