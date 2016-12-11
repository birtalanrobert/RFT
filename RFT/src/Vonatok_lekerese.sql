﻿-- Megfelelő időpontok kiszámitása
SELECT '0' AS 'COUNT_OF_CHANGES'
	,WAGONS.TRAINS_ID AS 'FIRST_TRAIN_ID'
	,SPEED AS 'FIRST_TRAIN_SPEED'
	,TYPE AS 'FIRST_TRAIN_TYPE'
	,DISTANCE_BETWEEN_START_AND_STOP AS 'FIRST_TRAIN_DISTANCE_BETWEEN_START_AND_STOP'
	,'0' AS 'CHANGE_STATION'
	,CLASS1_SERVICES AS 'FIRST_TRAIN_CLASS1_SERVICES'
	,CLASS2_SERVICES AS 'FIRST_TRAIN_CLASS2_SERVICES'
	,TMP3_EXPLETIVE_TICKET AS 'FIRST_TRAIN_EXPLETIVE_TICKET'
	,START + INTERVAL DISTANCE_BEFORE_START / SPEED * 60.0 MINUTE AS 'START_TIME1'
	,START + INTERVAL(DISTANCE_BEFORE_START + DISTANCE_BETWEEN_START_AND_STOP) / SPEED * 60.0 MINUTE AS 'ARRIVE_TIME1'
	,'0' AS 'SECOND_TRAIN_ID'
	,'0' AS 'SECOND_TRAIN_SPEED'
	,'0' AS 'SECOND_TRAIN_TYPE'
	,'0' AS 'SECOND_TRAIN_DISTANCE_BETWEEN_START_AND_STOP'
	,'0' AS 'SECOND_TRAIN_CLASS1_SERVICES'
	,'0' AS 'SECOND_TRAIN_CLASS2_SERVICES'
	,'0' AS 'SECOND_TRAIN_EXPLETIVE_TICKET'
	,'0' AS 'START_TIME2'
	,'0' AS 'ARRIVE_TIME2'
	,ROUTES_ID AS 'FIRST_TRAIN_ROUTE_ID'
	,'0' AS 'SECOND_TRAIN_ROUTE_ID'
