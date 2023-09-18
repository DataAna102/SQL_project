--database creation
CREATE DATABASE sql_min_proj;

--table creation : MEMBER
CREATE TABLE member (
    member_id SERIAL PRIMARY KEY,
    last_name VARCHAR(25) NOT NULL,
    first_name VARCHAR(25),
    address VARCHAR(100),
    city VARCHAR(30),
    phone VARCHAR(15),
    join_date DATE NOT NULL
);


--table : TITLE
CREATE TABLE title (
	title_id SERIAL PRIMARY KEY NOT NULL UNIQUE,
	title VARCHAR(60) NOT NULL,
	description VARCHAR(400) NOT NULL,
	rating VARCHAR(4) CHECK (rating in ('G', 'PG', 'R','NC17', 'NR')),
	category VARCHAR(20) CHECK (category in ('DRAMA', 'COMEDY', 'ACTION', 'CHILD', 'SCIFI', 'DOCUMENTARY')),
	release_date DATE 
);

--table : TITLE_COPY
CREATE TABLE title_copy (
	copy_id SERIAL PRIMARY KEY NOT NULL UNIQUE,
	title_id INT  NOT NULL,
	status VARCHAR(15) CHECK (status in ('AVAILABLE', 'DESTROYED', 'RENTED', 'RESERVED')),
	constraint fk_title_id
	FOREIGN KEY (title_id)
	REFERENCES title(title_id)
);

--table : RENTAL
CREATE TABLE rental (
	book_date DATE DEFAULT CURRENT_DATE NOT NULL,
	member_id SERIAL,
	copy_id SERIAL,
	act_ret_date date,
	exp_ret_date DATE DEFAULT CURRENT_DATE + 2,
	title_id INT,
	PRIMARY KEY (book_date),
	constraint fk_member_id FOREIGN KEY (member_id) REFERENCES member(member_id),
	constraint fk_copy_id FOREIGN KEY (copy_id) REFERENCES title_copy(copy_id),
	constraint fk_title_id FOREIGN KEY (title_id) REFERENCES title_copy(title_id)
);

--table : RESERVATION
CREATE TABLE reservation (
	res_date DATE PRIMARY KEY NOT NULL UNIQUE,
	member_id SERIAL NOT NULL,
	title_id INT NOT NULL,
	constraint fk_member_id FOREIGN KEY (member_id) REFERENCES member(member_id),
	constraint fk_title_id FOREIGN KEY (title_id) REFERENCES title(title_id)
);

--verify table
SELECT * FROM member
SELECT * FROM rental
SELECT * FROM reservation
SELECT * FROM title
SELECT * FROM title_copy

--create sequence
CREATE SEQUENCE member_id_seq
START WITH 101;

CREATE SEQUENCE title_id_seq
START WITH 92;

--verify the sequences
SELECT schemaname ||','|| sequencename as sequence_name, increment_by, last_value as last_number
FROM pg_sequences
WHERE sequencename in ('member_id_seq', 'title_id_seq');


