fs = require 'fs'
Readable = require('stream').Readable

TEMPLATE = fs.readFileSync './assets/lua/unitdef_extractor.lua'
spawn = require('child_process').spawn
module.exports = 
  # this doesn't seem like a bad idea at all!
  evalUnitDef: (content)->
    luaScript = TEMPLATE.toString().replace('UNIT_DEF_GOES_HERE', "\n#{content}\n")
    child = spawn('lua', ['-'])

    new Promise (resolve, reject)->
      result = ''
      child.stdout.on 'data', (data)->
        result += data.toString()

      err = ''
      child.stderr.on 'data', (data)->
        err += data.toString()

      child.stdout.on 'close', (ev)->
        try
          resolve(JSON.parse(result))
        catch e
          sails.log.error "Error parsing JSON: #{e}"
          sails.log.error content
          resolve({})

      child.on 'error', (err)->
        sails.log.error err
        reject(err)

      child.stdin.write(luaScript)
      child.stdin.end()
