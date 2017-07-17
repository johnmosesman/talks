You interact with your database all the time, but have you ever wondered how it actually works? What does it mean when you request "a user and their posts?" Or, how do you speed up a slow query that is killing your page load time and causing timeouts?In this talk, we'll peek under the hood to learn what happens when your framework of choice interacts with your database. We'll start with SELECT * and work our way through to data integrity, blazing-fast performance, and more. If the thought of learning how to write pure SQL thrills/terrifies you, this might be the talk for you.

---

# Who am I?

# Why this talk?

## Apps are only as good as their data
### The app is the data (Facebook, your email inbox, Github)
### To make great apps, we need to understand how to store and retrieve data
### Even for frontend developers, understanding the backend will make you better

## Databases are one of the first services external to our webservers we interact with
### Databases are usually the first and universally required dependency 

## Databases can be one of the first performance bottlenecks
### Databases are very powerful, used poorly they can be very slow, used well they can be fast

## Data storage and querying is not very intuitive
### SQL doesn't read like most newer programming languagues do (English), nor do we usually think about data as its individual parts, but as a system that is connected

# What are we covering?

## Structuring data for a relational database
## Querying (SQL)
## Associations
## Ensuring data integrity
## Measuring and improving performance
## Advanced topics

# Structuring data for a relational database

## How do we represent data?
### <Pic various ways to describe a person: bubbles, list, json, drawing>
### The database way: tables and rows (and schemas)
### How we represent tables graphically

## What is "good" structure in a relational database? (*not doc dbs)
### Pet store example
#### People

```
+-------------+------------+
| person_name | person_age |
+-------------+------------+
| John        |         26 |
| Susan       |         22 |
| Jim         |         30 |
+-------------+------------+
```

#### Add in their pets?

Add to person's table?

```
+-------------+------------+----------+----------+----------+
| person_name | person_age | pet_name | pet_type | pet_legs |
+-------------+------------+----------+----------+----------+
| John        |         26 | Ruby     | Dog      |        4 |
| Susan       |         22 | Pete     | Bird     |        2 |
| Jim         |         30 | Fluffy   | Cat      |        4 |
+-------------+------------+----------+----------+----------+
```

#### What happens when John gets another pet?

Add another row? 

```
+-------------+------------+----------+----------+----------+
| person_name | person_age | pet_name | pet_type | pet_legs |
+-------------+------------+----------+----------+----------+
| John        |         26 | Ruby     | Dog      |        4 |
| Susan       |         22 | Pete     | Bird     |        2 |
| Jim         |         30 | Fluffy   | Cat      |        4 |
| John        |         26 | Buddy    | Dog      |        4 |
+-------------+------------+----------+----------+----------+

Problems? Duplicated data (when John gets older we update multiple places)
```

Add another pet column?

```
+-------------+------------+-----------+-----------+-----------+-----------+-----------+-----------+
| person_name | person_age | pet1_name | pet1_type | pet1_legs | pet2_name | pet2_type | pet2_legs |
+-------------+------------+-----------+-----------+-----------+-----------+-----------+-----------+
| John        |         26 | Ruby      | Dog       |         4 | Buddy     | Dog       |         4 |
| Susan       |         22 | Pete      | Bird      |         2 |           |           |           |
| Jim         |         30 | Fluffy    | Cat       |         4 |           |           |           |
+-------------+------------+-----------+-----------+-----------+-----------+-----------+-----------+

Problems?
    * No more duplicated data, but the number of pets we can have is limited to the number of columns we have.
    * Inefficient for those with less than max pets
    * Have to check which fields are available to use 
```

#### A pet sadly dies:

```
+-------------+------------+-----------+-----------+-----------+-----------+-----------+-----------+
| person_name | person_age | pet1_name | pet1_type | pet1_legs | pet2_name | pet2_type | pet2_legs |
+-------------+------------+-----------+-----------+-----------+-----------+-----------+-----------+
| John        |         26 | Ruby      | Dog       | 4         | Buddy     | Dog       |         4 |
| Susan       |         22 | ???       | ???       | ???       | Paco      | Bird      |         2 |
| Jim         |         30 | Fluffy    | Cat       | 4         |           |           |           |
+-------------+------------+-----------+-----------+-----------+-----------+-----------+-----------+

Problems:
    * Do we move pet_2 fields down into pet_1?
    * Have to check which pet fields are free to add/remove pets
```

