

###
### Scrape data from websites and organize it into classes
###

from lxml import html
import sys, requests, json, socks, socket, pickle, os.path, time
from fake_useragent import UserAgent
from defense import Defense
from player import Player

## Relevant URLS ##
# Current Player Stats #
defenseURL = 'http://stats.nba.com/stats/leaguedashteamstats?Conference=&DateFrom=&DateTo=&Division=&GameScope=&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Opponent&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=PerGame&Period=0&PlayerExperience=&PlusMinus=N&Rank=N&Season=2015-16&SeasonSegment=&SeasonType=Regular+Season&ShotClockRange=&StarterBench=Starters&TeamID=0&VsConference=&VsDivision=&PlayerPosition='
defenseFG3URL = 'http://stats.nba.com/stats/leaguedashptteamdefend?DefenseCategory=3+Pointers&LastNGames=0&LeagueID=00&Month=0&OpponentTeamID=0&PORound=0&PerMode=PerGame&Period=0&Season=2015-16&SeasonType=Regular+Season&TeamID=0'
defenseFG2URL = 'http://stats.nba.com/stats/leaguedashptteamdefend?DefenseCategory=2+Pointers&LastNGames=0&LeagueID=00&Month=0&OpponentTeamID=0&PORound=0&PerMode=PerGame&Period=0&Season=2015-16&SeasonType=Regular+Season&TeamID=0'
playerStatsURL = 'http://stats.nba.com/stats/leaguedashplayerstats?College=&Conference=&Country=&DateFrom=&DateTo=&Division=&DraftPick=&DraftYear=&GameScope=&GameSegment=&Height=&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=PerGame&Period=0&PlayerExperience=&PlayerPosition=&PlusMinus=N&Rank=N&Season=2015-16&SeasonSegment=&SeasonType=Regular+Season&ShotClockRange=&StarterBench=&TeamID=0&VsConference=&VsDivision=&Weight=&LastNGames='

# 2014-15 stats #
# defenseURL = 'http://stats.nba.com/stats/leaguedashteamstats?Conference=&DateFrom=&DateTo=&Division=&GameScope=&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Opponent&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=PerGame&Period=0&PlayerExperience=&PlayerPosition=&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Regular+Season&ShotClockRange=&StarterBench=&TeamID=0&VsConference=&VsDivision='
# defenseFG3URL = 'http://stats.nba.com/stats/leaguedashptteamdefend?DefenseCategory=3+Pointers&LastNGames=0&LeagueID=00&Month=0&OpponentTeamID=0&PORound=0&PerMode=PerGame&Period=0&Season=2014-15&SeasonType=Regular+Season&TeamID=0'
# defenseFG2URL = 'http://stats.nba.com/stats/leaguedashptteamdefend?DefenseCategory=2+Pointers&LastNGames=0&LeagueID=00&Month=0&OpponentTeamID=0&PORound=0&PerMode=PerGame&Period=0&Season=2014-15&SeasonType=Regular+Season&TeamID=0'
# playerStatsURL = 'http://stats.nba.com/stats/leaguedashplayerstats?College=&Conference=&Country=&DateFrom=&DateTo=&Division=&DraftPick=&DraftYear=&GameScope=&GameSegment=&Height=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=PerGame&Period=0&PlayerExperience=&PlayerPosition=&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Regular+Season&ShotClockRange=&StarterBench=&TeamID=0&VsConference=&VsDivision=&Weight='


## Route http requests through TOR with random user agent ##
ua = UserAgent()

def getPage(url, headers={}):
	global ua
	request_headers = {
		'User-Agent': ua.chrome,
	}
	request_headers.update(headers)
	return requests.get(url, headers = request_headers).text

def testConn():
	print('Connecting through ' + getPage('http://icanhazip.com'))

def startConn():
	socks.set_default_proxy(socks.SOCKS5, "localhost", 9050)
	socket.socket = socks.socksocket
	testConn()

# Fanduel uses . in abbreviations, nba doesn't
def parseName(name):
	nbaNames = {
		'Ishmael Smith': 'Ish Smith',
		'Brad Beal': 'Bradley Beal',
		'Nene Hilario': 'Nene',
		'Patrick Mills': 'Patty Mills',
		'OJ Mayo': 'O.J. Mayo',
		'Louis Williams': 'Lou Williams',
		'JR Smith': 'J.R. Smith',
		'Larry Nance Jr': 'Larry Nance Jr.',
		'Joseph Young': 'Joe Young',
	}
	name = name.replace('.', '')
	if name in nbaNames:
		name = nbaNames[name]
	return name

# Remove people who aren't playing
def cleanLineup(players):
	removedTeams = [
		'',#'IND', 'CLE', 'LAL', 'NYK'
	]
	for n in reversed(range(len(players))):
		if 0 in (players[n]['played'], players[n]['points'], players[n]['salary']) or players[n]['opponent'] in removedTeams:
			del players[n]
	return players