FROM WAGONS
INNER JOIN
	-- A kiinduló állomás előtt megtett út, illetve a kiinduló és célállomás közti távolság kiszámitása
	(
	SELECT *
		,SUM(CASE 
				WHEN STATION_INDEX_IN_ROUTE < START_INDEX_IN_ROUTE
					THEN DISTANCE
				ELSE 0
				END) AS 'DISTANCE_BEFORE_START'
		,SUM(CASE 
				WHEN (
						STATION_INDEX_IN_ROUTE >= START_INDEX_IN_ROUTE
						AND STATION_INDEX_IN_ROUTE < STOP_INDEX_IN_ROUTE
						)
					THEN DISTANCE
				ELSE 0
				END) AS 'DISTANCE_BETWEEN_START_AND_STOP'
	FROM (
		SELECT *
		FROM ROUTE_STATIONS_CONNECTION
		INNER JOIN
			-- Azon vonatok kilistázása, amelyek ezen az útvonalon haladnak a kiválasztott napon.
			(
			SELECT TRAINS.ID
				,TRAINS.SPEED
				,TRAINS.TYPE
				,TRAIN_ROUTE_CONNECTION.ROUTES_ID AS 'TMP4_ROUTES_ID'
				,TRAIN_ROUTE_CONNECTION.START
				,TMP3.STATION_INDEX_IN_ROUTE AS 'START_INDEX_IN_ROUTE'
				,TMP3.TMP2_STATION_INDEX_IN_ROUTE AS 'STOP_INDEX_IN_ROUTE'
				,TMP3.STATIONS_ID AS 'START_STATIONS_ID'
				,TMP3.TMP2_STATIONS_ID AS 'STOP_STATIONS_ID'
				,TMP3_EXPLETIVE_TICKET
			FROM TRAINS
			INNER JOIN TRAIN_ROUTE_CONNECTION ON TRAINS.ID = TRAIN_ROUTE_CONNECTION.TRAINS_ID
			INNER JOIN
				-- Vizsgálat, szükséges-e pótjegy vásárlása a megteendő útvonalra.
				(
				SELECT ROUTE_STATIONS_CONNECTION.ROUTES_ID
					,SUM(ROUTE_STATIONS_CONNECTION.EXPLETIVE_TICKET) AS 'TMP3_EXPLETIVE_TICKET'
					,ROUTE_STATIONS_CONNECTION.TYPE_OF_TRAINS_STOPS AS 'FROM_TYPE_OF_TRAINS_STOPS'
					,TMP.TO_TYPE_OF_TRAINS_STOPS
					,TMP.STATIONS_ID
					,TMP.TMP2_STATIONS_ID
					,TMP.STATION_INDEX_IN_ROUTE
					,TMP.TMP2_STATION_INDEX_IN_ROUTE
				FROM ROUTE_STATIONS_CONNECTION
				INNER JOIN
					-- Azok az útvonalak, amelyek megállnak a célállomásnál és a kiinduló állomásnál is.
					(
					SELECT *
					FROM ROUTE_STATIONS_CONNECTION
					INNER JOIN STATIONS ON ROUTE_STATIONS_CONNECTION.STATIONS_ID = STATIONS.ID
					INNER JOIN
						-- Azok az útvonalak, amelyek megállnak a célállomásnál, célállomásról infók.
						(
						SELECT STATIONS_ID AS 'TMP2_STATIONS_ID'
							,STATION_INDEX_IN_ROUTE AS 'TMP2_STATION_INDEX_IN_ROUTE'
							,ROUTES_ID AS 'TMP2_ROUTES_ID'
							,TYPE_OF_TRAINS_STOPS AS 'TO_TYPE_OF_TRAINS_STOPS'
						FROM ROUTE_STATIONS_CONNECTION
						INNER JOIN STATIONS ON ROUTE_STATIONS_CONNECTION.STATIONS_ID = STATIONS.ID
						WHERE STATIONS.NAME = 'Debrecen'
						) TMP2 ON ROUTE_STATIONS_CONNECTION.ROUTES_ID = TMP2.TMP2_ROUTES_ID
					WHERE STATIONS.NAME = 'Kisvárda-Hármasút'
						AND TMP2.TMP2_STATION_INDEX_IN_ROUTE > ROUTE_STATIONS_CONNECTION.STATION_INDEX_IN_ROUTE
					) TMP ON ROUTE_STATIONS_CONNECTION.ROUTES_ID = TMP.ROUTES_ID
				WHERE ROUTE_STATIONS_CONNECTION.STATION_INDEX_IN_ROUTE BETWEEN TMP.STATION_INDEX_IN_ROUTE
						AND TMP.TMP2_STATION_INDEX_IN_ROUTE
				GROUP BY ROUTE_STATIONS_CONNECTION.ROUTES_ID
				) TMP3 ON TRAIN_ROUTE_CONNECTION.ROUTES_ID = TMP3.ROUTES_ID
			WHERE /*TMP3.TMP3_EXPLETIVE_TICKET = 0 AND */ TMP3.FROM_TYPE_OF_TRAINS_STOPS LIKE CONCAT (
					'%'
					,TRAINS.TYPE
					,'%'
					)
				AND TMP3.TO_TYPE_OF_TRAINS_STOPS LIKE CONCAT (
					'%'
					,TRAINS.TYPE
					,'%'
					)
			) TMP4 ON ROUTE_STATIONS_CONNECTION.ROUTES_ID = TMP4.TMP4_ROUTES_ID
		) TMP8
	INNER JOIN (
		SELECT ROUTES_ID AS 'TMP9_ROUTES_ID'
			,STATION_INDEX_IN_ROUTE AS 'TMP9_STATION_INDEX_IN_ROUTE'
			,STATIONS_ID AS 'TMP9_STATIONS_ID'
		FROM ROUTE_STATIONS_CONNECTION
		) TMP9 ON TMP8.ROUTES_ID = TMP9.TMP9_ROUTES_ID
		AND TMP8.STATION_INDEX_IN_ROUTE + 1 = TMP9.TMP9_STATION_INDEX_IN_ROUTE
	INNER JOIN (
		SELECT NEIGHBOUR_ID
			,DISTANCE
			,STATIONS_ID AS 'TMP10_STATIONS_ID'
		FROM NEIGHBOURS
		) TMP10 ON TMP10.NEIGHBOUR_ID = TMP9.TMP9_STATIONS_ID
		AND TMP10.TMP10_STATIONS_ID = TMP8.STATIONS_ID
	GROUP BY ROUTES_ID
	) TMP7 ON TMP7.ID = WAGONS.TRAINS_ID