#### Someone abandons their pet:

```
+-------------+------------+----------+----------+----------+
| person_name | person_age | pet_name | pet_type | pet_legs |
+-------------+------------+----------+----------+----------+
| John        | 26         | Ruby     | Dog      |        4 |
| ???         | ???        | Pete     | Bird     |        2 |
| Jim         | 30         | Fluffy   | Cat      |        4 |
+-------------+------------+----------+----------+----------+

Problems:
    * If we delete the row with Susan we lose all of the pet data
```

These problems are solved by creating a "normalized" structure.

## The 3 "Normal forms" 

#### Introduced by Dr. Edgar F. Codd
#### Goal: "reduce data redundancy and improve data integrity"

* 1st Normal Form – The information is stored in a relational table and each column contains atomic values, and there are not repeating groups of columns.

```
+-------------+------------+-----------+-----------+-----------+-----------+-----------+-----------+
| person_name | person_age | pet1_name | pet1_type | pet1_legs | pet2_name | pet2_type | pet2_legs |
+-------------+------------+-----------+-----------+-----------+-----------+-----------+-----------+
| John        |         26 | Ruby      | Dog       |         4 | Buddy     | Dog       |         4 |
| Susan       |         22 | Pete      | Bird      |         2 |           |           |           |
| Jim         |         30 | Fluffy    | Cat       |         4 |           |           |           |
+-------------+------------+-----------+-----------+-----------+-----------+-----------+-----------+
```

=>

```
+-------------+------------+
| person_name | person_age |
+-------------+------------+
| John        |         26 |
| Susan       |         22 |
| Jim         |         30 |
+-------------+------------+

+-------------+----------+----------+----------+
| person_name | pet_name | pet_type | pet_legs |
+-------------+----------+----------+----------+
| John        | Ruby     | Dog      |        4 |
| Susan       | Pete     | Bird     |        2 |
| Jim         | Fluffy   | Cat      |        4 |
+-------------+----------+----------+----------+

John gets another pet =>

+-------------+----------+----------+----------+
| person_name | pet_name | pet_type | pet_legs |
+-------------+----------+----------+----------+
| John        | Ruby     | Dog      |        4 |
| Susan       | Pete     | Bird     |        2 |
| Jim         | Fluffy   | Cat      |        4 |
| John        | Buddy    | Dog      |        4 |
+-------------+----------+----------+----------+
```

* 2nd Normal Form – The table is in first normal form and all the columns depend on the table’s primary key.

"Everyone has one and only one pet"

```
+-------------+------------+----------+----------+----------+
| person_name | person_age | pet_name | pet_type | pet_legs |
+-------------+------------+----------+----------+----------+
| John        | 26         | Ruby     | Dog      |        4 |
| ???         | ???        | Pete     | Bird     |        2 |
| Jim         | 30         | Fluffy   | Cat      |        4 |
+-------------+------------+----------+----------+----------+

Type of pet is not related to the person =>

+-------------+------------+
| person_name | person_age |
+-------------+------------+
| John        |         26 |
| Susan       |         22 |
| Jim         |         30 |
+-------------+------------+

+-------------+----------+----------+----------+
| person_name | pet_name | pet_type | pet_legs |
+-------------+----------+----------+----------+
| John        | Ruby     | Dog      |        4 |
| Susan       | Pete     | Bird     |        2 |
| Jim         | Fluffy   | Cat      |        4 |
| John        | Buddy    | Dog      |        4 |
+-------------+----------+----------+----------+
```

* 3rd Normal Form – the table is in second normal form and all of its columns are not transitively dependent on the primary key

> "Every non-key attribute must provide a fact about the key, the whole key, and nothing but the key, so help me Codd."
> 
> -- Credited to Bill Kent on Wikipedia

```
+-------------+----------+----------+----------+
| person_name | pet_name | pet_type | pet_legs |
+-------------+----------+----------+----------+
| John        | Ruby     | Dog      |        4 |
| Susan       | Pete     | Bird     |        2 |
| Jim         | Fluffy   | Cat      |        4 |
| John        | Buddy    | Dog      |        4 |
+-------------+----------+----------+----------+

Number of legs depends on the pet type =>

+-------------+----------+----------+
| person_name | pet_name | pet_type |
+-------------+----------+----------+
| John        | Ruby     | Dog      |
| Susan       | Pete     | Bird     |
| Jim         | Fluffy   | Cat      |
| John        | Buddy    | Dog      |
+-------------+----------+----------+

+----------+----------+
| pet_type | pet_legs |
+----------+----------+
| Dog      |        4 |
| Bird     |        2 |
| Cat      |        4 |
+----------+----------+
```