def getFdLineups(dataFile, playerList):
	with open(dataFile) as f:
		data = json.load(f)
	players = data['players']
	fixtures = data['fixtures']
	teams = data['teams']
	names = [player['first_name'] + ' ' + player['last_name'] for player in players if player['injury_details'] is None]
	positions = [player['position'] for player in players if player['injury_details'] is None]
	salaries = [player['salary']/1000.0 for player in players if player['injury_details'] is None]
	points = [player['fppg'] for player in players if player['injury_details'] is None]
	statURLs = [player['player_card_url'] for player in players if player['injury_details'] is None]
	played = [0 if player['played'] is None else player['played'] for player in players if player['injury_details'] is None]

	## Get Opponents ##
	teamIds = [player['team']['_members'][0] for player in players if player['injury_details'] is None]
	opponentIds = []
	for teamId in teamIds:
		for fixture in fixtures:
			if fixture['away_team']['team']['_members'][0] == teamId:
				opponentIds.append(fixture['home_team']['team']['_members'][0])
				break
			if fixture['home_team']['team']['_members'][0] == teamId:
				opponentIds.append(fixture['away_team']['team']['_members'][0])
				break
	opponents = []
	for opponentId in opponentIds:
		opponents.append([team['code'] for team in teams if team['id'] == opponentId][0].upper())

	players = []
	for n in range(len(names)):
		if playerList is not None:
			if names[n] not in playerList:
				continue
		players.append({
			'name': parseName(names[n]),
			'position': positions[n],
			'salary': salaries[n],
			'points': points[n],
			'played': played[n],
			'statURL': statURLs[n],
			'opponent': opponents[n]
		})

	players = cleanLineup(players)

	## Get variances ##

	for player in players:
		print(player['name'])
		parts = player['statURL'].split('/')
		statURL = 'http://www.fanduel.com/eg/Player/' + parts[-3] + '/Stats/getPlayerData/' + parts[-1]
		confirmed = False
		while not confirmed:
			try:
				statPage = getPage(statURL, {'X-FD-SCRIPTING': 'hunter.rew@gmail.com'})
				time.sleep(2)
				stats = json.loads(statPage)
				confirmed = True
			except ValueError:
				pass
		stats = stats['player']
		n = min(10, player['played'])
		x_avg = 0
		x2_avg = 0
		m = 0
		for game in stats['gamestats']:
			if float(game['Minutes']) != 0:
				x_avg += float(game['Fantasy Pts'])/n
				x2_avg += pow(float(game['Fantasy Pts']),2)/n
				m += 1
				if m == n:
					break

		player['variance'] = x2_avg - pow(x_avg,2)
		if player['variance'] < 0:
			print(player['name'])
			for game in stats['gamestats'][0:n]:
				print(float(game['Fantasy Pts']))
			sys.exit()


	return players

def getDkLineups(dataFile, playerList):
	with open(dataFile) as f:
		data = json.load(f)
	players = []
	for player in data['playerList']:
		players.append({
			'name': parseName(player['fn'] + ' ' + player['ln']),
			'position': player['pn'],
			'salary': player['s']/1000
			})
	return players

def joinSites(fd, dk):
	for player in fd:
		found = False
		for dkPlayer in dk:
			if dkPlayer['name'] == player['name']:
				player['dk_salary'] = dkPlayer['salary']
				player['dk_position'] = dkPlayer['position']
				found = True
				break
		if not found:
			print('could not find ' + player['name'] + ' on DK')
			player['dk_salary'] = 0
			player['dk_position'] = 'NA'
	return fd

def getLineups(playerFile, playerList):
	backup = 'games/players_backup.p'
	if playerList is None and os.path.exists(backup):
		return pickle.load(open(backup, 'rb'))
	else:
		fdPlayers = getFdLineups('games/fd.json', playerList)
		#dkPlayers = getDkLineups('games/dk.json', playerList)
		dkPlayers = [];
		players = joinSites(fdPlayers, dkPlayers)
		pickle.dump(players, open(backup, 'wb'), protocol=3)
		return players


def getTeamIds(teams, data):
	nba = {
		'PHO': 'PHX',
		'GS': 'GSW',
		'SA': 'SAS',
		'NY': 'NYK',
		'NO': 'NOP'
	}
	# Check for names that need to be converted
	# for team in teams:
	# 	if team in nba:
	# 		team = nba[team]
	# 	x = 0
	# 	for row in data:
	# 		if row[3] == team:
	# 			x = 1
	# 			break
	# 	if x == 0:
	# 		print(team)

	teamIds = []
	for team in teams:
		if team in nba:
			team = nba[team]
		teamIds.append(next(row[2] for row in data if team == row[3]))
	return teamIds

# Get rid of players we don't have stats for
def removeUnknown(players, data):
	for n in reversed(range(len(players))):
		if players[n]['name'] not in data:
				print('Could not find ' + players[n]['name'])
				del players[n]
	return players

# Only keep stats of players playing
def removeUnused(targets, data, idx):
	for n in reversed(range(len(data))):
		val = data[n][idx];
		if val not in targets:
			del data[n]
	return data

# Scrape the player data
def getPlayerData(names, n):
	
	page = getPage(playerStatsURL + str(n))
	data = json.loads(page)
	data = data['resultSets'][0]['rowSet']
	# data = removeUnused(names, data, 1)
	return data
	
