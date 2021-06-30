-- creating partition table by range
CREATE TABLE employees (
    id INT NOT NULL,
    fname VARCHAR(30),
    lname VARCHAR(30),
    hired DATE NOT NULL DEFAULT '1970-01-01',
    separated DATE NOT NULL DEFAULT '9999-12-31',
    job_code INT NOT NULL,
    store_id INT NOT NULL
)
PARTITION BY RANGE (store_id) (
    PARTITION p0 VALUES LESS THAN (6),
    PARTITION p1 VALUES LESS THAN (11),
    PARTITION p2 VALUES LESS THAN (16),
    PARTITION p3 VALUES LESS THAN MAXVALUE
);

-- inserting data into the table
INSERT INTO employees (id, fname, lname, job_code, store_id)
VALUES (1, 't1', 't1-l', 100, 1),
       (2, 't2', 't2-l', 100, 2),
       (3, 't3', 't3-l', 100, 3),
       (4, 't4', 't4-l', 100, 4),
       (5, 't5', 't5-l', 100, 1),
       (6, 't6', 't6-l', 100, 2),
       (7, 't7', 't7-l', 100, 5),
       (8, 't8', 't8-l', 100, 5),
       (9, 't9', 't9-l', 100, 2),
       (10, 't10', 't10-l', 100, 6),
       (11, 't11', 't11-l', 100, 7),
       (12, 't12', 't12-l', 100, 5),
       (13, 't13', 't13-l', 100, 8),
       (14, 't14', 't14-l', 100, 9),
       (15, 't15', 't15-l', 100, 10),
       (16, 't16', 't16-l', 100, 11),
       (17, 't17', 't17-l', 100, 12),
       (18, 't18', 't18-l', 100, 15),
       (19, 't19', 't19-l', 100, 13),
       (20, 't20', 't20-l', 100, 14),
       (21, 't21', 't21-l', 100, 13),
       (22, 't22', 't22-l', 100, 12),
       (23, 't23', 't23-l', 100, 16);

select * from employees where store_id >= 5;
select * from employees PARTITION (p0) where store_id >= 5;

show create table employees;

-- query partitions
select * from employees PARTITION (p0);
select * from employees PARTITION (p1);
select * from employees PARTITION (p2);
select * from employees PARTITION (p3);


INSERT INTO employees (id, fname, lname, job_code, store_id)
VALUES (27,'t27','t27-l', 124, 20),
       (28,'t27','t27-l', 124, 21),
       (29,'t27','t27-l', 124, 22),
       (30,'t27','t27-l', 124, 23),
       (31,'t27','t27-l', 124, 25),
       (32,'t27','t27-l', 124, 24),
       (33,'t27','t27-l', 124, 22),
       (34,'t27','t27-l', 124, 23),
       (35,'t27','t27-l', 124, 26),
       (36,'t27','t27-l', 124, 21),
       (37,'t27','t27-l', 124, 20),
       (38,'t27','t27-l', 124, 27),
       (39,'t27','t27-l', 124, 28),
       (40,'t27','t27-l', 124, 29),
       (41,'t27','t27-l', 124, 30);


-- query partitions
select * from employees PARTITION (p3);
select * from employees where id=25;
select * from employees PARTITION (p3) where id=25;

-- this will show the details partition view of any table
SELECT * from information_schema.PARTITIONS where TABLE_SCHEMA='ptest';

-- deleting all rows from partition 3
ALTER TABLE employees TRUNCATE PARTITION p3;

-- this will automatically inserted into partition 3 as the store id is greater than 16
INSERT INTO employees (id, fname, lname, job_code, store_id)
VALUES (27,'t27','t27-l', 124, 20),
       (28,'t27','t27-l', 124, 21),
       (29,'t27','t27-l', 124, 22),
       (30,'t27','t27-l', 124, 23),
       (31,'t27','t27-l', 124, 25),
       (32,'t27','t27-l', 124, 24),
       (33,'t27','t27-l', 124, 22),
       (34,'t27','t27-l', 124, 23),
       (35,'t27','t27-l', 124, 26),
       (36,'t27','t27-l', 124, 21),
       (37,'t27','t27-l', 124, 20),
       (38,'t27','t27-l', 124, 27),
       (39,'t27','t27-l', 124, 28),
       (40,'t27','t27-l', 124, 29),
       (41,'t27','t27-l', 124, 30);