## ID keys

### Using person's name as identifier, but names can change, and they are duplicated across the tables

### "Primary keys" - One or more columns on a table that uniquely identify each row in atable

```
+-------------+------------+
| person_name | person_age |
+-------------+------------+
| John        |         26 |
| Susan       |         22 |
| Jim         |         30 |
+-------------+------------+

+-------------+----------+----------+
| person_name | pet_name | pet_type |
+-------------+----------+----------+
| John        | Ruby     | Dog      |
| Susan       | Pete     | Bird     |
| Jim         | Fluffy   | Cat      |
+-------------+----------+----------+

Using IDs =>

+----+-------------+------------+
| id | person_name | person_age |
+----+-------------+------------+
|  1 | John        |         26 |
|  2 | Susan       |         22 |
|  3 | Jim         |         30 |
+----+-------------+------------+

+----+-----------+----------+----------+
| id | person_id | pet_name | pet_type |
+----+-----------+----------+----------+
| 20 |         1 | Ruby     | Dog      |
| 21 |         2 | Pete     | Bird     |
| 22 |         3 | Fluffy   | Cat      |
| 23 |         1 | Buddy    | Dog      |
+----+-----------+----------+----------+

=> If a person updates their name it doesn't affect the pets table anymore
```

### Foreign key - a reference to a primary key in another table

```
+------------------+-------------+------------+
| id (primary key) | person_name | person_age |
+------------------+-------------+------------+
|                1 | John        |         26 |
|                2 | Susan       |         22 |
|                3 | Jim         |         30 |
+------------------+-------------+------------+

+------------------+-------------------------+----------+----------+
| id (primary key) | person_id (foreign key) | pet_name | pet_type |
+------------------+-------------------------+----------+----------+
|               20 |                       1 | Ruby     | Dog      |
|               21 |                       2 | Pete     | Bird     |
|               22 |                       3 | Fluffy   | Cat      |
|               23 |                       1 | Buddy    | Dog      |
+------------------+-------------------------+----------+----------+
```

# Querying (SQL)

## Most modern DBMS's adhere to SQL Standard
## "Structured Query Language"

### An empty table

```
CREATE TABLE people (
  first_name varchar,
  last_name  varchar,
  age        integer
)
```

### Data types

* VARCHAR / TEXT
* INTEGER
* BOOLEAN

### SELECT

```
SELECT * FROM people
SELECT first_name, last_name FROM people
```

### INSERT and DELETE

```
INSERT INTO people (first_name, last_name, age) VALUES
  ('John', 'Mosesman', 26),
  ('Bob', 'Smith', 40),
  ('Jane', 'Doe', 32)
  
DELETE FROM people
```

### WHERE

```
SELECT *
FROM people
WHERE first_name = 'John'

INSERT INTO persons 
SELECT 'John', 'Smith', 100

=> 2 results
```

#### AND and OR

```
SELECT *
FROM people
WHERE first_name = 'John'
  AND last_name = 'Mosesman'
  
=> 1 result
  
SELECT *
FROM people
WHERE age > 50
  OR age < 20
  
=> multiple results
```

### ALTER / PRIMARY KEY

```
ALTER TABLE people ADD COLUMN id SERIAL PRIMARY KEY;

SELECT *
FROM people
WHERE id = 1
```

### UPDATE

```
UPDATE persons
SET first_name = 'Jack'
WHERE id = 4
```

### Simple aggregations

#### AVG, SUM, COUNT()

```
SELECT AVG(age) FROM people
SELECT SUM(age) FROM people
SELECT COUNT(*) FROM people
```

## Associations

