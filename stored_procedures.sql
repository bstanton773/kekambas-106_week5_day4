-- Stored Procedures!

SELECT *
FROM customer c 
WHERE loyalty_member = TRUE;

-- If you don't have the loyalty member column, execute the following command:
ALTER TABLE customer 
ADD COLUMN loyalty_member BOOLEAN DEFAULT FALSE;

-- Reset all customers loyalty to FALSE
UPDATE customer 
SET loyalty_member = FALSE;



-- Create a Procedure that will set anyone who has spent >= $100 to loyalty members

-- Query to get the customer who have spent >= $100

SELECT customer_id
FROM payment
GROUP BY customer_id
HAVING SUM(amount) >= 100;

-- Update all customers who have spent more than $100
UPDATE customer 
SET loyalty_member = TRUE 
WHERE customer_id IN (
	SELECT customer_id
	FROM payment
	GROUP BY customer_id
	HAVING SUM(amount) >= 100
);

-- Put into a stored procedure
CREATE OR REPLACE PROCEDURE update_loyalty_status(loyalty_min NUMERIC(5,2) DEFAULT 100.00)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE customer 
	SET loyalty_member = TRUE 
	WHERE customer_id IN (
		SELECT customer_id
		FROM payment
		GROUP BY customer_id
		HAVING SUM(amount) >= loyalty_min
	);
END;
$$;

-- Execute the Procedure with CALL 
CALL update_loyalty_status();


SELECT *
FROM customer c 
WHERE loyalty_member = TRUE;

-- Find a customer who is close to the minimum
SELECT customer_id, SUM(amount)
FROM payment p 
GROUP BY customer_id 
HAVING SUM(amount) BETWEEN 95 AND 100;


-- Choose one of the customers and push them over the threshold
-- by adding a new payment of $4.99
INSERT INTO payment(customer_id, staff_id, rental_id, amount, payment_date)
VALUES(554, 1, 1, 4.99, '2023-01-05 14:14:25');

SELECT *
FROM customer
WHERE customer_id = 554;

-- Call PROCEDURE 
CALL update_loyalty_status(); 

SELECT *
FROM customer
WHERE customer_id = 554;


-- Create a procedure to add new rows to a table
SELECT *
FROM actor;
-- To add a new actor to the table 
INSERT INTO actor(first_name, last_name, last_update)
VALUES ('Brian', 'Stanton', NOW());


SELECT SPLIT_PART('Brian Stanton', ' ', 2);

-- Put that into a procedure that takes in a full name and adds to the actor table 
CREATE OR REPLACE PROCEDURE add_actor(full_name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO actor(first_name, last_name, last_update)
	VALUES (SPLIT_PART(full_name, ' ', 1), SPLIT_PART(full_name, ' ', 2), NOW());
END;
$$;


-- Add a new actor via the procedure
CALL add_actor('Jeremy Renner');

SELECT *
FROM actor a 
WHERE last_name = 'Renner';

CALL add_actor('Burt Reynolds');

SELECT * FROM actor;

SELECT SPLIT_PART('Olivia Newton John',' ', -1);

-- To delete a procedure, we use DROP
DROP PROCEDURE IF EXISTS add_actor;



