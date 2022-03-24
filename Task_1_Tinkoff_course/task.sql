--1
SELECT DISTINCT(partner_nm)
FROM cource_analytics.partner p
	INNER JOIN cource_analytics.legend l
		ON l.partner_rk = p.partner_rk
WHERE p.partner_rk NOT IN (SELECT partner_rk FROM cource_analytics.location)
-- Ответ: Ferrari, Porshe, Tesla

--2
WITH table1 as(
SELECT q.quest_nm, q.quest_rk, COUNT(q.quest_rk) as start_q_1
FROM cource_analytics.quest q
	INNER JOIN cource_analytics.game g
		ON q.quest_rk = g.quest_rk
WHERE  g.game_flg = 1 AND CAST(g.game_dttm AS TEXT) LIKE '%-01-%' 	
GROUP BY q.quest_nm, q.quest_rk
),
table2 as(
SELECT q.quest_rk, COUNT(q.quest_rk) as all_q_1
FROM cource_analytics.quest q
	INNER JOIN cource_analytics.game g
		ON q.quest_rk = g.quest_rk
WHERE CAST(g.game_dttm AS TEXT) LIKE '%-01-%' 	
GROUP BY q.quest_rk
),
table3 as(
SELECT q.quest_rk, COUNT(q.quest_rk) as start_q_2
FROM cource_analytics.quest q
	INNER JOIN cource_analytics.game g
		ON q.quest_rk = g.quest_rk
WHERE  g.game_flg = 1 AND CAST(g.game_dttm AS TEXT) LIKE '%-02-%' 	
GROUP BY q.quest_nm, q.quest_rk
),
table4 as(
SELECT q.quest_rk, COUNT(q.quest_rk) as all_q_2
FROM cource_analytics.quest q
	INNER JOIN cource_analytics.game g
		ON q.quest_rk = g.quest_rk
WHERE CAST(g.game_dttm AS TEXT) LIKE '%-02-%' 	
GROUP BY q.quest_rk
),
table5 as(
SELECT table1.quest_nm, 
	   table1.start_q_1, 
	   table2.all_q_1, 
	   table3.start_q_2, 
	   table4.all_q_2,
	   table1.start_q_1 / table2.all_q_1 :: FLOAT as january,
	   table3.start_q_2 / table4.all_q_2 :: FLOAT as february
FROM table1 INNER JOIN table2
	ON table1.quest_rk = table2.quest_rk
		INNER JOIN table3
			ON table2.quest_rk = table3.quest_rk
				INNER JOIN table4
					ON table3.quest_rk = table4.quest_rk
)
SELECT quest_nm, abs(january - february) :: FLOAT as final
FROM table5
ORDER BY final DESC
--Ответ: Начало - Москва

--3
with table_1 as(
SELECT e.employee_rk, l.city_nm, e.last_name, time
FROM cource_analytics.game g
	INNER JOIN cource_analytics.employee e
		ON g.employee_rk = e.employee_rk
			INNER JOIN cource_analytics.quest q
				ON q.quest_rk = g.quest_rk
					INNER JOIN cource_analytics.location l
						ON q.location_rk = l.location_rk
WHERE g.finish_flg = 1 AND e.gender_cd = 'f'
),
table_2 as(
SELECT city_nm, last_name, (SUM(time) / COUNT(time)) :: FLOAT as final
FROM table_1
GROUP BY city_nm, last_name
),
table_3 as(
SELECT 
	*,
	dense_rank() OVER(partition by city_nm ORDER BY final ASC)
FROM table_2
ORDER BY city_nm),
table_4 as(
SELECT last_name, final, dense_rank
FROM table_3
WHERE dense_rank = 2)
SELECT * 
FROM table_4
WHERE final = (SELECT min(final) FROM table_4)
ORDER BY final ASC, last_name ASC
LIMIT 1
-- Ответ: Робертс














