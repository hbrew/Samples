

### Class for players

class Player:
	# Fanduel score multipliers
	fd_scoring = [
		3,	#fg3pt
		2,	#fg2pt
		1,	#ft
		1.2,	#rbd
		1.5,	#ast
		2,	#blk
		2,	#stl
		-1	#tov
	]

	dk_scoring = [
		3.5,
		2,
		1,
		1.25,
		1.5,
		2,
		2,
		-0.5
	]

	def __init__(self, name, pos, dk_pos, salary, dk_sal, variance, gp, mins, fg3pt, fg2pt, ft, rbd, ast, blk, stl, tov):
		self.NAME = name
		self.POS = {
			'fd': pos,
			'dk': dk_pos
		}
		self.SALARY = {
			'fd': salary,
			'dk': dk_sal
		}
		self.VAR = variance
		self.FG3PT = fg3pt # (attempted, percentage)
		self.FG2PT = fg2pt # (attempted, percentage)
		self.FT = ft
		self.RBD = rbd
		self.AST = ast
		self.BLK = blk
		self.STL = stl
		self.TOV = tov
		self.MIN = mins 
		self.GP = gp

	def setOpponent(self, opp):
		self.OPP = opp

	def calcScore(self):
		self.setAvgScore()
		self.setPlusMinus()
		self.SCORE = {
			'fd': self.AVG['fd'] + self.PM['fd'],
			'dk': self.AVG['dk'] + self.PM['dk']
		}
		self.setConsistency()
		self.setWeight()
		self.setError()
		self.setEfficiency()

	def setAvgScore(self):
		cats = [
			self.FG3PT[0]*self.FG3PT[1], 
			self.FG2PT[0]*self.FG2PT[1],
			self.FT,
			self.RBD,
			self.AST,
			self.BLK,
			self.STL,
			self.TOV
		]
		self.AVG = {
			'fd': sum([a*b for a,b in zip(cats, self.fd_scoring)]),
			'dk': sum([a*b for a,b in zip(cats, self.dk_scoring)])
		}

	def setPlusMinus(self):
		cats = [
			self.FG3PT[0]*self.OPP.FG3PT_DIFF, 
			self.FG2PT[0]*self.OPP.FG2PT_DIFF,
			0,
			self.RBD*self.OPP.RBD,
			self.AST*self.OPP.AST,
			self.BLK*self.OPP.BLK,
			self.STL*self.OPP.STL,
			self.TOV*self.OPP.TOV
		]
		self.PM = {
			'fd': sum([a*b for a,b in zip(cats, self.fd_scoring)]),
			'dk': sum([a*b for a,b in zip(cats, self.dk_scoring)])
		}

	def setConsistency(self):
		self.CNST = 0 if self.SCORE['fd'] == 0 else (self.SCORE['fd'] - pow(self.VAR, 0.5))/self.SCORE['fd']

	def setWeight(self):
		self.WEIGHT = self.CNST # doubles weight
		self.TOURN_WEIGHT = 2 - self.CNST # tournament weight

	def setError(self):
		self.ERR = self.VAR / pow(self.GP,0.5)

	def setEfficiency(self):
		self.EFF = {
			'fd': 0 if self.SALARY['fd'] == 0 else self.SCORE['fd']/ self.SALARY['fd'], # efficiency
			'dk': 0 if self.SALARY['dk'] == 0 else self.SCORE['dk']/ self.SALARY['dk']
		}

	def adjust(self, adjustments):
		score = self.AVG['fd']
		mins = self.MIN
		if 'score' in adjustments:
			score = adjustments['score']
		if 'mins' in adjustments:
			mins = adjustments['mins']
		if 'var' in adjustments:
			self.VAR = adjustments['var']
		fd_score = score + self.PM['fd']
		dk_score = score + (self.AVG['dk'] - self.AVG['fd']) + self.PM['dk']
		self.SCORE = {
			'fd': 0 if self.MIN == 0 else fd_score*mins/self.MIN,
			'dk': 0 if self.MIN == 0 else dk_score*mins/self.MIN
		}
		self.setConsistency()
		self.setWeight()
		self.setEfficiency()
		self.setError()

	def removeTeam(self, out):
		if self.OPP.ID in out:
			self.SCORE = 0
		##
		self.setConsistency()
		self.setWeight()
		self.setEfficiency()
		
		



