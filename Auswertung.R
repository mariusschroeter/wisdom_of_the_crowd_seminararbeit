library(dplyr)

#Filtern von Spielen mit weniger als 100 Abstimmungen
lsdf_100 <- livescore_data_full%>%
  filter(totalVotingCount > 100)

# Unterteilung in Ligen
bundesliga <- lsdf_100%>%
  filter(competition == "Bundesliga")

premier_league <- lsdf_100%>%
  filter(competition == "Premier League")

serie_a <- lsdf_100%>%
  filter(competition == "Serie A")

other_league <- lsdf_100%>%
  filter(competition != "Bundesliga" &
           competition != "Premier League" &
           competition != "Serie A")

# -- Tabelle 2 --
#Summe der Spiele
bundesliga%>%
  count()
#Summe der Abstimmungen
bundesliga%>%
  summarise(sum(totalVotingCount))
#Durchschnitt der Abstimmungen
#Summe der Abstimmungen / Summe der Spiele
#selbe herangehensweise für premier_league, serie_a und other_league Datensätze

# -- Tabelle 3 --
bundesliga%>%
  filter(homeGoals > awayGoals)%>%
  count()
# 32/74 = 0.4324 = 43.24% (s.Tabelle 2: Zeile 1, Spalte 1)
bundesliga%>%
  filter(homeGoals == awayGoals)%>%
  count()
# 18/74 = 0.2432 = 24.32%
bundesliga%>%
  filter(homeGoals < awayGoals)%>%
  count()
# 24/74 = 0.3243 = 32.43%
#selbe herangehensweise für premier_league, serie_a und other_league Datensätze

# -- Tabelle 4 --
bundesliga%>%
  summarise(sum(homeOdd) / 74)
#selbe herangehensweise für premier_league, serie_a, other_league
#und lsdf_100 Datensätze

# -- Tabelle 5, 6, 7 und 8-- 
#Am Beispiel der Bundesliga
#Prozentsatz home/draw/away (Wie oft kam welches Ergebniss?)
bundesliga%>%
  mutate(ls_home_prop = homeVotingCount / totalVotingCount, 
         ls_draw_prop = drawVotingCount / totalVotingCount,
         ls_away_prop = awayVotingCount / totalVotingCount) -> bundesliga

#Erwartungswert berechnen
bundesliga%>%
  mutate(ls_home_ev = ls_home_prop * homeOdd,
         ls_draw_ev = ls_draw_prop * drawOdd,
         ls_away_ev = ls_away_prop * awayOdd) -> bundesliga

#Welcher Erwartungswert ist am höchsten? 1-heim, 0-draw, -1-away
bundesliga%>%
  mutate(ls_bet = if_else((ls_home_ev > ls_draw_ev) & (ls_home_ev > ls_away_ev), 1,
                          if_else((ls_draw_ev > ls_home_ev) & (ls_draw_ev > ls_away_ev), 0,
                                  -1))) -> bundesliga

#Welches Team hat gewonnen? heimteam 1, draw 0, away -1
bundesliga%>%
  mutate(result = if_else(homeGoals > awayGoals,1,
                             if_else(awayGoals > homeGoals, -1, 0))) -> bundesliga

#Wieviel Profit macht man bei einem Euro Einsatz?
bundesliga%>%
  mutate(ls_profit_random = if_else(result == ls_bet_random, 
                             if_else(result == 1, homeOdd, 
                                     if_else(result == 0, drawOdd,
                                             awayOdd)), -1)) -> bundesliga

#Modell des reinen Zufalls (Jedes mal anders)
bundesliga%>%
  mutate(ls_bet_random = sample(-1:1, 3559, replace = TRUE)) -> bundesliga

#Heimteam gewinnt Modell
bundesliga%>%
  mutate(ls_profit_homeWin = if_else(result == 1, homeOdd, -1)) -> bundesliga

#Wettquoten Modell
bundesliga%>%
  mutate(ls_bet_odds = if_else((homeOdd < drawOdd & homeOdd < awayOdd), 1,
                               if_else((awayOdd < homeOdd) & (awayOdd < drawOdd), -1,
                                       0))) -> bundesliga

#Alternative -> Ich wette garnicht
bundesliga%>%
  mutate(no_bet_profit = 0) -> bundesliga

#Profit von WdV
bundesliga%>%
 summarise(sum(ls_profit))

#Profit von Zufalls Modell
bundesliga%>%
  summarise(sum(ls_profit_random))

#Profit von Heimteam gewinnt Modell
bundesliga%>%
  summarise(sum(ls_profit_homeWin))

#Profit von Heimteam gewinnt Modell
bundesliga%>%
  summarise(sum(ls_profit_odds))

#Signifikants Test (Tabelle 5)
#h0 -> resultat bei abstimmungen ist 0 
#h1 -> resultat bei abstimmungen ist ungleich 0
t.test(bundesliga$ls_profit, bundesliga$no_bet_profit, alternative = 'two.sided')
t.test(bundesliga$ls_profit_random, bundesliga$no_bet_profit, alternative = 'two.sided')
t.test(bundesliga$ls_profit_homeWin, bundesliga$no_bet_profit, alternative = 'two.sided')
t.test(bundesliga$ls_profit_odds, bundesliga$no_bet_profit, alternative = 'two.sided')

#Signifikants Test Vergleich der Modelle (Tabelle 6, 7 und 8)

#besser als reiner Zufall?
t.test(bundesliga$ls_profit, bundesliga$ls_profit_random, alternative = 'greater')

#Heimteam sieg
t.test(bundesliga$ls_profit, bundesliga$ls_profit_homeWin, alternative = 'greater')

#Wettquoten
t.test(bundesliga$ls_profit, bundesliga$ls_profit_odds, alternative = 'greater')

#gleiches Spiel für die anderen Datensätze (premier_league, serie_a, other_league, lsdf_100)
