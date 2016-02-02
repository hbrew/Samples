import scrape, positions, pickle, os.path, sys
import adjustments as adj

def saveMatchups(players_dict, filename):
	players = []
	for name in players_dict:
		players.append(players_dict[name])
	with open(filename, 'w') as f:
		players = sorted(players, key=lambda x: x.PM['fd'], reverse=True)
		f.write('Player, Fanduel, Draftkings\n')
		for player in players:
			output = '%s, %0.2f, %0.2f\n' % (player.NAME, player.PM['fd'], player.PM['dk'])
			f.write(output)

def adjust(players, playersN, contestType):
	# Make adjustments to player stats
	if contestType == 'tournament':
		adjustments = adj.tournament()
	else:
		adjustments = adj.doubles()
		for name in players:
			# use season average or last n games, whichever is lowest
			if name in playersN:
				if players[name].SCORE['fd'] > playersN[name].SCORE['fd']:
					players[name] = playersN[name]
	
	for name in adjustments:
		if name in players:
			players[name].adjust(adjustments[name])

	## rule out teams for later tournys
	# out = [
	# 	1610612763, 1610612756
	# ]
	# for name in players:
	# 	players[name].removeTeam(out)

	return players

def getPlayers(playerFile, nGames):
	players = []
	if os.path.exists(playerFile):
		# Load saved player data
		players = pickle.load(open(playerFile, 'rb'))
		# Add missing players
		# players2, defense = scrape.getData(nGames, ['Joseph Young'])
		# for name in players2:
		# 	players[name] = players2[name]
		# pickle.dump(players, open(playerFile, 'wb'), protocol=3)

	else:
		# Scrape and save player data
		players, defenses = scrape.getData(nGames, None)
		pickle.dump(players, open(playerFile, 'wb'), protocol=3)

	return players

def main(suffix, contestType, nPerPosition, nGames):
	playerFile = 'games/players_' + suffix + '_n' + str(nGames) + '.p'
	playersN = getPlayers(playerFile, nGames)
	playerFile = 'games/players_' + suffix + '_n0.p'
	players = getPlayers(playerFile, 0)
	players = adjust(players, playersN, contestType)
	positions.run(players, contestType, nPerPosition)
	saveMatchups(players, 'predictions/matchups.csv')
	return players


if __name__ == "__main__":
   players = main(sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]))