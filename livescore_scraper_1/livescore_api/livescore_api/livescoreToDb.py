import sqlite3

conn = sqlite3.connect('livescore_with_votings.db')
c = conn.cursor()

c.execute('''CREATE TABLE livescore_with_votings(homeTeam TEXT NOT NULL, awayTeam TEXT NOT NULL, homeGoals INT, awayGoals INT, homeVotingCount INT, drawVotingCount INT, awayVotingCount INT, totalVotingCount INT, homeShortName TEXT, awayShortName TEXT, homeMicroName TEXT, awayMicroName TEXT, matchDate TEXT, matchTime TEXT, competition TEXT, uniqueId TEXT)''')
# home = '0.5'
# draw = '0.2'
# away = '0.3'

# c.execute('''INSERT INTO livescore VALUES("test", "test", ?,?,?)''', (home, draw, away))
# conn.commit()

# c.execute('''SELECT * FROM livescore''')
# results= c.fetchall()
# print(results)

conn.close()
