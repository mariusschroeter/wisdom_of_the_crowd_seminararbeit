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

# -- Tabelle 1 --
#siehe premier_league Zeile 3

# -- Tabelle 2 --
#Summe der Spiele
lsdf_100%>%
  count()
#Summe der Abstimmungen
lsdf_100%>%
  summarise(sum(totalVotingCount))
#Durchschnitt der Abstimmungen
#Summe der Abstimmungen / Summe der Spiele
#selbe herangehensweise für bundesliga, premier_league, serie_a und 
#other_league Datensätze

# -- Tabelle 3 --
lsdf_100%>%
  filter(homeGoals > awayGoals)%>%
  count()
# 1681/3802 = 0,4421 = 44.21% (s.Tabelle 3: Zeile 5, Spalte 1)
lsdf_100%>%
  filter(homeGoals == awayGoals)%>%
  count()
# 981/3802
lsdf_100%>%
  filter(homeGoals < awayGoals)%>%
  count()
# 1140/3802
#selbe herangehensweise für bundesliga, premier_league, serie_a und 
#other_league Datensätze

# -- Tabelle 4 --
lsdf_100%>%
  summarise(sum(homeOdd) / 3802)
#selbe herangehensweise für bundesliga, premier_league, serie_a und 
#other_league Datensätze

# -- Tabelle 5, 6, 7 --
#siehe premier_league zeile 3 spalten homeVotingCount, drawVotingCount,
#awayVotingCount und totalVotingCount



# -- Tabelle 8-- 
#Am Beispiel lsdf_100 Datensatz
#Prozentsatz home/draw/away (Wie oft kam welches Ergebniss?)
lsdf_100%>%
  mutate(ls_home_prop = homeVotingCount / totalVotingCount, 
         ls_draw_prop = drawVotingCount / totalVotingCount,
         ls_away_prop = awayVotingCount / totalVotingCount) -> lsdf_100

#Erwartungswert berechnen
lsdf_100%>%
  mutate(ls_home_ev = ls_home_prop * homeOdd,
         ls_draw_ev = ls_draw_prop * drawOdd,
         ls_away_ev = ls_away_prop * awayOdd) -> lsdf_100

#Welcher Erwartungswert ist am höchsten? 1-heim, 0-draw, -1-away
lsdf_100%>%
  mutate(ls_bet = if_else((ls_home_ev > ls_draw_ev) & (ls_home_ev > ls_away_ev), 1,
                          if_else((ls_draw_ev > ls_home_ev) & (ls_draw_ev > ls_away_ev), 0,
                                  -1))) -> lsdf_100

#Welches Team hat gewonnen? heimteam 1, draw 0, away -1
lsdf_100%>%
  mutate(result = if_else(homeGoals > awayGoals,1,
                             if_else(awayGoals > homeGoals, -1, 0))) -> lsdf_100

#Wieviel Profit macht man bei einem Euro Einsatz?
lsdf_100%>%
  mutate(ls_profit_random = if_else(result == ls_bet_random, 
                             if_else(result == 1, homeOdd, 
                                     if_else(result == 0, drawOdd,
                                             awayOdd)), -1)) -> lsdf_100

#Alternative -> Ich wette garnicht
lsdf_100%>%
  mutate(no_bet_profit = 0) -> lsdf_100

#Profit von WdV
lsdf_100%>%
 summarise(sum(ls_profit))

#Signifikant Unterschiedlich von 0?
t.test(lsdf_100$ls_profit, lsdf_100$no_bet_profit, alternative = 'greater')

# -- Tabelle 9, 10, 11 --
#Wettquoten Modell
lsdf_100%>%
  mutate(ls_bet_odds = if_else((homeOdd < drawOdd & homeOdd < awayOdd), 1,
                               if_else((awayOdd < homeOdd) & (awayOdd < drawOdd), -1,
                                       0))) -> lsdf_100

