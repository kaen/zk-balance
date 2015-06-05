module.exports =
  attributes:
    file:
      type: 'string'
      required: true

    author:
      type: 'string'
      required: true

    unit:
      model: 'Unit'
      required: true
      index: true

    fileDelta:
      type: 'string'
      required: true

    beforeUnitDef:
      type: 'string'
      required: true

    afterUnitDef:
      type: 'string'
      required: true

    unitDefDelta:
      type: 'string'
      required: true

    significant:
      type: 'boolean'
      required: true
      index: true

    commit:
      model: 'Commit'
      required: true
      index: true
