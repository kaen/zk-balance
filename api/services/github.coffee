github = {}
github.beginAutoRefresh = ->
  setTimeout github.refreshGithubData, 0
  setInterval github.refreshGithubData, 60 * 60 * 1000

module.exports = github
