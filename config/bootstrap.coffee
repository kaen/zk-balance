module.exports.bootstrap = (cb)->
  sails.log.info "Autorefresh: #{sails.config.zkbalance.autoRefresh}"
  github.beginAutoRefresh() if sails.config.zkbalance.autoRefresh
  BattleScraper.beginAutoRefresh() if sails.config.zkbalance.autoRefresh
  cb()