INNER JOIN (
	SELECT TRAINS_ID
		,CASE 
			WHEN ISNULL(GROUP_CONCAT(CASE 
							WHEN CLASS = 1
								THEN SERVICES
							END separator ';'))
				THEN 0
			ELSE GROUP_CONCAT(CASE 
						WHEN CLASS = 1
							THEN SERVICES
						END separator ';')
			END AS 'CLASS1_SERVICES'
	FROM WAGONS
	GROUP BY WAGONS.TRAINS_ID
	) TMP5 ON WAGONS.TRAINS_ID = TMP5.TRAINS_ID
INNER JOIN (
	SELECT TRAINS_ID
		,CASE 
			WHEN ISNULL(GROUP_CONCAT(CASE 
							WHEN CLASS = 2
								THEN SERVICES
							END separator ';'))
				THEN 0
			ELSE GROUP_CONCAT(CASE 
						WHEN CLASS = 2
							THEN SERVICES
						END separator ';')
			END AS 'CLASS2_SERVICES'
	FROM WAGONS
	GROUP BY WAGONS.TRAINS_ID
	) TMP6 ON WAGONS.TRAINS_ID = TMP6.TRAINS_ID
WHERE DATE (START + INTERVAL DISTANCE_BEFORE_START / SPEED * 60.0 MINUTE) = DATE ('2016-12-11')
-- EXAMPLE WHERE (CLASS1_SERVICES LIKE '%1%' OR CLASS2_SERVICES LIKE '%1%') AND (CLASS1_SERVICES LIKE '%4%' OR CLASS2_SERVICES LIKE '%4%')
GROUP BY WAGONS.TRAINS_ID

UNION ALL

SELECT '1' AS 'COUNT_OF_CHANGES'
	,FIRST_TRAIN_ID
	,FIRST_TRAIN_SPEED
	,FIRST_TRAIN_TYPE
	,DISTANCE_BETWEEN_START_AND_STOP1 AS 'FIRST_TRAIN_DISTANCE_BETWEEN_START_AND_STOP'
	,MIDDLE_STATION_NAME AS 'CHANGE_STATION'
	,CLASS1_SERVICES1 AS 'FIRST_TRAIN_CLASS1_SERVICES'
	,CLASS2_SERVICES1 AS 'FIRST_TRAIN_CLASS2_SERVICES'
	,SUM(EXPLETIVE_TICKET1) AS 'FIRST_TRAIN_EXPLETIVE_TICKET'
	,START_TIME1
	,ARRIVE_TIME1
	,SECOND_TRAIN_ID
	,SECOND_TRAIN_SPEED
	,SECOND_TRAIN_TYPE
	,DISTANCE_BETWEEN_START_AND_STOP2 AS 'SECOND_TRAIN_DISTANCE_BETWEEN_START_AND_STOP'
	,CLASS1_SERVICES2 AS 'SECOND_TRAIN_CLASS1_SERVICES'
	,CLASS2_SERVICES2 AS 'SECOND_TRAIN_CLASS2_SERVICES'
	,SUM(EXPLETIVE_TICKET2) AS 'SECOND_TRAIN_EXPLETIVE_TICKET'
	,START_TIME2
	,ARRIVE_TIME2
	,ID2 AS 'FIRST_TRAIN_ROUTE_ID'
	,ID3 AS 'SECOND_TRAIN_ROUTE_ID'
