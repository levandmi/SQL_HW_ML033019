use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(concat(first_name, " ", last_name)) as "Joined_Name" FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT * FROM actor WHERE first_name = "JOE";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM  country 
WHERE country in ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
-- as the difference between it and VARCHAR are significant)
ALTER TABLE actor ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name) from actor group by last_name having count(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor set first_name = "HARPO"  WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor set first_name = "GROUCHO"  WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT  staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON
staff.address_id=address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment
SELECT staff_id, sum(amount) 
FROM payment 
WHERE payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 23:59:59'
GROUP BY staff_id;

SELECT staff_id, sum(amount) 
FROM payment 
WHERE payment_date like '2005-08-%'
GROUP BY staff_id;

-- 6c List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select title, count(actor_id) as "Number of Actors" FROM film
JOIN film_actor ON
film.film_id=film_actor.film_id
GROUP BY title;

-- 6d How many copies of the film Hunchback Impossible exist in the inventory system?
 SELECT title, count(inventory_id) as "Total in Inventory" FROM inventory
 JOIN film ON
 inventory.film_id=film.film_id
 WHERE title = "Hunchback Impossible";
 
 -- 6e Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
 SELECT first_name, last_name, sum(amount) as "Total Amount Paid" FROM payment
 JOIN customer ON
 payment.customer_id=customer.customer_id
 group by payment.customer_id
 ORDER BY last_name;
 
-- 7a The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles 
-- of movies starting with the letters K and Q whose language is English.
SELECT title FROM film where language_id =(
SELECT language_id from `language` where `name` = "English") and title like 'K%' or title like 'Q%';

-- 7b Use subqueries to display all actors who appear in the film Alone Trip
SELECT first_name, last_name FROM actor WHERE actor_id IN (
SELECT actor_id FROM film_actor WHERE film_id =(
SELECT film_id FROM film WHERE title = "Alone Trip"));

-- 7c You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT first_name, last_name, email, country FROM customer cus
JOIN address ad ON cus.address_id=ad.address_id
JOIN city cit ON cit.city_id=ad.city_id
JOIN country cou ON cou.country_id=cit.country_id
WHERE country = "Canada";

-- 7d Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT film.title as "Film Title", category.`name` as "Movie Category" FROM film
JOIN film_category ON film.film_id=film_category.film_id
JOIN category ON category.category_id=film_category.category_id
WHERE category.`name` = "Family";

-- 7e Display the most frequently rented movies in descending order.
SELECT film.title as "Film_Title", count(rental.rental_id) as "Times_Rented" FROM film
JOIN inventory ON inventory.film_id=film.film_id
JOIN rental ON rental.inventory_id=inventory.inventory_id
GROUP BY film.title
ORDER BY Times_Rented DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, sum(payment.amount) FROM payment
JOIN customer ON customer.customer_id=payment.customer_id
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city, country FROM store
JOIN address ad ON store.address_id=ad.address_id
JOIN city cit ON cit.city_id=ad.city_id
JOIN country cou ON cou.country_id=cit.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)


SELECT ca.`name` as "Genre", sum(pay.amount) as "Gross_Revenue" FROM category ca
JOIN film_category as fc ON ca.category_id=fc.category_id
JOIN inventory inv on inv.film_id=fc.film_id
JOIN rental ren ON ren.inventory_id=inv.inventory_id
JOIN payment pay ON pay.rental_id=ren.rental_id
GROUP BY ca.`name`
ORDER BY Gross_Revenue DESC;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Answer_8a AS
SELECT ca.`name` as "Genre", sum(pay.amount) as "Gross_Revenue" FROM category ca
JOIN film_category as fc ON ca.category_id=fc.category_id
JOIN inventory inv on inv.film_id=fc.film_id
JOIN rental ren ON ren.inventory_id=inv.inventory_id
JOIN payment pay ON pay.rental_id=ren.rental_id
GROUP BY ca.`name`
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Answer_8a;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW answer_8a;


 

