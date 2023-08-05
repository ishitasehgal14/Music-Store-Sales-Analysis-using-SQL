create database music_store
/* IMPORTED CLEANED DATASET FROM EXCEL AFTER TRANSFORMING AND CLEANING THE DATA IN POWER BI.
   AN UNKNOWN SYMBOL APPEARED IN THE BEGINNING OF THE FIRST COLUMN WHILE LOADING THE DATA SO 
   RENAMED THE FIRST COLUMN NAME OF ALL THE TABLES */
   
   
   ALTER TABLE album2
   RENAME COLUMN ï»¿album_id TO album_id;
   ALTER TABLE artist
   RENAME COLUMN ï»¿artist_id TO artist_id;
   ALTER TABLE customers
   RENAME COLUMN ï»¿customer_id TO customer_id;
   ALTER TABLE employee
   RENAME COLUMN ï»¿employee_id TO employee_id;
   ALTER TABLE genre
   RENAME COLUMN ï»¿genre_id TO genre_id;
   ALTER TABLE invoice_line
   RENAME COLUMN ï»¿invoice_line_id TO invoice_line_id;
   ALTER TABLE media_type
   RENAME COLUMN ï»¿media_type_id TO media_type_id;
   ALTER TABLE track
   RENAME COLUMN ï»¿track_id TO track_id;
  
   
   /*WHO IS THE SENIORMOST EMPLOYEE BASED ON JOB TITLE?*/
   
   
   SELECT *
   FROM employee
   ORDER BY levels DESC
   LIMIT 1;
   
   
   /*WHICH COUNTRIES HAVE THE MOST INVOICES?*/
   
   
   WITH cte AS(
   SELECT billing_country,count(billing_country) AS num
   FROM invoicss
   GROUP BY billing_country
   ORDER by count(billing_country) DESC)
   SELECT billing_country
   FROM cte 
   LIMIT 5;
   
   
   /*WHAT ARE TOP 3 VALUES OF TOTAL INVOICES?*/
   
   
   SELECT total
   FROM invoicss
   ORDER BY total DESC;
   
   
   /*WHICH CITY HAS THE BEST CUSTOMERS?*/
   
   
   SELECT billing_city,SUM(total) as TOTALL
   FROM invoicss
   GROUP BY billing_city
   ORDER BY TOTALL DESC;
   
   
   /* WHO IS THE BEST CUSTOMER?*/
   
   
   SELECT c.customer_id,c.first_name,c.last_name,SUM(i.total) as totall
   FROM customers c
   JOIN invoicss i
   ON c.customer_id=i.customer_id
   GROUP BY c.customer_id,c.first_name,c.last_name
   ORDER BY SUM(i.total) DESC
   LIMIT 1;
   
   
/*QUERY TO RETURN THE FIRST NAME,LAST NAME, EMAIL AND GENRE OF ALL CUSTOMERS WHO LISTEN TO ROCK MUSIC*/


SELECT DISTINCT c.first_name,c.last_name,c.email,g.genre_id,g.name
FROM customers c  
JOIN invoicss i ON c.customer_id=i.customer_id
JOIN invoice_line il ON i.invoice_id=il.invoice_id
JOIN track t ON il.track_id=t.track_id
JOIN genre g ON t.genre_id=g.genre_id
WHERE g.name LIKE 'Rock'
ORDER BY c.email;


/*TOP 5 ROCK BANDS/ARTISTS AND THEIR NUMBER OF TRACKS*/


SELECT art.name,
COUNT(t.track_id) AS no_of_tracks,art.artist_id
FROM track t 
JOIN album2 a2 ON t.album_id=a2.album_id
JOIN artist art ON a2.artist_id=art.artist_id 
JOIN genre g ON t.genre_id=g.genre_id
WHERE g.name='Rock'
GROUP BY art.name,art.artist_id
ORDER BY no_of_tracks DESC;

   
   /*RETURN THE TRACK NAMES THAT HAVE A SONG LENGTH HIGHER THAN THE AVERAGE SONG LENGTH.RETURN THE
   NAME AND MILLISECONDS FOR EACH TRACK AND ORDER THE SONG LENGTH WITH LONGEST SONGS FIRST.*/


 
   SELECT name, milliseconds
   FROM track
   WHERE milliseconds>(SELECT avg(milliseconds) AS averge_time
   FROM track)
   GROUP BY name,milliseconds
   ORDER BY milliseconds DESC;
   
   
   /* FIND OUT HOW MUCH AMOUNT IS SPENT BY EACH CUSTOMER ON TOP 1 BEST SELLING ARTIST?*/
   
   
   WITH best_selling_artist AS (SELECT art.artist_id,art.name,SUM(il.unit_price*il.quantity) AS total
   FROM invoice_line il
   JOIN invoicss i ON il.invoice_id=i.invoice_id
   JOIN track t ON il.track_id=t.track_id
   JOIN album2 a ON t.album_id=a.album_id
   JOIN artist art ON a.artist_id=art.artist_id
   GROUP BY art.name,art.artist_id
   ORDER BY total DESC
   LIMIT 1
   )
   SELECT c.customer_id,c.first_name,c.last_name,bsa.name,
   SUM(il.unit_price*il.quantity) AS money_spent
   FROM customers c
   JOIN invoicss i ON c.customer_id=i.customer_id
   JOIN invoice_line il ON i.invoice_id=il.invoice_id
   JOIN track t ON il.track_id=t.track_id
   JOIN album2 a2 ON t.album_id=a2.album_id
   JOIN best_selling_artist bsa ON a.artist_id=bsa.artist_id
   GROUP BY 
   c.customer_id,c.first_name,c.last_name,bsa.name
   ORDER BY money_spent;

   
   /*NUMBER OF PURCHASES OF THE MOST POPULAR MUSIC GENRE FOR EACH COUNTRY*/
   
   
   WITH most_popular AS( SELECT g.genre_id,g.name,COUNT(il.quantity) as purchases,c.country,
   ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS row_no
   FROM invoicss i 
   JOIN customers c ON i.customer_id=c.customer_id
   JOIN invoice_line il ON i.invoice_id=il.invoice_id
   JOIN track t ON il.track_id=t.track_id
   JOIN genre g ON t.genre_id=g.genre_id
   GROUP BY g.genre_id,g.name,c.country
   ORDER BY purchases DESC
   )
   SELECT purchases,mp.country,name 
   FROM most_popular mp
   WHERE row_no<=1;
   
   
   
   