-- insert details into title
INSERT INTO title (title_id, title, description, rating, category, release_date)
VALUES
	(nextval('title_id_seq'), 'william and christmas too', 'All of williams friends makes a christmas list for santa
	, but william has yet to add his own wish list', 'G', 'CHILD', '05-OCT-1995'),
	(nextval('title_id_seq'), 'alien again', 'yet another installation of science fiction history. can the heroin save the planet from the
	 alien life form?', 'R', 'SCIFI', '19-MAY-1995'),
	 (nextval('title_id_seq'), 'the glob', 'a meteor crasher near a small american town and unleasess carnivorous goo in this classic', 'NR',
	 'SCIFI', '12-AUG-1995'),
	 (nextval('title_id_seq'), 'my day off', 'with a little luck and alot of ingenuity, a teeneger skips school for a day in new york', 'PG',
	 'COMEDY', '12-JUL-1995'),
	 (nextval('title_id_seq'), 'miracle on ice', 'a six year old has doubt about santa claus, but she discovers that miracle
	  really do exists', 'PG', 'DRAMA', '12-SEP-1995'),
	  (nextval('title_id_seq'), 'soda gang', 'a discovering a cache of drugs, young man finds themselves against a vicious gang',
	  'NR', 'ACTION', '01-JUN-1995'),
	  (nextval('title_id_seq'), 'home alon', 'the little one gets left behind while the family goes for the trip to california on christmas holiday. how would the little boy will survive now',
	  'PG', 'COMEDY', '01-APR-1992');
	  
--verify the table
SELECT * FROM title;

--insert data into member table
INSERT INTO member (member_id, last_name, first_name, address, city, phone, join_date)
VALUES
	(nextval('member_id_seq'), 'velasquez', 'carmen', '283 king street', 'seattle', '206-899-6666', '1990-03-08'),
	(nextval('member_id_seq'), 'ngao', 'ladoris', '5 modrany', 'bratislava', '586-355-8882', '1990-03-08'),
	(nextval('member_id_seq'), 'nagayama', 'midori', '68 via centrale', 'Sao Paulo', '254-852-5764', '1991-06-17'),
	(nextval('member_id_seq'), 'quick-to-see', 'mark', '6921 king way', 'lagos', '63-559-7777', '1990-04-07'),
	(nextval('member_id_seq'), 'ropeburn', 'audry', '86 chu street', 'hong kong', '41-559-87', '1991-01-18'),
	(nextval('member_id_seq'), 'urguhart', 'molly', '3035 laurier', 'quebec', '418-542-9988', '1991-01-18');

--add movies copies into title table
INSERT INTO title_copy (copy_id, title_id, status)
VALUES
	(1, 92, 'AVAILABLE'),
	(2, 93, 'AVAILABLE'),
	(3, 94, 'RENTED'),
	(4, 95, 'AVAILABLE'),
	(5, 96, 'AVAILABLE'),
	(6, 97, 'AVAILABLE'),
	(7, 98, 'RENTED');
	
--add details into rental id
INSERT INTO rental ( title_id, copy_id, member_id, book_date, act_ret_date, exp_ret_date)
VALUES
 	(92, 1, 101, current_date - 3, current_date - 1, current_date - 2),
	(93, 2, 102, current_date - 1, current_date + 1, null),
	(94, 3, 103, current_date - 2, current_date, null),
	(97, 1, 106, current_date - 4, current_date - 2, current_date - 2);
	
--create view : TITLE_AVAIL
CREATE VIEW title_avail AS 
SELECT t.title_id, c.copy_id, c.status, r.exp_ret_date
FROM title t
INNER JOIN title_copy c ON t.title_id = c.title_id
LEFT JOIN rental r ON c.copy_id = r.copy_id AND c.title_id = r.title_id;

--verity the view
SELECT * FROM title_avail

--make changes data into tables
--add new data into table TITLE with TITLE_COPY record too.
INSERT INTO title (title_id, title, description, rating, category, release_date)
VALUES
	(nextval('title_id_seq'), 'interstellar wars', 'furistic interstellar action movie. can the rebels save the humans from evil empire?',
	'PG', 'SCIFI', '07-JUL-77');

INSERT INTO title_copy (copy_id, title_id, status)
VALUES
	(8, 99, 'AVAILABLE');

--add new data into reservation
INSERT INTO reservation (title_id, member_id, res_date)
VALUES
	(98, 101, current_date + 1),
	(97, 104, current_date + 2);

--record rental information and update
INSERT INTO rental (title_id,copy_id,member_id)
VALUES
(98,1,101);

UPDATE title_copy
SET status = 'RENTED' WHERE title_id = 98 and copy_id = 1;

DELETE FROM reservation WHERE member_id = 101;

SELECT * FROM title_avail ORDER BY title_id DESC;

--add price column to the TITLE table with len.08 dig and 02 decimal places.
ALTER TABLE title
ADD COLUMN price NUMERIC(8,2);

SELECT * FROM title;

--updating rows
UPDATE title
SET price = 35
WHERE title_id = 95;

UPDATE title
SET price = 40
WHERE title_id = 96;

UPDATE title
SET price = 30
WHERE title_id = 97;

UPDATE title
SET price = 35
WHERE title_id = 98;

UPDATE title
SET price = 35
WHERE title_id = 99;

--update multiple rows at once
UPDATE title
SET rating = 'G',
    category = 'CHILD',
    release_date = '1999-04-10'
WHERE title_id = 3;

UPDATE title
SET rating = 'G',
    category = 'CHILD',
    release_date = '1999-04-10'
WHERE title_id = 4;

UPDATE title
SET rating = 'R',
    category = 'SCIFI',
    release_date = '1998-04-10'
WHERE title_id = 5;

UPDATE title
SET rating = 'NR',
    category = 'SCIFI',
    release_date = '1997-04-10'
WHERE title_id = 6;

UPDATE title
SET rating = 'PG',
    category = 'COMEDY',
    release_date = '1997-04-10'
WHERE title_id = 7;

UPDATE title
SET rating = 'PG',
    category = 'DRAMA',
    release_date = '1996-04-10'
WHERE title_id = 8;

UPDATE title
SET rating = 'PG',
    category = 'COMEDY',
    release_date = '1998-04-10'
WHERE title_id = 9;

UPDATE title
SET rating = 'G',
    category = 'SCIFI',
    release_date = '2012-04-10'
WHERE title_id = 10;

--add constraint to price
ALTER TABLE title
ALTER price SET NOT NULL;

--query report
-- Define a variable for the report title
DO $$
DECLARE
    report_title text := 'CUSTOMER HISTORY REPORT';
    result_record record;
BEGIN
    -- Print the report title
    RAISE NOTICE 'REPORT TITLE: %', report_title;

    -- Query the data and display it
    FOR result_record IN (
        SELECT
            m.first_name || ' ' || m.last_name AS member,
            t.title,
            r.book_date,
            r.act_ret_date - r.book_date AS duration
        FROM
            member m
        JOIN
            rental r ON r.member_id = m.member_id
        JOIN
            title t ON r.title_id = t.title_id
        ORDER BY
            member
    ) LOOP
        RAISE NOTICE 'MEMBER: %, TITLE: %, BOOK DATE: %, DURATION: %',
                     result_record.member, result_record.title, result_record.book_date, result_record.duration;
    END LOOP;
END $$;
