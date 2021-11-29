import sqlite3

conn = sqlite3.connect('livescore_with_odds.db')
c = conn.cursor()

c.execute('''CREATE TABLE livescore_with_odds(homeTeam TEXT NOT NULL, awayTeam TEXT NOT NULL, homeOdd DOUBLE, awayOdd DOUBLE, drawOdd DOUBLE, homeMicroName TEXT, awayMicroName TEXT, matchDate TEXT, matchTime TEXT, uniqueId TEXT)''')

conn.close()
