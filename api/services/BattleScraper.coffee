cheerio = require 'cheerio'
request = require 'request-promise'
moment = require 'moment'

BATTLES_URL = 'http://zero-k.info/Battles'
BATTLES_DETAIL_URL = 'http://zero-k.info/Battles/Detail/'
BATTLE_DATE_REGEX = /replays\/(\d+_\d+)_/
BATTLE_DATE_FORMAT = 'YYYYMMDD_HHmmss'
BATTLE_START_DATE = '2015-07-17'
SATURDAY = 6
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
      .then((html)=> @scrapeBattle html, battleId)

  scrapeBattle: (html, battleId)=>
    $ = cheerio.load html
    winner = @guessClan $('.battle_winner')
    loser = @guessClan $('.battle_loser')
    date = @parseDate $('a:contains("Manual download")').get(0)

    unless @filterBattle(winner, loser, date)
      return sails.log.debug "Skipping battle #{battleId}"

    sails.log.debug "Creating battle #{battleId}"
    Clan.findOrCreate(name: winner)
      .then sails.log.debug
      .then Clan.findOrCreate(name: loser)
      .then sails.log.debug
      .then (=> ClanMatch.findOrCreate battleId)
      .then ((clan)=> ClanMatch.update battleId, winner: winner, loser: loser, date: date)
      .then sails.log.debug

  filterBattle: (winner, loser, date)=>
    winner != 'Unknown' and
    loser != 'Unknown' and
    moment(date).isAfter(BATTLE_START_DATE) and
    moment(date).day() == SATURDAY

  guessClan: (el)=>
    clans = el.find('img[src*="clan"]').map (i, el)->
      el.attribs.src.match(CLAN_REGEX)[1] || 'Unknown'

    counts = { }
    # We return unknown unless there are *at least* two players from the same
    # clan on the same team
    bestClan = 'Unknown'
    bestCount = 1
    for clan in clans
      sails.log.debug clan
      if counts[clan]
        counts[clan]++
      else
        counts[clan] = 1

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
      battleTitle: 'GBC'
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