# Organize the stats from the data
def getPlayerStats(names, data):
	# stat indices in data
	gp = 5
	mins = 9
	fgm = 10
	fga = 11
	fg3m = 13
	fg3a = 14
	ftm = 16
	rbd = 21
	ast = 22
	tov = 23
	stl = 24
	blk = 25
	statsAll = []
	for name in names:
		stats = []
		n = [i for i,val in enumerate(data) if name in val]
		n = n[0]
		fg3prc = 0 if data[n][fg3m] == 0 else data[n][fg3m]/data[n][fg3a] # 3 points made / attempts
		fg3pt = (data[n][fg3a], fg3prc)
		fg2a = data[n][fga] - data[n][fg3a] # total - 3 pointers
		fg2m = data[n][fgm] - data[n][fg3m]
		fg2prc = 0 if fg2m == 0 else fg2m/fg2a
		fg2pt = (fg2a, fg2prc)
		stats.extend([
			data[n][gp],
			data[n][mins],
			fg3pt, 
			fg2pt, 
			data[n][ftm], 
			data[n][rbd], 
			data[n][ast], 
			data[n][blk], 
			data[n][stl], 
			data[n][tov]
		])
		statsAll.append(stats)
	return statsAll

# Opposing team stats
def getDefenseStats(opps):
	#indices for stats
	fg3_diff = 10
	fg2_diff = 10
	rbd = 18
	ast = 19
	tov = 20
	stl = 21
	blk = 22
	page = getPage(defenseURL)
	page3 = getPage(defenseFG3URL)
	page2 = getPage(defenseFG2URL)
	data = json.loads(page)
	data = data['resultSets'][0]['rowSet']
	data3 = json.loads(page3)
	data3 = data3['resultSets'][0]['rowSet']
	data2 = json.loads(page2)
	data2 = data2['resultSets'][0]['rowSet']
	# Find the percent different from the average for each stat for modifying players
	nTeams = len(data)
	rbd_avg = sum([team[rbd]/nTeams for team in data])
	ast_avg = sum([team[ast]/nTeams for team in data])
	blk_avg = sum([team[blk]/nTeams for team in data])
	stl_avg = sum([team[stl]/nTeams for team in data])
	tov_avg = sum([team[tov]/nTeams for team in data])
	data = removeUnused(opps, data, 0)
	data3 = removeUnused(opps, data3, 0)
	data2 = removeUnused(opps, data2, 0)
	
	statsAll = {}
	for opp in set(opps):
		stats = []
		n = [i for i,val in enumerate(data) if opp in val]
		n = n[0]
		n2 = [i for i,val in enumerate(data2) if opp in val]
		n2 = n2[0]
		n3 = [i for i,val in enumerate(data3) if opp in val]
		n3 = n3[0]
		stats.extend([
			data3[n3][fg3_diff],
			data2[n2][fg2_diff],
			data[n][rbd]/rbd_avg - 1,
			data[n][ast]/ast_avg - 1,
			data[n][blk]/blk_avg - 1,
			data[n][stl]/stl_avg - 1,
			data[n][tov]/tov_avg - 1
		])
		statsAll[opp] = stats
	# Most of these stats need to be normalized to the average of all teams
	return statsAll

# Store defense data in objects
def getDefenses(opp_names, opp_ids, stats):
	defenses = {}
	for n in range(len(opp_ids)):
		defense = Defense(
			opp_ids[n],
			opp_names[n], 
			stats[opp_ids[n]][0],
			stats[opp_ids[n]][1],
			stats[opp_ids[n]][2],
			stats[opp_ids[n]][3],
			stats[opp_ids[n]][4],
			stats[opp_ids[n]][5],
			stats[opp_ids[n]][6]
		)
		defenses[opp_names[n]] = defense
	return defenses

#store the player data in objects
def getPlayers(players_list, stats, defenses):
	players = {}
	for n in range(len(players_list)):
		player = Player(
			players_list[n]['name'],
			players_list[n]['position'],
			players_list[n]['dk_position'],
			players_list[n]['salary'],
			players_list[n]['dk_salary'],
			players_list[n]['variance'],
			stats[n][0],
			stats[n][1],
			stats[n][2],
			stats[n][3],
			stats[n][4],
			stats[n][5],
			stats[n][6],
			stats[n][7],
			stats[n][8],
			stats[n][9]
		)
		player.setOpponent(defenses[players_list[n]['opponent']])
		player.calcScore()
		players[players_list[n]['name']] = player
	return players

# This runs first and calls everything else
def getData(nGames, player_list):
	players = getLineups('games/fd.json', player_list)
	data = getPlayerData([player['name'] for player in players], nGames)
	players = removeUnknown(players, [a[1] for a in data])
	stats = getPlayerStats([player['name'] for player in players], data)
	opponent_ids = getTeamIds([player['opponent'] for player in players], data)
	opponent_stats = getDefenseStats(opponent_ids)

	defenses = getDefenses([player['opponent'] for player in players], opponent_ids, opponent_stats)
	players = getPlayers(players, stats, defenses) # put into classes

	return players, defenses
