--Question set 1
--find senior most employee

SELECT * FROM employee
ORDER BY levels desc
LIMIT 1;

--countries have most invoices

SELECT COUNT (*) as total_invoices,billing_country FROM invoice
GROUP BY billing_country 
ORDER BY total_invoices desc;

--top 3 values of total invoice

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

--which city has best customers

SELECT SUM(total) as invoice_total, billing_city FROM invoice
GROUP BY  billing_city
ORDER BY invoice_total desc;

--who is the best customer

SELECT customer. customer_id, customer. first_name, customer. last_name, SUM(invoice. total) as total
FROM customer
JOIN invoice ON customer. customer_id = invoice. customer_id
GROUP BY  customer. customer_id
ORDER BY total DESC
LIMIT 1;

--Question set 2
--return email, firstname, last name & genre of rock music listners. order email alphabetically

SELECT DISTINCT customer. first_name, customer. last_name, customer. email 
FROM customer
JOIN invoice ON customer. customer_id = invoice. customer_id
JOIN invoice_line ON invoice. invoice_id = invoice_line. invoice_id
WHERE track_id IN (
	SELECT track_id FROM track
	JOIN genre ON track. genre_id = genre. genre_id
	WHERE genre. name LIKE 'Rock'
)
ORDER BY customer. email;

--artist who has written most rock music with total track count

SELECT artist. artist_id, artist. name, COUNT(artist. artist_id) AS total_songs
FROM track
JOIN album ON album. album_id = track. album_id
JOIN artist ON artist. artist_id = album. artist_id
JOIN genre ON genre. genre_id = track. genre_id
WHERE genre. name LIKE 'Rock'
GROUP BY artist. artist_id
ORDER BY total_songs DESC
LIMIT 10;

--return track names that gave a song length longer than average

SELECT name, milliseconds FROM track
WHERE milliseconds > (SELECT Avg(milliseconds) 
					  FROM  track)
ORDER BY milliseconds desc;

--Question set 3
--find amount spent by each customer on artist. return cust. name, art. name, and total spendings.
 
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
	SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(il.unit_price * il.quantity) As amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--find out most popular music genre for each country

WITH popular_genre AS
(
	SELECT COUNT(invoice_line.quantity) AS purchase, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

--write query that determines the customer that has spent the most on music for each country

WITH RECURSIVE
	customer_with_country AS (
	SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 2,3 DESC
	),
	country_max_spending AS(
	SELECT billing_country, MAX(total_spending) AS max_spending
	FROM customer_with_country
	GROUP BY billing_country)
	
SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customer_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;