```
+----+-------------+------------+
| id | name        | age        |
+----+-------------+------------+
|  1 | John        |         26 |
|  2 | Susan       |         22 |
|  3 | Jim         |         30 |
+----+-------------+------------+

// TODO: add extra pet data in here?

+----+-----------+--------+-----+
| id | person_id |  name  | age |
+----+-----------+--------+-----+
| 20 |         1 | Ruby   |   3 |
| 21 |         2 | Pete   |   5 |
| 22 |         3 | Fluffy |  12 |
| 23 |         1 | Buddy  |   1 |
+----+-----------+--------+-----+

CREATE TABLE people (
  id SERIAL PRIMARY KEY,
  name VARCHAR,
  age INTEGER
)

CREATE TABLE pets (
  id SERIAL PRIMARY KEY,
  person_id INTEGER REFERENCES people,
  name VARCHAR,
  age INTEGER
)
```

### How would we get all of a person's pets?

``` 
SELECT *
FROM pets
WHERE person_id = 1

=> 2 results
```

### How would we get everyone and their pets?

## JOINs

### "Take two tables, match the related rows, and put the result together"

```
+------------+--------------+-------------+---------+----------------+-----------+----------+
| persons.id | persons.name | persons.age | pets.id | pets.person_id | pets.name | pets.age |
+------------+--------------+-------------+---------+----------------+-----------+----------+
|          1 | John         |          26 |      20 |              1 | Ruby      |        3 |
|        ... |              |             |         |                |           |          |
+------------+--------------+-------------+---------+----------------+-----------+----------+
```

### Naive implementation => "Compare every row with every row, then filter out ones that don't make sense"

#### "Cartesian product" or "Cross join"

```
A
B

and

1
2

The cross join of those two tables would be:

A, 1
A, 2
B, 1
B, 2
```

`CROSS JOIN` of people and pets

```
SELECT *
FROM people
  CROSS JOIN pets
  
=> Show results (12 rows?)
```

But some of these don't make sense:

```
~~EXAMPLE OF ROWS NOT MATCHING UP
```

So we filter those out:

```
SELECT *
FROM people
  CROSS JOIN pets
WHERE people.id = pets.person_id

=> Show result of people JOIN pets
```

### "What are you joining, and how are you filtering it?"

=> Using JOIN syntax

```
SELECT *
FROM people
  JOIN pets ON pets.person_id = people.id
  
=> Show result set again

(Note there are multiple results for some people)
```

### Can be filtered like any WHERE clause

Say we were storing pets age =>

```
SELECT *
FROM people
  JOIN pets ON pets.person_id = people.id
    AND pets.age > 2
```

### Execution order

```
SELECT *
FROM people
  JOIN pets ON pets.person_id = people.id
    AND pets.age > 2
WHERE people.age < 30
```

### "Up to this point, we've been reading top-down"

1. FROM
2. JOIN
3. WHERE
4. SELECT

Difference between => 

```
SELECT *
FROM people
  JOIN pets ON pets.person_id = people.id
WHERE people.age < 30
  AND pets.age > 2
  
VS

SELECT *
FROM people
  JOIN pets ON pets.person_id = people.id
    AND pets.age > 2
WHERE people.age < 30
```

In the first example, we join X_ROWS from the pets table, and then filter.

In the second example, we join Y_ROWS (X_ROWS - Z), so when we do the where clause, there are less rows to filter out.

=> Remember the cross join result? 

50_000 * 100_000 = 5 million rows

=> 50_000 * 80_000 = 4 million

### Bringing in pet_types

```
SELECT *
FROM people
  JOIN pets ON people.id = pets.person_id
  JOIN pet_types pt ON pt.pet_id = pets.id
  
(Note alias on pet_types)
```

### Early filtering can really pay off*

#### *But also it doesn't—to be continued

## Types of JOINs

### Seen CROSS JOIN

[IMAGE OF CROSS JOIN]

### Seen "INNER JOIN"

Long-hand version of "JOIN"

[IMAGE OF INNER JOIN]

### OUTER JOIN

### Real quick: NULL

```
irb(main):001:0> nil == nil
=> true
irb(main):002:0> nil == 1
=> false
```

#### "An unknown value"

* = is equality (==) not assignment

```
SELECT 1 = 1                -- TRUE
SELECT 1 <> 1               -- FALSE
SELECT 1 = NULL             -- NULL
SELECT 0 = NULL             -- NULL
SELECT '' = NULL            -- NULL
SELECT NULL = NULL          -- NULL ?

---

IS NULL / IS NOT NULL

SELECT 1 IS NULL            -- FALSE
SELECT 'pizza' IS NOT NULL  -- TRUE
SELECT NULL IS NULL         -- TRUE
SELECT NULL IS NOT NULL     -- FALSE
```

