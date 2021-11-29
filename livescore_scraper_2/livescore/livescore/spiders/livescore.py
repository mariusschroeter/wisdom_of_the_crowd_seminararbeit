import scrapy
import json
import sqlite3
import re
from datetime import datetime


class LivescoreSpider(scrapy.Spider):

    name = 'livescore'
    allowed_domains = ['livescore.com',
                       'sportscubecdn-wqps7yvkz.stackpathdns.com']

    today = datetime.today().strftime('%Y%m%d')
    start_urls = [
        f'https://prod-public-api.livescore.com/v1/api/react/date/soccer/{today}/2.00']

    conn = sqlite3.connect('livescore_with_odds.db')
    c = conn.cursor()

    def parse(self, response):
        # get all event ids from today
        allEventIds = []
        resp = json.loads(response.body)
        stages = resp.get('Stages')
        for stage in stages:
            events = stage.get('Events')
            for event in events:
                eventId = event.get('Eid')
                allEventIds.append(eventId)

        # get all match infos

        for eventId in allEventIds:
            yield response.follow(
                url=f'https://sportscubecdn-wqps7yvkz.stackpathdns.com/v3/en_US/42/votings/?apikey=ZYg0quj6ndvXv0WxXeJ0WVaqd3KNsDWU&bookie_id=81&country_iso=DE&match_assoc=livescore&match_id={eventId}&mode=loose',
                callback=self.parseMatchInfo
            )

    def parseMatchInfo(self, response):

        resp = json.loads(response.body)

        # teams
        try:
            homeTeam = resp.get('data').get('match').get(
                'teams').get('home').get('name')
            awayTeam = resp.get('data').get('match').get(
                'teams').get('away').get('name')
        except:
            pass

        try:
            matchDateAndTime = resp.get('data').get('match').get('matchdate')
            # extras
            matchDate = re.findall(
                "\d{4}-\d{2}-\d{2}", matchDateAndTime)[0]
            matchTime = re.findall(
                "\d{2}:\d{2}", matchDateAndTime)[0]

            homeMicroName = resp.get('data').get('match').get(
                'teams').get('home').get('microname')
            awayMicroName = resp.get('data').get('match').get(
                'teams').get('away').get('microname')

            uniqueId = homeMicroName + '_' + awayMicroName + \
                '_' + str(matchDate) + '-' + matchTime
        except:
            pass

        # possible odds
        try:
            homeOdd = resp.get('data').get(
                'match').get('bets').get('1').get('odd')
            drawOdd = resp.get('data').get(
                'match').get('bets').get('X').get('odd')
            awayOdd = resp.get('data').get(
                'match').get('bets').get('2').get('odd')
            print('--odds added--')
        except:
            pass

        # Write to db
        try:
            self.c.execute(
                '''INSERT INTO livescore_with_odds VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''', (homeTeam, awayTeam, homeOdd, drawOdd, awayOdd, homeMicroName, awayMicroName, matchDate, matchTime, uniqueId))
            self.conn.commit()
        except:
            pass
