module.exports =
  attributes:
    name:
      type: 'string'
      primaryKey: true
      unique: true
      required: true
      index: true

    friendly_name:
      type: 'string'
      index: true

    balanceChanges:
      collection: 'BalanceChange'
      via: 'unit'

    image:
      type: 'string'

    unitDef:
      type: 'string'

    official:
      type: 'boolean'