select * from employees PARTITION (p3);

-- dropping a partition. it will drop all the rows inside that partition.
ALTER TABLE employees DROP PARTITION p3;

-- adding the partition through alter again
ALTER TABLE employees ADD PARTITION (PARTITION p3 VALUES LESS THAN MAXVALUE);

-- this will automatically inserted into partition 3 as the store id is greater than 16
INSERT INTO employees (id, fname, lname, job_code, store_id)
VALUES (27,'t27','t27-l', 124, 20),
       (28,'t27','t27-l', 124, 21),
       (29,'t27','t27-l', 124, 22),
       (30,'t27','t27-l', 124, 23),
       (31,'t27','t27-l', 124, 25),
       (32,'t27','t27-l', 124, 24),
       (33,'t27','t27-l', 124, 22),
       (34,'t27','t27-l', 124, 23),
       (35,'t27','t27-l', 124, 26),
       (36,'t27','t27-l', 124, 21),
       (37,'t27','t27-l', 124, 20),
       (38,'t27','t27-l', 124, 27),
       (39,'t27','t27-l', 124, 28),
       (40,'t27','t27-l', 124, 29),
       (41,'t27','t27-l', 124, 30);

-- how to optimally search through a partitioned tables it is shown with this explain command
-- This first select will search all the partition as we are not using the partition key in the where clause
EXPLAIN SELECT * FROM employees WHERE id= 23;
-- This second query only search the partition p0
EXPLAIN SELECT * FROM employees WHERE id= 3 and store_id <6;
-- This query will search two partition p0 and p1 as the range falls into p0 and p1
EXPLAIN SELECT * FROM employees WHERE id= 3 and store_id < 11;
-- This query will only search in partition p3
EXPLAIN SELECT * FROM employees PARTITION (p3) WHERE id=3;

-- ### We can't add new partition like these because the last partition (p3)
-- is already declared with range maxvalue.
ALTER TABLE employees ADD PARTITION (PARTITION p4 VALUES LESS THAN (21));

-- a workaround for this issue to to reorganize and splitting partition p3 into p3 and p4
ALTER TABLE employees REORGANIZE PARTITION p3 INTO (
    PARTITION p3 VALUES LESS THAN (25),
    PARTITION p4 VALUES LESS THAN MAXVALUE
    );

-- this will show the details partition view of any table
SELECT * from information_schema.PARTITIONS where TABLE_SCHEMA='ptest';

SELECT * FROM employees PARTITION (p3);
SELECT * FROM employees PARTITION (p4);

-- Joining the p3 and p3 into p4 | basically reversing the previous split
ALTER TABLE employees REORGANIZE PARTITION p3, p4 INTO (
    PARTITION p3 VALUES LESS THAN MAXVALUE
    );

-- this will show the details partition view of any table
SELECT * from information_schema.PARTITIONS where TABLE_NAME='employees';

SELECT * FROM employees PARTITION (p3);

-- ### testing what will happen when the partition by column is null
-- making the store_id column nullable
ALTER TABLE employees MODIFY COLUMN store_id int;
-- inserting a new row with null store_id
INSERT INTO employees (id, fname, lname, job_code, store_id)
    VALUES (42, 't42', 't42-l', 102, NULL);

-- as we can see that without the store id these record is stored into p0
-- because of the partition condition anything whose store id is less than 6 will fall under p0
EXPLAIN SELECT * FROM employees PARTITION (p0) WHERE id = 42;

-- Testing if changing the partition by column value move the row in the correct partition
UPDATE employees SET store_id = 7 where id=42;

-- It does move the data to different partition
EXPLAIN SELECT * FROM employees PARTITION (p1) WHERE id = 42;
