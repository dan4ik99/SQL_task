drop table if exists Installs;
drop table if exists Payments;

create table Installs(
        installs_id serial primary key,
		player_id int not null,
        install_date date not null
);

create table Payments(
       	payments_id serial primary key,
		date_ date not null,
		value_ int not null,
		installs_id int not null,
		player_id int,
        
        constraint fk
                foreign key (installs_id)
                references Installs(installs_id)
);


insert into Installs
	(player_id, install_date) 
values
	(1, '2019-09-01'),
	(2, '2019-09-05'),
	(3, '2019-09-07'),
	(1, '2019-09-09'),
	(2, '2019-09-11'),
	(3, '2019-09-15'),
	(2, '2019-10-21'),
	(3, '2019-12-13');
	
	
insert into Payments
	(date_, value_, installs_id, player_id) 
values
	('2019-09-01', 200, 1, 1),
	('2019-09-05', 300, 2, 2),
	('2019-09-07', 100, 3, 3),
	('2019-09-09', 500, 4, 6),
	('2019-09-11', 400, 5, 7),
	('2019-09-15', 1000, 6, 8),
	('2019-11-07', 200, 7, 9),
	('2019-11-07', 200, 8, 10);

---------------------------------------------------

CREATE TEMPORARY TABLE temp AS (
with recursive d as(
SELECT * FROM (
 	SELECT
    	ROW_NUMBER() OVER (ORDER BY i.install_date ASC) AS rownumber,
    	i.install_date,
		p.value_,
		1 n
	FROM Installs i INNER JOIN Payments p
		ON i.installs_id = p.installs_id
	WHERE
		i.install_date BETWEEN '2019-09-01' AND '2019-09-30'
) AS foo
WHERE rownumber >= 1
	
UNION
	
SELECT * FROM (
 	SELECT
    	ROW_NUMBER() OVER (ORDER BY install_date ASC) AS rownumber,
    	install_date,
		value_,
		n + 1
	FROM 
		d
	WHERE
		install_date BETWEEN '2019-09-01' AND '2019-09-30'
)AS foo2 WHERE rownumber >= 2) 
SELECT
	n,
	install_date AS final_date,
	sum(value_) over(PARTITION BY n order by install_date) AS payments_sum
FROM 
	d
)


SELECT
	i.install_date AS install_date, 
	t.final_date,
	t.payments_sum
FROM
	temp t INNER JOIN Installs i
		ON i.installs_id = t.n
