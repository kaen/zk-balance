module.exports.bootstrap = (cb)->
  sails.log.info "Autorefresh: #{sails.config.zkbalance.autoRefresh}"
  setTimeout(github.beginAutoRefresh, 10000) if sails.config.zkbalance.autoRefresh
  setTimeout(BattleScraper.beginAutoRefresh, 10000) if sails.config.zkbalance.autoRefresh
  cb()
