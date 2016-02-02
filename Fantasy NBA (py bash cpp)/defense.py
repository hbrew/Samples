

### Class for Defenses

class Defense:
	def __init__(self, team_id, name, fg3pt, fg2pt, rbd, ast, blk, stl, tov):
		self.ID = team_id
		self.NAME = name
		self.FG3PT_DIFF = fg3pt
		self.FG2PT_DIFF = fg2pt
		self.RBD = rbd
		self.AST = ast
		self.BLK = blk
		self.STL = stl
		self.TOV = tov

