﻿-- ha elmegy az első vonat is a végállomáshoz csak olyanokat javasoljon amikkel hamarabb odaérhet. //ez majd az összeolvasztotthoz
-- visszafele utazást is lehessen engedni, de vizsgálni kellesz hogy egy vonatra, ha átszállunk, abból a legkevesebb utazásos jelenjen csak meg.
-- ne lehessen átszállni a végállomásban vonatra
SELECT *, FIRST_TRAIN_START + INTERVAL DISTANCE_BEFORE_START1/SPEED*60.0 MINUTE AS 'START_TIME1', FIRST_TRAIN_START + INTERVAL (DISTANCE_BEFORE_START1+DISTANCE_BETWEEN_START_AND_STOP1)/SPEED*60.0 MINUTE AS 'ARRIVE_TIME1', START + INTERVAL DISTANCE_BEFORE_START2/SPEED*60.0 MINUTE AS 'START_TIME2', START + INTERVAL (DISTANCE_BEFORE_START2+DISTANCE_BETWEEN_START_AND_STOP2)/SPEED*60.0 MINUTE AS 'ARRIVE_TIME2'
FROM WAGONS
INNER JOIN 
	(SELECT *, SUM(CASE WHEN TMP7_STATION_INDEX_IN_ROUTE < START_STATION_INDEX_IN_ROUTE AND TMP7_ROUTES_ID = ID2 THEN DISTANCE ELSE 0 END) AS 'DISTANCE_BEFORE_START1', SUM(CASE WHEN (TMP7_STATION_INDEX_IN_ROUTE >= START_STATION_INDEX_IN_ROUTE AND TMP7_STATION_INDEX_IN_ROUTE < MIDDLE_STATION_INDEX_IN_ROUTE1 AND TMP7_ROUTES_ID = ID2) THEN DISTANCE ELSE 0 END) AS 'DISTANCE_BETWEEN_START_AND_STOP1', SUM(CASE WHEN TMP7_STATION_INDEX_IN_ROUTE < MIDDLE_STATION_INDEX_IN_ROUTE2 AND TMP7_ROUTES_ID = ID3 THEN DISTANCE ELSE 0 END) AS 'DISTANCE_BEFORE_START2', SUM(CASE WHEN (TMP7_STATION_INDEX_IN_ROUTE >= MIDDLE_STATION_INDEX_IN_ROUTE2 AND TMP7_STATION_INDEX_IN_ROUTE < STOP_STATION_INDEX_IN_ROUTE2 AND TMP7_ROUTES_ID = ID3) THEN DISTANCE ELSE 0 END) AS 'DISTANCE_BETWEEN_START_AND_STOP2'
	FROM
		(SELECT ROUTE_STATIONS_CONNECTION.EXPLETIVE_TICKET AS 'TMP7_EXPLETIVE_TICKET', ROUTE_STATIONS_CONNECTION.ROUTES_ID AS 'TMP7_ROUTES_ID', ROUTE_STATIONS_CONNECTION.STATIONS_ID AS 'TMP7_STATIONS_ID', ROUTE_STATIONS_CONNECTION.STATION_INDEX_IN_ROUTE AS 'TMP7_STATION_INDEX_IN_ROUTE', ROUTE_STATIONS_CONNECTION.TYPE_OF_TRAINS_STOPS AS 'TMP7_TYPE_OF_TRAINS_STOPS', TMP6.*
		FROM ROUTE_STATIONS_CONNECTION
		INNER JOIN 
			(SELECT DISTINCT TRAINS.ID AS 'SECOND_TRAIN_ID', TRAINS.TYPE, TRAINS.SPEED, TRAINS.STATUS, TRAIN_ROUTE_CONNECTION.START, TMP5.*
			FROM TRAINS
			INNER JOIN TRAIN_ROUTE_CONNECTION
				ON TRAINS.ID = TRAIN_ROUTE_CONNECTION.TRAINS_ID
			INNER JOIN
				(SELECT TRAINS.ID AS 'FIRST_TRAIN_ID', TRAINS.TYPE AS 'FIRST_TRAIN_TYPE', TRAINS.SPEED AS 'FIRST_TRAIN_SPEED', TRAINS.STATUS AS 'FIRST_TRAIN_STATUS', TRAIN_ROUTE_CONNECTION.START AS 'FIRST_TRAIN_START', TMP4.*
				FROM TRAINS
				INNER JOIN TRAIN_ROUTE_CONNECTION
					ON TRAINS.ID = TRAIN_ROUTE_CONNECTION.TRAINS_ID
				INNER JOIN
					(SELECT *, ROUTE_STATIONS_CONNECTION.STATION_INDEX_IN_ROUTE AS 'STOP_STATION_INDEX_IN_ROUTE2'
					FROM ROUTE_STATIONS_CONNECTION
					INNER JOIN 
						(SELECT ROUTE_STATIONS_CONNECTION.ROUTES_ID AS 'ID3', ROUTE_STATIONS_CONNECTION.STATION_INDEX_IN_ROUTE AS 'MIDDLE_STATION_INDEX_IN_ROUTE2', TMP2.MIDDLE_STATION_INDEX_IN_ROUTE1, TMP2.ID2, TMP2.START_STATION_INDEX_IN_ROUTE, TMP2.START_TRAINS_STOP, ROUTE_STATIONS_CONNECTION.TYPE_OF_TRAINS_STOPS AS 'MIDDLE_TRAINS_STOP'
						FROM ROUTE_STATIONS_CONNECTION
						INNER JOIN 
							(SELECT ROUTE_STATIONS_CONNECTION.STATIONS_ID, ROUTES_ID AS 'ID2', TMP.FIRST_STATION_ID, TMP.START_STATION_INDEX_IN_ROUTE, TMP.START_TRAINS_STOP, ROUTE_STATIONS_CONNECTION.STATION_INDEX_IN_ROUTE AS 'MIDDLE_STATION_INDEX_IN_ROUTE1', STATIONS.NAME AS 'MIDDLE_STATION_NAME'
							FROM ROUTE_STATIONS_CONNECTION
							INNER JOIN 
								(SELECT ROUTES_ID AS 'ID1', STATION_INDEX_IN_ROUTE AS 'START_STATION_INDEX_IN_ROUTE', TYPE_OF_TRAINS_STOPS AS 'START_TRAINS_STOP', STATIONS_ID AS 'FIRST_STATION_ID'
								FROM ROUTE_STATIONS_CONNECTION
								INNER JOIN STATIONS
									ON STATIONS.ID = ROUTE_STATIONS_CONNECTION.STATIONS_ID
								WHERE STATIONS.NAME = 'Kisvárda') TMP
								ON ROUTE_STATIONS_CONNECTION.ROUTES_ID = TMP.ID1
							INNER JOIN STATIONS
									ON STATIONS.ID = ROUTE_STATIONS_CONNECTION.STATIONS_ID) TMP2
							ON ROUTE_STATIONS_CONNECTION.STATIONS_ID = TMP2.STATIONS_ID
						WHERE ROUTE_STATIONS_CONNECTION.ROUTES_ID != TMP2.ID2 AND TMP2.MIDDLE_STATION_NAME != 'Debrecen' AND FIRST_STATION_ID != ROUTE_STATIONS_CONNECTION.STATIONS_ID/* AND MIDDLE_STATION_INDEX_IN_ROUTE1 > START_STATION_INDEX_IN_ROUTE*/) TMP3
						ON TMP3.ID3 = ROUTE_STATIONS_CONNECTION.ROUTES_ID
						INNER JOIN STATIONS
							ON STATIONS.ID = ROUTE_STATIONS_CONNECTION.STATIONS_ID
					WHERE STATIONS.NAME = 'Debrecen'
					GROUP BY ID2,ID3
					HAVING MIN(MIDDLE_STATION_INDEX_IN_ROUTE1)) TMP4
					ON TRAIN_ROUTE_CONNECTION.ROUTES_ID = TMP4.ID2) TMP5 /*OR TRAIN_ROUTE_CONNECTION.ROUTES_ID = TMP4.ID3*/
				ON TRAIN_ROUTE_CONNECTION.ROUTES_ID = TMP5.ID3
			WHERE START_TRAINS_STOP LIKE CONCAT('%',TMP5.FIRST_TRAIN_TYPE,'%') AND MIDDLE_TRAINS_STOP LIKE CONCAT('%',TRAINS.TYPE,'%') AND TMP5.TYPE_OF_TRAINS_STOPS LIKE CONCAT('%',TRAINS.TYPE,'%')) TMP6
			ON ROUTE_STATIONS_CONNECTION.ROUTES_ID = TMP6.ID3 OR ROUTE_STATIONS_CONNECTION.ROUTES_ID = TMP6.ID2) TMP7
	INNER JOIN 
		(SELECT ROUTES_ID AS 'TMP8_ROUTES_ID', STATION_INDEX_IN_ROUTE AS 'TMP8_STATION_INDEX_IN_ROUTE', STATIONS_ID AS 'TMP8_STATIONS_ID'
		FROM ROUTE_STATIONS_CONNECTION) TMP8
		ON TMP7.TMP7_ROUTES_ID = TMP8.TMP8_ROUTES_ID AND TMP7.TMP7_STATION_INDEX_IN_ROUTE+1 = TMP8.TMP8_STATION_INDEX_IN_ROUTE
	INNER JOIN
		(SELECT NEIGHBOUR_ID, DISTANCE, STATIONS_ID AS 'TMP9_STATIONS_ID'
		FROM NEIGHBOURS) TMP9
		ON TMP9.NEIGHBOUR_ID = TMP8.TMP8_STATIONS_ID AND TMP9.TMP9_STATIONS_ID = TMP7.TMP7_STATIONS_ID
	GROUP BY ID2,ID3) TMP10
	ON TMP10.FIRST_TRAIN_ID = WAGONS.TRAINS_ID OR TMP10.SECOND_TRAIN_ID = WAGONS.TRAINS_ID
