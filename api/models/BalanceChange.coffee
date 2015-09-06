module.exports =
  attributes:
    file:
      type: 'string'

    author:
      type: 'string'

    unit:
      model: 'Unit'
      index: true

    fileDelta:
      type: 'string'

    beforeUnitDef:
      type: 'string'

    afterUnitDef:
      type: 'string'

    unitDefDelta:
      type: 'string'

    significant:
      type: 'boolean'
      index: true

    commit:
      model: 'Commit'
      index: true