FROM (
	SELECT *
		,FIRST_TRAIN_START + INTERVAL DISTANCE_BEFORE_START1 / FIRST_TRAIN_SPEED * 60.0 MINUTE AS 'START_TIME1'
		,FIRST_TRAIN_START + INTERVAL(DISTANCE_BEFORE_START1 + DISTANCE_BETWEEN_START_AND_STOP1) / FIRST_TRAIN_SPEED * 60.0 MINUTE AS 'ARRIVE_TIME1'
		,SECOND_TRAIN_START + INTERVAL DISTANCE_BEFORE_START2 / SECOND_TRAIN_SPEED * 60.0 MINUTE AS 'START_TIME2'
		,SECOND_TRAIN_START + INTERVAL(DISTANCE_BEFORE_START2 + DISTANCE_BETWEEN_START_AND_STOP2) / SECOND_TRAIN_SPEED * 60.0 MINUTE AS 'ARRIVE_TIME2'
	FROM (
		SELECT *
			,IF (
				START_STATION_INDEX_IN_ROUTE < MIDDLE_STATION_INDEX_IN_ROUTE1
				,SUM(CASE 
						WHEN TMP7_STATION_INDEX_IN_ROUTE < START_STATION_INDEX_IN_ROUTE
							AND TMP7_ROUTES_ID = ID2
							THEN DISTANCE
						ELSE 0
						END)
				,SUM(CASE 
						WHEN TMP7_STATION_INDEX_IN_ROUTE >= START_STATION_INDEX_IN_ROUTE
							AND TMP7_ROUTES_ID = ID2
							THEN DISTANCE
						ELSE 0
						END)
				) AS 'DISTANCE_BEFORE_START1'
			,
			IF (
					START_STATION_INDEX_IN_ROUTE < MIDDLE_STATION_INDEX_IN_ROUTE1
					,SUM(CASE 
							WHEN (
									TMP7_STATION_INDEX_IN_ROUTE >= START_STATION_INDEX_IN_ROUTE
									AND TMP7_STATION_INDEX_IN_ROUTE < MIDDLE_STATION_INDEX_IN_ROUTE1
									AND TMP7_ROUTES_ID = ID2
									)
								THEN DISTANCE
							ELSE 0
							END)
					,SUM(CASE 
							WHEN (
									TMP7_STATION_INDEX_IN_ROUTE < START_STATION_INDEX_IN_ROUTE
									AND TMP7_STATION_INDEX_IN_ROUTE >= MIDDLE_STATION_INDEX_IN_ROUTE1
									AND TMP7_ROUTES_ID = ID2
									)
								THEN DISTANCE
							ELSE 0
							END)
					) AS 'DISTANCE_BETWEEN_START_AND_STOP1'
				,SUM(CASE 
						WHEN TMP7_STATION_INDEX_IN_ROUTE < MIDDLE_STATION_INDEX_IN_ROUTE2
							AND TMP7_ROUTES_ID = ID3
							THEN DISTANCE
						ELSE 0
						END) AS 'DISTANCE_BEFORE_START2'
				,SUM(CASE 
						WHEN (
								TMP7_STATION_INDEX_IN_ROUTE >= MIDDLE_STATION_INDEX_IN_ROUTE2
								AND TMP7_STATION_INDEX_IN_ROUTE < STOP_STATION_INDEX_IN_ROUTE2
								AND TMP7_ROUTES_ID = ID3
								)
							THEN DISTANCE
						ELSE 0
						END) AS 'DISTANCE_BETWEEN_START_AND_STOP2' FROM (
				SELECT ROUTE_STATIONS_CONNECTION.EXPLETIVE_TICKET AS 'TMP7_EXPLETIVE_TICKET'
					,ROUTE_STATIONS_CONNECTION.ROUTES_ID AS 'TMP7_ROUTES_ID'
					,ROUTE_STATIONS_CONNECTION.STATIONS_ID AS 'TMP7_STATIONS_ID'
					,ROUTE_STATIONS_CONNECTION.STATION_INDEX_IN_ROUTE AS 'TMP7_STATION_INDEX_IN_ROUTE'
					,ROUTE_STATIONS_CONNECTION.TYPE_OF_TRAINS_STOPS AS 'TMP7_TYPE_OF_TRAINS_STOPS'
					,TMP6.*
				FROM ROUTE_STATIONS_CONNECTION
				INNER JOIN (
					SELECT DISTINCT TRAINS.ID AS 'SECOND_TRAIN_ID'
						,TRAINS.TYPE AS 'SECOND_TRAIN_TYPE'
						,TRAINS.SPEED AS 'SECOND_TRAIN_SPEED'
						,TRAINS.STATUS AS 'SECOND_TRAIN_STATUS'
						,TRAIN_ROUTE_CONNECTION.START AS 'SECOND_TRAIN_START'
						,TMP5.*
					FROM TRAINS
					INNER JOIN TRAIN_ROUTE_CONNECTION ON TRAINS.ID = TRAIN_ROUTE_CONNECTION.TRAINS_ID
					INNER JOIN (
						SELECT TRAINS.ID AS 'FIRST_TRAIN_ID'
							,TRAINS.TYPE AS 'FIRST_TRAIN_TYPE'
							,TRAINS.SPEED AS 'FIRST_TRAIN_SPEED'
							,TRAINS.STATUS AS 'FIRST_TRAIN_STATUS'
							,TRAIN_ROUTE_CONNECTION.START AS 'FIRST_TRAIN_START'
							,TMP4.*
						FROM TRAINS
						INNER JOIN TRAIN_ROUTE_CONNECTION ON TRAINS.ID = TRAIN_ROUTE_CONNECTION.TRAINS_ID
						INNER JOIN (
							SELECT *
								,ROUTE_STATIONS_CONNECTION.STATION_INDEX_IN_ROUTE AS 'STOP_STATION_INDEX_IN_ROUTE2'
							FROM ROUTE_STATIONS_CONNECTION
							INNER JOIN (
								SELECT ROUTE_STATIONS_CONNECTION.ROUTES_ID AS 'ID3'
									,ROUTE_STATIONS_CONNECTION.STATION_INDEX_IN_ROUTE AS 'MIDDLE_STATION_INDEX_IN_ROUTE2'
									,TMP2.MIDDLE_STATION_INDEX_IN_ROUTE1
									,MIDDLE_STATION_NAME
									,TMP2.ID2
									,TMP2.START_STATION_INDEX_IN_ROUTE
									,TMP2.START_TRAINS_STOP
									,ROUTE_STATIONS_CONNECTION.TYPE_OF_TRAINS_STOPS AS 'MIDDLE_TRAINS_STOP'
								FROM ROUTE_STATIONS_CONNECTION
								INNER JOIN (
									SELECT ROUTE_STATIONS_CONNECTION.STATIONS_ID
										,ROUTES_ID AS 'ID2'
										,TMP.FIRST_STATION_ID
										,TMP.START_STATION_INDEX_IN_ROUTE
										,TMP.START_TRAINS_STOP
										,ROUTE_STATIONS_CONNECTION.STATION_INDEX_IN_ROUTE AS 'MIDDLE_STATION_INDEX_IN_ROUTE1'
										,STATIONS.NAME AS 'MIDDLE_STATION_NAME'
									FROM ROUTE_STATIONS_CONNECTION
									INNER JOIN (
										SELECT ROUTES_ID AS 'ID1'
											,STATION_INDEX_IN_ROUTE AS 'START_STATION_INDEX_IN_ROUTE'
											,TYPE_OF_TRAINS_STOPS AS 'START_TRAINS_STOP'
											,STATIONS_ID AS 'FIRST_STATION_ID'
										FROM ROUTE_STATIONS_CONNECTION
										INNER JOIN STATIONS ON STATIONS.ID = ROUTE_STATIONS_CONNECTION.STATIONS_ID
										WHERE STATIONS.NAME = 'Kisvárda-Hármasút'
										) TMP ON ROUTE_STATIONS_CONNECTION.ROUTES_ID = TMP.ID1
									INNER JOIN STATIONS ON STATIONS.ID = ROUTE_STATIONS_CONNECTION.STATIONS_ID
									) TMP2 ON ROUTE_STATIONS_CONNECTION.STATIONS_ID = TMP2.STATIONS_ID
								WHERE ROUTE_STATIONS_CONNECTION.ROUTES_ID != TMP2.ID2
									AND TMP2.MIDDLE_STATION_NAME != 'Debrecen'
									AND FIRST_STATION_ID != ROUTE_STATIONS_CONNECTION.STATIONS_ID
									AND MIDDLE_STATION_INDEX_IN_ROUTE1 > START_STATION_INDEX_IN_ROUTE
								) TMP3 ON TMP3.ID3 = ROUTE_STATIONS_CONNECTION.ROUTES_ID
							INNER JOIN STATIONS ON STATIONS.ID = ROUTE_STATIONS_CONNECTION.STATIONS_ID
							WHERE STATIONS.NAME = 'Debrecen'
								AND ROUTE_STATIONS_CONNECTION.STATION_INDEX_IN_ROUTE > MIDDLE_STATION_INDEX_IN_ROUTE2
							GROUP BY ID2
								,ID3
							HAVING MIN(MIDDLE_STATION_INDEX_IN_ROUTE1)
							) TMP4 ON TRAIN_ROUTE_CONNECTION.ROUTES_ID = TMP4.ID2
						) TMP5 ON TRAIN_ROUTE_CONNECTION.ROUTES_ID = TMP5.ID3
					WHERE START_TRAINS_STOP LIKE CONCAT (
							'%'
							,TMP5.FIRST_TRAIN_TYPE
							,'%'
							)
						AND MIDDLE_TRAINS_STOP LIKE CONCAT (
							'%'
							,TRAINS.TYPE
							,'%'
							)
						AND TMP5.TYPE_OF_TRAINS_STOPS LIKE CONCAT (
							'%'
							,TRAINS.TYPE
							,'%'
							)
					) TMP6 ON ROUTE_STATIONS_CONNECTION.ROUTES_ID = TMP6.ID3
					OR ROUTE_STATIONS_CONNECTION.ROUTES_ID = TMP6.ID2
				) TMP7 INNER JOIN (
				SELECT ROUTES_ID AS 'TMP8_ROUTES_ID'
					,STATION_INDEX_IN_ROUTE AS 'TMP8_STATION_INDEX_IN_ROUTE'
					,STATIONS_ID AS 'TMP8_STATIONS_ID'
				FROM ROUTE_STATIONS_CONNECTION
				) TMP8 ON TMP7.TMP7_ROUTES_ID = TMP8.TMP8_ROUTES_ID
				AND TMP7.TMP7_STATION_INDEX_IN_ROUTE + 1 = TMP8.TMP8_STATION_INDEX_IN_ROUTE INNER JOIN (
				SELECT NEIGHBOUR_ID
					,DISTANCE
					,STATIONS_ID AS 'TMP9_STATIONS_ID'
				FROM NEIGHBOURS
				) TMP9 ON TMP9.NEIGHBOUR_ID = TMP8.TMP8_STATIONS_ID
				AND TMP9.TMP9_STATIONS_ID = TMP7.TMP7_STATIONS_ID GROUP BY ID2
				,ID3 ) TMP10 INNER JOIN (
				SELECT TRAINS_ID AS 'TMP11_TRAINS_ID'
					,CASE 
						WHEN ISNULL(GROUP_CONCAT(CASE 
										WHEN CLASS = 1
											THEN SERVICES
										END separator ';'))
							THEN 0
						ELSE GROUP_CONCAT(CASE 
									WHEN CLASS = 1
										THEN SERVICES
									END separator ';')
						END AS 'CLASS1_SERVICES1'
				FROM WAGONS
				GROUP BY WAGONS.TRAINS_ID
				) TMP11 ON TMP10.FIRST_TRAIN_ID = TMP11.TMP11_TRAINS_ID INNER JOIN (
				SELECT TRAINS_ID AS 'TMP12_TRAINS_ID'
					,CASE 
						WHEN ISNULL(GROUP_CONCAT(CASE 
										WHEN CLASS = 2
											THEN SERVICES
										END separator ';'))
							THEN 0
						ELSE GROUP_CONCAT(CASE 
									WHEN CLASS = 2
										THEN SERVICES
									END separator ';')
						END AS 'CLASS2_SERVICES1'
				FROM WAGONS
				GROUP BY WAGONS.TRAINS_ID
				) TMP12 ON TMP10.FIRST_TRAIN_ID = TMP12.TMP12_TRAINS_ID INNER JOIN (
				SELECT TRAINS_ID AS 'TMP13_TRAINS_ID'
					,CASE 
						WHEN ISNULL(GROUP_CONCAT(CASE 
										WHEN CLASS = 1
											THEN SERVICES
										END separator ';'))
							THEN 0
						ELSE GROUP_CONCAT(CASE 
									WHEN CLASS = 1
										THEN SERVICES
									END separator ';')
						END AS 'CLASS1_SERVICES2'
				FROM WAGONS
				GROUP BY WAGONS.TRAINS_ID
				) TMP13 ON TMP10.SECOND_TRAIN_ID = TMP13.TMP13_TRAINS_ID INNER JOIN (
				SELECT TRAINS_ID AS 'TMP14_TRAINS_ID'
					,CASE 
						WHEN ISNULL(GROUP_CONCAT(CASE 
										WHEN CLASS = 2
											THEN SERVICES
										END separator ';'))
							THEN 0
						ELSE GROUP_CONCAT(CASE 
									WHEN CLASS = 2
										THEN SERVICES
									END separator ';')
						END AS 'CLASS2_SERVICES2'
				FROM WAGONS
				GROUP BY WAGONS.TRAINS_ID
				) TMP14 ON TMP10.SECOND_TRAIN_ID = TMP14.TMP14_TRAINS_ID WHERE DATE (FIRST_TRAIN_START + INTERVAL DISTANCE_BEFORE_START1 / FIRST_TRAIN_SPEED * 60.0 MINUTE) = DATE ('2016-12-11')
				AND SECOND_TRAIN_START + INTERVAL DISTANCE_BEFORE_START2 / SECOND_TRAIN_SPEED * 60.0 MINUTE > FIRST_TRAIN_START + INTERVAL(DISTANCE_BEFORE_START1 + DISTANCE_BETWEEN_START_AND_STOP1) / SECOND_TRAIN_SPEED * 60.0 MINUTE
				-- EXAMPLE WHERE (CLASS1_SERVICES LIKE '%1%' OR CLASS2_SERVICES LIKE '%1%') AND (CLASS1_SERVICES LIKE '%4%' OR CLASS2_SERVICES LIKE '%4%'))
				) TMP_ATSZALLAS INNER JOIN (
				SELECT *
					,EXPLETIVE_TICKET AS 'EXPLETIVE_TICKET1'
				FROM ROUTE_STATIONS_CONNECTION
				) TMP15 ON TMP15.ROUTES_ID = ID2 INNER JOIN (
				SELECT *
					,EXPLETIVE_TICKET AS 'EXPLETIVE_TICKET2'
				FROM ROUTE_STATIONS_CONNECTION
				) TMP16 ON TMP16.ROUTES_ID = ID3 WHERE 1 = 1
				AND TMP15.STATION_INDEX_IN_ROUTE BETWEEN TMP_ATSZALLAS.START_STATION_INDEX_IN_ROUTE
					AND TMP_ATSZALLAS.MIDDLE_STATION_INDEX_IN_ROUTE1
				AND TMP16.STATION_INDEX_IN_ROUTE BETWEEN TMP_ATSZALLAS.MIDDLE_STATION_INDEX_IN_ROUTE2
					AND TMP_ATSZALLAS.STOP_STATION_INDEX_IN_ROUTE2 
					GROUP BY ID2,ID3