import sys, os
from subprocess import call, STDOUT
from multiprocessing import Pool

# Open /dev/null
FNULL = open(os.devnull, 'w')

# Wrapper for call function to include optional parameters
def bash(command):
	call(command, shell=True)#, stdout=FNULL, stderr=STDOUT)


if __name__ == "__main__":
	commands = []
	with open(sys.argv[1], 'r') as f:
		for line in f:
			commands.append(line.rstrip())
	p = Pool(8)
	p.map(bash, commands)