#Wettquoten Modell besser als mein Modell?
t.test(lsdf_100$ls_profit_odds, lsdf_100$ls_profit, paired=TRUE, alternative = 'greater')
#pwert ist sehr klein -> Wettquoten Modell besser als WdV-Modell!

#Durchschnittsmodell (Tabelle 10)
#vergleich mit dem Modell wie oft kommt welches Ergebnis vor.
#Durchschnitte sind 44,14 25,43 und 30,43 (Tabelle 3)
#quote * durchschnitte -> neuer EW
#Erwartungswert berechnen
lsdf_100%>%
  mutate(ls_prop_home_ev = 0.44 * homeOdd,
         ls_prop_draw_ev = 0.25 * drawOdd,
         ls_prop_away_ev = 0.3 * awayOdd) -> lsdf_100

#Welcher Erwartungswert ist am höchsten? 1-heim, 0-draw, -1-away
lsdf_100%>%
  mutate(ls_prop_bet = if_else((ls_prop_home_ev > ls_prop_draw_ev) & (ls_prop_home_ev > ls_prop_away_ev), 1,
                          if_else((ls_prop_draw_ev > ls_prop_home_ev) & (ls_prop_draw_ev > ls_prop_away_ev), 0,
                                  -1))) -> lsdf_100

#Wieviel Profit macht man bei einem Euro Einsatz?
lsdf_100%>%
  mutate(ls_profit_prop = if_else(result == ls_prop_bet, 
                                    if_else(result == 1, homeOdd, 
                                            if_else(result == 0, drawOdd,
                                                    awayOdd)), -1)) -> lsdf_100
#Wie erfolgreich ?
t.test(lsdf_100$ls_profit_odds, lsdf_100$ls_profit_prop,paired = TRUE, alternative = 'greater')
# Wettquoten Modell ist besser als das Durchschnittsmodell!

#3. Modell -> Die Underdogs sind unterbewertet?
#Die Wahrscheinlichkeit für den vermeintlichen Verlierer wird + 5% genommen.
lsdf_100%>%
  mutate(
    ls_ud_home_ev = if_else((homeOdd > awayOdd),
                            homeOdd * (1 / homeOdd + 0.05),
                            homeOdd * (1 / homeOdd - 0.025),
                            ),
    ls_ud_draw_ev = drawOdd * (1 / drawOdd - 0.025),
    ls_ud_away_ev = if_else((awayOdd > homeOdd),
                            awayOdd * (1 / awayOdd + 0.05),
                            awayOdd * (1 / awayOdd - 0.025),
    ),
  ) -> lsdf_100

#Welcher Erwartungswert ist am höchsten? 1-heim, 0-draw, -1-away
lsdf_100%>%
  mutate(ls_ud_bet = if_else((ls_ud_home_ev > ls_ud_draw_ev) & (ls_ud_home_ev > ls_ud_away_ev), 1,
                               if_else((ls_ud_draw_ev > ls_ud_home_ev) & (ls_ud_draw_ev > ls_ud_away_ev), 0,
                                       -1))) -> lsdf_100

#Wieviel Profit macht man bei einem Euro Einsatz?
lsdf_100%>%
  mutate(ls_profit_ud = if_else(result == ls_ud_bet, 
                                  if_else(result == 1, homeOdd, 
                                          if_else(result == 0, drawOdd,
                                                  awayOdd)), -1)) -> lsdf_100

#Wie erfolgreich ?
t.test(lsdf_100$ls_profit_odds, lsdf_100$ls_profit_ud, paired = TRUE,alternative = 'greater')
# Das Wettquoten Modell ist besser als das Außenseiter Modell
#

# Auflistung der Ergebnisse
#Wettquoten
sum(lsdf_100$ls_profit_odds)
#WdV
sum(lsdf_100$ls_profit)
#Durchschnitt
sum(lsdf_100$ls_profit_prop)
#Außenseiter
sum(lsdf_100$ls_profit_ud)
