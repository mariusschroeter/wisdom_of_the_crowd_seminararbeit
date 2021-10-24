install.packages("dpylr")
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
# 100 - 5000 votes
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

# -- Tabelle 3 --
bundesliga%>%
  filter(totalVotingCount < 5000)%>%
  count()

# 49 (s.Tabelle 3: Zeile 1, Spalte 1)

bundesliga%>%
  filter(totalVotingCount < 5000)%>%
  filter(
    (homeGoals > awayGoals &
            homeVotingCount > drawVotingCount &
            homeVotingCount > awayVotingCount
            )
    |
      (homeGoals < awayGoals &
         awayVotingCount > drawVotingCount &
         homeVotingCount < awayVotingCount
      )
    |
      (homeGoals == awayGoals &
         homeVotingCount < drawVotingCount &
         drawVotingCount > awayVotingCount
      )
           )%>%
  count()

# 21
# 21/49 = 0.42857 = 42.86%

#>5000 Votes
bundesliga%>%
  filter(totalVotingCount > 5000)%>%
  count()
#25 
#...
#s. 100-5000 votes

# -- Tabelle 4 --
# Werte aus Tabelle 3 aufsummiert
# Beispiel Bundesliga:
# 49 + 25 = 74
# 21 + 17 = 38
# 38 / 74 = 51.35%

# -- Tabelle 5 --
bundesliga%>%
  filter(
    (homeGoals > awayGoals &
       homeOdd < drawOdd &
       homeOdd < awayOdd
    )
    |
      (homeGoals < awayGoals &
         awayOdd < drawOdd &
         homeOdd > awayOdd
      )
    |
      (homeGoals == awayGoals &
         homeOdd > drawOdd &
         drawOdd < awayOdd
      )
  )%>%
  count()

#38
#38 / 74 = 51.35%

# -- Tabelle 6 -- 
lsdf_100%>%
  filter(homeGoals > awayGoals)%>%
  count()

# 1681 / 3802 = 44.21%
# Wettquoten siehe Tabelle 5
# Wdv siehe Tabelle 4

# -- Tabelle 7 -- 
lsdf_100%>%
  filter(
    (homeGoals > awayGoals &
       homeVotingCount > drawVotingCount &
       homeVotingCount > awayVotingCount
    )
    |
      (homeGoals < awayGoals &
         awayVotingCount > drawVotingCount &
         homeVotingCount < awayVotingCount
      )
    |
      (homeGoals == awayGoals &
         homeVotingCount < drawVotingCount &
         drawVotingCount > awayVotingCount
      )
  )%>%
  count()
