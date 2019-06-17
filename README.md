## Working with Databases Directly from R
by Amy F. Szczepanski

There are several advantages to having your R script connect directly to your database.

* More efficient than exporting CSVs from the database and then reading them into R. Your R script will always have access to fresh data.
* Access multiple databases from one R script, even if the databases are on different servers and use different technologies.
* Avoid running slow queries on a production server by doing simple queries on the server and then processing and combining the data in R.
* Complicated SQL queries can be replaced with a sequence of smaller, easier to understand (and debug!) steps in R.

### Things to Install

For the hands-on part of the session you will need:

* A laptop with R installed.
* The following R packages: `DBI`, `RSQLite`, and `stringr`.
* The [SQLite version of the "Chinook" database](https://github.com/lerocha/chinook-database/blob/master/ChinookDatabase/DataSources/Chinook_Sqlite.sqlite).
* Probably Optional: Install [SQLite](https://www.sqlite.org/index.html) on your laptop.

Your computer might have come with SQLite already installed on it. You can check this by typing `which sqlite` and `which sqlite3` at a command line prompt ("Terminal window" on a Mac). If at least one of those gives you a non-empty response, then you are all set. You'll be able to communicate with the database directly, outside of R. This can help you debug your SQL.

Example (Mac):

```
% sqlite3 ~/Downloads/Chinook_Sqlite.sqlite
SQLite version 3.19.3 2017-06-27 16:48:08
Enter ".help" for usage hints.
sqlite> .tables
Album          Employee       InvoiceLine    PlaylistTrack
Artist         Genre          MediaType      Track        
Customer       Invoice        Playlist     
sqlite> .header on
sqlite> SELECT * FROM Employee LIMIT 1;
EmployeeId|LastName|FirstName|Title|ReportsTo|BirthDate|HireDate|Address|City|State|Country|PostalCode|Phone|Fax|Email
1|Adams|Andrew|General Manager||1962-02-18 00:00:00|2002-08-14 00:00:00|11120 Jasper Ave NW|Edmonton|AB|Canada|T5K 2N1|+1 (780) 428-9482|+1 (780) 428-3457|andrew@chinookcorp.com
sqlite> .separator " "
sqlite> SELECT FirstName, LastName FROM Employee;
FirstName LastName
Andrew Adams
Nancy Edwards
Jane Peacock
Margaret Park
Steve Johnson
Michael Mitchell
Robert King
Laura Callahan
sqlite> .quit
```

If you need (want) to install SQLite, I recommend using a package manager, such as Homebrew. If you don't have Homebrew installed, you can follow the directions at [brew.sh](http://brew.sh), and then type `brew install sqlite`. If that doesn't work, try `brew install sqlite3`. (SQLite and SQLite3 are two different names for the same thing.)

The SQLite web page says that they have a precompiled binary for Windows, so if you use Windows, I guess you should give that a try?

### The Main Idea

R needs to know how to talk to the database, and the database needs to allow R to connect to it on your behalf.

You'll need the `DBI` package installed to connect to any of the supported database types. You'll also need a package that can communicate with your specific type of database. We're using `RSQLite` to talk to a SQLite database, but you can use `RMySQL` with MySQL databases, `RPostgres` for PostgreSQL databases, etc.

For MySQL and PostgreSQL databases, you'll need a username and password (set up by a database admin), and you'll also need to know the hostname and the name of the database. The database admin will probably also have to whitelist the IP address that you are connecting from.

Once all of this is setup, from within R you open a connection to the database, you query the database with SQL, and when you're done, you close the connection.

```
library(DBI)
library(RMySQL)

conMySQL <- dbConnect(RMySQL::MySQL(), user="jane_doe", password="CorrectHorseBatteryStaple", dbname="killerapp", host="example.com")
on.exit(dbDisconnect(con))

sql <- "SELECT * FROM customers WHERE transaction_date > '2019-06-27'"

recent_customers <- dbGetQuery(conMySQL, sql)
```

### Exercises

Use the Chinook database and the tools of your choice to answer at least one of the following questions. The [Chinook Schema](https://github.com/lerocha/chinook-database/wiki/Chinook-Schema) shows the names of all the tables and all their columns. If you are at the Meetup session, I strongly recommend working with one or more other people. As I told my students when I was teaching, try to have your group include at least one person who hasn't been in a group with you before.

1. Which country has the most customers?
2. What is the name of the customer whose invoice has the highest total?
3. Among the purchases recorded in the Chinook database, compare the popularity of the genres of music among customers from North America vs. customers from Europe.
4. For each support rep, what is the total value of their customers' invoices? The average value of their customers' invoices?
5. Break down this data by year: What were the total and average values of each rep's customers' invoices in each year from 2009 - 2013?
6. Write your own question and challenge the members of your group to solve it.

Once your group agrees on the answer to a question, check your answer with a nearby group.

### The price you pay for free training

If you know anyone in the San Diego area who wants to teach math (once a week, after school or on weekends) to enthusiastic and talented K-12 students, point them towards [AoPS Academy Carmel Valley](https://sandiego-cv.aopsacademy.org/school/jobs). Teachers are paid a flat rate for class time and prep time; grading time and training are compensated on an hourly basis.