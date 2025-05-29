--Q1: who is the senior most employee based on job title?
select*
from employee 
order by levels desc 
limit 1;

--Q2:which country have more invoice
select*from invoice;
select billing_country ,count(total) totalinvoice
from invoice 
group by  billing_country 
order by  totalinvoice desc;
--METHOD2
select billing_country , totalspend 
from(select billing_country ,count(total) totalspend
from invoice 
group by  billing_country 
order by  totalspend desc);

--Q3:what are top3 values of total invoice
select  distinct total
from invoice
order by total desc
limit 3;

-- Q4:which city has the best customer ? we would like to throw a promotional music festival in the city we made the most money
--wirte query that returens one city that has the highest sum of invoice totals return both the city name and sum of all invoice total
select*from invoice;
select billing_city ,sum(total) as  highest 
from invoice 
group by billing_city 
order by highest desc
limit 1;

--Q5:who is the best customer ? the cutomer who has spent the most money will 
--be declared the best customer write query that returns the person who has spent the most money?
select*from customer;
select*from invoice;
select c.customer_id ,c.first_name,c.last_name,sum(invoice.total) total 
from  customer c
join invoice 
on c.customer_id=invoice.customer_id
group by c.customer_id
order by total desc
limit 1;


---MODERATE
--1.write query return the email,firstname,lastname and genere of all rock music listeners return
--your list orderd alphabetically by email starting with a.
select  distinct first_name,last_name ,email
from customer 
join invoice
on customer.customer_id=invoice.customer_id
join invoice_line
on invoice.invoice_id=invoice_line.invoice_id
where track_id in (select track_id  from track join genre on track.genre_id=genre.genre_id where genre.name like 'Rock')
order by email;

--Q2:lets invite the artists who have written the moc rocmkmusic in 
--our dataset write query that returns the artist name and total track count of the top 10 rock boands
select artist.name,artist.artist_id ,count( artist.artist_id)  n
from track
join album on album.album_id=track.album_id
join artist on  artist.artist_id=album.artist_id 
join genre on genre. genre_id=track.genre_id 
where genre.name like'Rock' 
group by artist.artist_id 
order by  n desc
limit 10;

---Q3:return all the track names that have a song length longer than the average song lenght.
--return the name and milliseconds for each track .order by the song length with the longest songs listed first.
select*from track;
select avg(milliseconds) from track;
select name,milliseconds 
from track 
where milliseconds>(select avg(milliseconds) as length
                     from track )
					 order by milliseconds desc;




--ADVANCE
--Q1find how much amount spent by each customer on artists write a query to return customer name artsist name and total spent
with highestsales as (select ar.artist_id as artistid,ar.name as artistname,
sum(il.unit_price*il.quantity) as totalspent
from invoice_line il
join track  t on  t.track_id=il.track_id
join album a on  a.album_id=t.album_id
join artist ar on a.artist_id=ar.artist_id
group by 1
order by 3 desc
limit 1)
select c.customer_id,c.first_name,c.last_name,hs.artistname,sum(il.unit_price*il.quantity) as totalspent from invoice i
join customer c on  c.customer_id=i.customer_id
join invoice_line il on  i.invoice_id=il.invoice_id
join track t on t.track_id=il.track_id
join album  a on a.album_id=t.album_id
join highestsales hs on hs.artistid=a.artist_id
group by 1 ,2 ,3 ,4
order by 5 desc;

--Q2 we want to find out the most popular music genere for each country
--we determine the most popular genre as the genre with the highes amount of purchase
--write query that returns each country along with the top genre 
--for countries wwwwrite the maximum no.of purhaes is shared return all genres
with top_genre as(select g.name ,c.country,count(il.quantity) as noofpurchase,g.genre_id,
row_number() over(partition by c.country order by count(il.quantity) desc)
from customer c 
join invoice i on c.customer_id=i.customer_id
join invoice_line il  on i.invoice_id=il.invoice_id
join  track t on t.track_id=il.track_id
join genre g on t.genre_id= g.genre_id
group by 1,2,4
order by 2 asc,3 desc)
max
select*from top_genre where row_number<=1;

--WITH RECURSIVE METHOD
WITH RECURSIVE salespercountry as (select g.name ,c.country,
count(il.quantity) as noofpurchase,g.genre_id
from customer c 
join invoice i on c.customer_id=i.customer_id
join invoice_line il  on i.invoice_id=il.invoice_id
join  track t on t.track_id=il.track_id
join genre g on t.genre_id= g.genre_id
group by 1,2,4
order by 3 ),
maxcountry as(select max(noofpurchase) as maxnumber ,country 
from salespercountry group by 2
order by 2)
select salespercountry.* from salespercountry join maxcountry 
on salespercountry.country=maxcountry.country
where salespercountry.noofpurchase=maxcountry.maxnumber;


--Q3write query that determines the customer that has spent the most on music for each country.
--write query that returns the countru along with the top customer
--and how they spent.for countries where the top amount spent is shared,provide
--all customers who spent this amount
select*from customer;  --customer_id
select*from artist;--artist_idname
select*from employee;
select*from invoice;--customer_id
select*from track;--album_idgenreid,mediatypeid
select*from album;--album_id,title,aritstid

select*from playlist;--playlist_id,name
select*from media_type;--media_type_id,name
select*from invoice_line;--inovice_id,track_id,invoice_line_id,unitprice,quantity
select*from employee;
select*from genre;--genre_id,name
select*from playlist_track;--playlist_id,track_id


 with recursive countrytotal as(select c.customer_id,c.first_name,
c.last_name ,i.billing_country ,sum(i.total) total 
from invoice i
join customer c on c.customer_id=i.customer_id
group by 1,2,3,4
order by  1,5 desc),
maxcountry as(select billing_country ,max(total) as totalspending
from countrytotal 
group by billing_country )
select c.billing_country,c.total,c.first_name,c.last_name,c.customer_id
from countrytotal c join maxcountry  m on
c.billing_country=m.billing_country
where c.total=m.totalspending
order by 1;

--with cte
 with countrytotal as(select billing_country,c.first_name,c.last_name,c.customer_id ,sum(total) as total,
row_number() over(partition by billing_country order by sum(total) desc)rownumber
from invoice i
join customer c on  i.customer_id=c.customer_id
group by 1,2,3,4
order by 1 asc,5 desc)
select*from countrytotal where rownumber<=1;
