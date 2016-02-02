


# Sort the players by position
def getPositions(players, site):
	pgs = []
	pfs = []
	sgs = []
	sfs = []
	cs = []
	for key in players:
		pos = players[key].POS[site]
		if pos == 'PG':
			pgs.append(players[key])
		elif pos == 'PF':
			pfs.append(players[key])
		elif pos == 'SG':
			sgs.append(players[key])
		elif pos == 'SF':
			sfs.append(players[key])
		elif pos == 'C':
			cs.append(players[key])
	return pgs, sgs, sfs, pfs, cs

# Sort players by points/cost
def sortDoubles(players, site):
	return sorted(players, key=lambda x: (x.EFF[site]*x.WEIGHT, x.WEIGHT), reverse=True)

def sortTournaments(players, z, site):
	return sorted(players, key=lambda x: ((x.SCORE[site] + z*pow(x.VAR,0.5))/x.SALARY[site], x.TOURN_WEIGHT), reverse=True)

def savePosition(players, filename, site):
	with open(filename, 'w') as f:
		for player in players:
			output = '%s, %0.4f, %0.4f, %0.4f,\n' % (player.NAME, player.SCORE[site], player.VAR, player.SALARY[site])
			f.write(output)

def run(players, contest, n):

	sites = ['fd', 'dk']
	for site in sites:
		pgs, sgs, sfs, pfs, cs = getPositions(players, site)

		if contest != 'tournament':
			# Lineups for doubles (low variance)
			pgs = sortDoubles(pgs, site)
			pfs = sortDoubles(pfs, site)
			sgs = sortDoubles(sgs, site)
			sfs = sortDoubles(sfs, site)
			cs = sortDoubles(cs, site)
		if contest != 'double':
			# Lineups for tournaments (high variance)
			z = 1 # Z-index to use when weighting by standard deviation
			pgs = sortTournaments(pgs,z, site)
			pfs = sortTournaments(pfs,z, site)
			sgs = sortTournaments(sgs,z, site)
			sfs = sortTournaments(sfs,z, site)
			cs = sortTournaments(cs,z, site)

		savePosition(pgs[0:n], 'positions/'+site+'_pgs.csv', site)
		savePosition(sgs[0:n], 'positions/'+site+'_sgs.csv', site)
		savePosition(sfs[0:n], 'positions/'+site+'_sfs.csv', site)
		savePosition(pfs[0:n], 'positions/'+site+'_pfs.csv', site)
		savePosition(cs[0:n], 'positions/'+site+'_cs.csv', site)
