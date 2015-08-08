cheerio = require 'cheerio'
request = require 'request-promise'
moment = require 'moment'

BATTLES_URL = 'http://zero-k.info/Battles'
BATTLES_DETAIL_URL = 'http://zero-k.info/Battles/Detail/'
BATTLE_DATE_REGEX = /replays\/(\d+_\d+)_/
BATTLE_DATE_FORMAT = 'YYYYMMDD_HHmmss'
CLAN_REGEX = /clans\/(.+)\.png/

class BattleScraper
  constructor: ->
    @offset = 0
    @battleIds = []
    @done = false

  ingestBattles: =>
    return if @done
    @promiseBattleId()
      .then @ingestBattle
      .then @ingestBattles

  ingestBattle: (battleId)=>
    request.get("#{BATTLES_DETAIL_URL}/#{battleId}")
      .then @scrapeBattle

  scrapeBattle: (html)=>
    $ = cheerio.load html
    winner = @guessClan $('.battle_winner')
    loser = @guessClan $('.battle_loser')
    date = @parseDate $('a:contains("Manual download")').get(0)
    Clan.findOrCreate(name: winner)
      .then sails.log.debug
      .then Clan.findOrCreate(name: loser)
      .then sails.log.debug
      .then (=> ClanMatch.create winner: winner, loser: loser, date: date)
      .then sails.log.debug

  guessClan: (el)=>
    sails.log.debug el.find('img[src*="clan"]').attr('src')
    clans = el.find('img[src*="clan"]').map (i, el)->
      el.attribs.src.match(CLAN_REGEX)[1] || 'Unknown'

    counts = { }
    bestClan = 'Unknown'
    bestCount = -1
    for clan in clans
      if counts[clan]
        counts[clan]++
      else
        counts[clan] = 0

      if counts[clan] > bestCount
        bestCount = counts[clan]
        bestClan = clan

    bestClan

  parseDate: (el)=>
    moment(el.attribs.href.match(BATTLE_DATE_REGEX)[1], BATTLE_DATE_FORMAT).toDate()

  promiseBattleId: =>
    return Promise.resolve(undefined) if @done
    return @promiseBattleIds().then @promiseBattleId if @battleIds.length == 0
    battle = @battleIds.splice(0, 1)[0]
    Promise.resolve(battle) 

  promiseBattleIds: =>
    form =
      battleTitle: 'clan'
      age: 'All Time'
      mission: 'No'
      bots: 'No'
      offset: @offset

    request.post BATTLES_URL, form: form
      .then @parseBattleIds
      .then @countBattleIds
      .then @checkIfDone

  parseBattleIds: (html)=>
    $ = cheerio.load html
    @battleIds = $('a').map (i, el)->
      el.attribs.href.match(/\d+/)[0]

  countBattleIds: (battleIds)=>
    @offset += battleIds.length
    battleIds

  checkIfDone: (battleIds)=>
    @done = true unless battleIds && battleIds.length > 0
    battleIds

module.exports = BattleScraper