### Back to JOINs

### CROSS JOIN - UNION
### INNER JOIN - INTERSECTION

### OUTER JOIN

### All of Table A, and any that match from Table B

#### "All people in our database, and their pet data—if they have any"

### LEFT OR RIGHT?

`people LEFT JOIN pets` => All people data, and pets if they have them
`people RIGHT JOIN pets` => All pets data, and people data if they have an owner

```
SELECT *
FROM people
  LEFT JOIN pets ON pets.person_id = people.id
  
=> Show result, notice NULL columns
=> We couldn't match any pet data
=> ~~These are the people without pets~~

SELECT *
FROM people
  LEFT JOIN pets ON pets.person_id = people.id
WHERE pets.id IS NULL
```

### Find pets who don't have their shots

```
CREATE TABLE shot_records (
  id SERIAL PRIMARY KEY,
  pet_id INTEGER REFERENCES pets,
  shot_name VARCHAR,
  date DATE 
)

INSERT INTO shot_records (pet_id, shot_name, date) VALUES
(1, 'Rabies', CURRENT_DATE),
(1, 'Bordetella', CURRENT_DATE)

=>

SELECT *
FROM people
  JOIN pets ON pets.person_id = people.id
  LEFT JOIN shot_records sr ON sr.pet_id = pets.id
WHERE sr.id IS NULL

=> Show results of pets without shots
```

### One last example => Find each person and how many pets they have

```
SELECT AVG(age) FROM people
SELECT SUM(age) FROM people
SELECT COUNT(*) FROM people
```

=> Get our people and pet data

```
SELECT *
FROM people
  JOIN pets ON pets.person_id = people.id
```

"GROUP BY"

```
SELECT *
FROM people
  JOIN pets ON pets.person_id = people.id
GROUP BY people.id

---

ERROR:  column "pets.id" must appear in the GROUP BY clause or be used in an aggregate function
LINE 1: SELECT *
               ^

=>

SELECT people.id, COUNT(pets.id)
FROM people
  JOIN pets ON pets.person_id = people.id
GROUP BY people.id

=> Show results, not very useful without name

SELECT people.id, people.name, COUNT(pets.id)
FROM people
  JOIN pets ON pets.person_id = people.id
GROUP BY people.id, people.name

=> More useful results

* Interesting side note—because we're grouping by the primary key, we can use other columns since they're guarenteed unique?
```

#### "People with more pets are more likely to get more"

```
SELECT people.id, people.name, COUNT(pets.id)
FROM people
  JOIN pets ON pets.person_id = people.id
GROUP BY people.id, people.name
ORDER BY COUNT(pets.id) DESC
```

#### Alias the COUNT value

```
SELECT people.id, people.name, COUNT(pets.id) AS num_pets
FROM people
  JOIN pets ON pets.person_id = people.id
GROUP BY people.id, people.name
ORDER BY num_pets DESC
```

#### "People with 2 or more pets are more likely to adopt more"

```
SELECT people.id, people.name, COUNT(pets.id) AS num_pets
FROM people
  JOIN pets ON pets.person_id = people.id
GROUP BY people.id, people.name
HAVING num_pets >= 2
ORDER BY num_pets DESC

=> Error, why?
```

### Order of Operations, cont'd:

1. FROM
2. ON (JOIN)
3. WHERE
4. GROUP BY
5. HAVING
6. SELECT
7. ORDER BY

```
SELECT people.id, people.name, COUNT(pets.id) AS num_pets
FROM people
  JOIN pets ON pets.person_id = people.id
GROUP BY people.id, people.name
HAVING COUNT(pets.id) >= 2
ORDER BY num_pets DESC

=> Results, shows one person (?)
```

### Difference between WHERE and HAVING

> "HAVING eliminates group rows that do not satisfy the condition. HAVING is different from WHERE: WHERE filters individual rows before the application of GROUP BY, while HAVING filters group rows created by GROUP BY. "
> -- Postgres docs

### LIMIT the results

```
SELECT people.id, people.name, COUNT(pets.id) AS num_pets
FROM people
  JOIN pets ON pets.person_id = people.id
GROUP BY people.id, people.name
HAVING COUNT(pets.id) >= 2
ORDER BY num_pets DESC
LIMIT 5
```

## Data Integrity

### "When data goes bad"