INNER JOIN 
	(SELECT TRAINS_ID, CASE WHEN ISNULL(GROUP_CONCAT(CASE WHEN CLASS = 1 THEN SERVICES END separator ';')) THEN 0 ELSE GROUP_CONCAT(CASE WHEN CLASS = 1 THEN SERVICES END separator ';') END AS 'CLASS1_SERVICES'
	FROM WAGONS
	GROUP BY WAGONS.TRAINS_ID) TMP11
	ON WAGONS.TRAINS_ID = TMP11.TRAINS_ID
INNER JOIN 
	(SELECT TRAINS_ID, CASE WHEN ISNULL(GROUP_CONCAT(CASE WHEN CLASS = 2 THEN SERVICES END separator ';')) THEN 0 ELSE GROUP_CONCAT(CASE WHEN CLASS = 2 THEN SERVICES END separator ';') END AS 'CLASS2_SERVICES'
	FROM WAGONS
	GROUP BY WAGONS.TRAINS_ID) TMP12
	ON WAGONS.TRAINS_ID = TMP12.TRAINS_ID
WHERE DATE(FIRST_TRAIN_START + INTERVAL DISTANCE_BEFORE_START1/SPEED*60.0 MINUTE) = DATE('2016-12-09') AND FIRST_TRAIN_START + INTERVAL DISTANCE_BEFORE_START1/SPEED*60.0 MINUTE > NOW() AND START + INTERVAL DISTANCE_BEFORE_START2/SPEED*60.0 MINUTE > FIRST_TRAIN_START + INTERVAL (DISTANCE_BEFORE_START1+DISTANCE_BETWEEN_START_AND_STOP1)/SPEED*60.0 MINUTE -- HA AKARUNK MAX VÁRAKOZÁST AKKOR AZT IDE?
-- EXAMPLE WHERE (CLASS1_SERVICES LIKE '%1%' OR CLASS2_SERVICES LIKE '%1%') AND (CLASS1_SERVICES LIKE '%4%' OR CLASS2_SERVICES LIKE '%4%')
GROUP BY FIRST_TRAIN_ID,SECOND_TRAIN_ID
HAVING 