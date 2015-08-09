class ClanScoreCalculator
  constructor: ->

  calculate: =>
    Clan.find().then((x)=> x)
      .each @updateWinRate
      .each @updateOpponentWinRate
      # .each @updateOpponentOpponentWinRate
      .each @scoreClan
      .done()

  updateWinRate: (clan)=>
    Promise.join ClanMatch.count(winner: clan.name), ClanMatch.count(loser: clan.name), (wins, losses)=>
      sails.log.debug "#{clan.name} Record: #{wins} - #{losses}"
      winRate = wins / (wins + losses) or 0
      Clan.update(clan.name, winRate: winRate, wins: wins, losses: losses)

  updateOpponentWinRate: (clan)=>
    @findOpponents(clan)
      .map((opponent)=> @calculateRecordExcluding(opponent, clan))
      .then @calculateWinRateFromRecords
      .then (opponentWinRate)=>
        sails.log.debug "#{clan.name} Opponent Win Rate: #{opponentWinRate}"
        Clan.update(clan.name, opponentWinRate: opponentWinRate)

  calculateWinRateFromRecords: (records)=>
    losses = 0
    wins = 0
    for record in records
      wins += record.wins
      losses += record.losses

    wins / (wins + losses) or 0

  calculateRecordExcluding: (clan, excluded)=>
    where =
      or: [{
          winner: clan.name
          loser:
            '!': excluded
        },{
          loser: clan.name
          winner:
            '!': excluded
      }]

    ClanMatch.find where: where
      .then (matches)=>
        sails.log.debug matches
        wins = 0
        losses = 0
        for match in matches
          wins++ if match.winner == clan.name
          losses++ if match.loser == clan.name
        { losses: losses, wins: wins}

  extractScoresByClan: (clanMatches)=>
    results = { } 
    for clanMatch in clanMatches
      winner = clanMatch.winner
      loser = clanMatch.loser
      results[winner] = results[winner] or { wins: 0, losses: 0 }
      results[loser] = results[loser] or { wins: 0, losses: 0 }
      results[winner].wins++
      results[loser].losses++
    results

  # weighted average by games played
  calculateWeightedAverageWinRate: (scoresByClan)=>
    totalGames = 0
    for score in scoresByClan
      totalGames += score.wins
      totalGames += score.losses

    winRate = 0
    for score in scoresByClan
      winRate += score.wins / (score.wins + score.losses) * (score.wins + score.losses) / totalGames

    winRate

  updateOpponentOpponentWinRate: (clan)=>
    wins = ClanMatch.find(winner: clan)
    losses = ClanMatch.find(loser: clan)
    clan.update(winRate: wins / (wins + losses))

  findOpponents: (clan)=>
    ClanMatch.find where: { or: [ { loser: clan.name }, { winner: clan.name } ] }
      .populate('loser')
      .populate('winner')
      .then @extractClans
      # filter clans to exclude ourselves
      .then (opponents)=>
        result = []
        for own name,opponent of opponents when name != clan.name
          result.push opponent
        sails.log.debug "Opponents of #{clan.name}", result
        result

  extractClans: (clanMatches)=>
    opponents = { }
    sails.log.debug clanMatches
    for clanMatch in clanMatches
      opponents[clanMatch.winner.name] = clanMatch.winner if clanMatch.winner
      opponents[clanMatch.loser.name] = clanMatch.loser if clanMatch.loser
    opponents

  scoreClan: (clan)=>
    Clan.findOne(clan.name)
      .then (clan)=>
        sails.log.debug "Scoring", clan
        score = (3 * clan.wins + clan.losses) * (.5 * clan.winRate + .5 * clan.opponentWinRate or 0)
        sails.log.debug "#{clan.name} score: #{score}"
        Clan.update clan.name, score: score 

ClanScoreCalculator.calculate = ->
  (new ClanScoreCalculator).calculate()

module.exports = ClanScoreCalculator