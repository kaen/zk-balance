# app.coffee

# Use `app.coffee` to run your app without `sails lift`.
# To start the server, run: `coffee app.coffee`.

# This is handy in situations where the sails CLI is not relevant or useful.

# For example:
# => `coffee app.coffee`
# => `forever start -c coffee app.coffee`
# => `coffee --nodejs debug app.coffee`
# => `modulus deploy`
# => `heroku scale`


# The same command-line arguments are supported, e.g.:
# `coffee app.coffee --silent --port=80 --prod`

require 'coffee-script'

try
  sails = require("sails")
catch e
  console.error "To run an app using `coffee app.coffee`, you usually need to have a version of `sails` installed in the same directory as your app."
  console.error "To do that, run `npm install coffee-script sails`"
  console.error ""
  console.error "Alternatively, if you have sails installed globally (i.e. you did `npm install -g sails coffee-script`), you can use `sails lift`."
  console.error "When you run `sails lift`, your app will still use a local `./node_modules/sails` dependency if it exists,"
  console.error "but if it doesn't, the app will run with the global sails instead!"
  return

if sails?
  try
    rc = require("rc")
  catch e0
    try
      rc = require("sails/node_modules/rc")
    catch e1
      console.error "Could not find dependency: `rc`."
      console.error "Your `.sailsrc` file(s) will be ignored."
      console.error "To resolve this, run:"
      console.error "npm install rc --save"
      rc = ->
        {}

  # Start server
  sails.lift hooks: { sockets: false, pubsub: false }
