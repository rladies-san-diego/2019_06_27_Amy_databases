library(stringr)
library(DBI)
library(RSQLite)

# Exercises from the handout:
# 1. Which country has the most customers?
# 2. What is the name of the customer whose invoice has the highest total?
# 3. Among the purchases recorded in the Chinook database, compare the popularity of the genres of music among customers from North America vs. customers from Europe.
# 4. For each support rep, what is the total value of their customers' invoices? The average value of their customers' invoices?
# 5. Break down this data by year: What were the total and average values of each rep's customers' invoices in each year from 2009 - 2013?

# You could write all the solutions as plain SQL queries.
# These sample solutions show how to use R functions with this data.

# The Chinook database:
# https://github.com/lerocha/chinook-database/blob/master/ChinookDatabase/DataSources/Chinook_Sqlite.sqlite

# Open a connection to the database
# For a SQLite database, include the path to the file
con <- dbConnect(RSQLite::SQLite(), "~/Downloads/Chinook_Sqlite.sqlite")
# Closes the connection on exit
on.exit(dbDisconnect(con))

# 1. Which country has the most customers?

sql <- "SELECT * FROM Customer"
customers <- dbGetQuery(con, sql)
countries <- as.data.frame(table(customers$Country))
countries[which.max(countries$Freq), "Var1"]

# Answer: USA

# 2. What is the name of the customer whose invoice has the highest total?
sql <- "SELECT * FROM Invoice"
invoices <- dbGetQuery(con, sql)

# "INNER JOIN" on CustomerID with a merge
customers_invoices <- merge(customers, invoices, by=c("CustomerId"), all=FALSE)
customers_invoices[which.max(customers_invoices$Total), c("FirstName", "LastName")]

# Answer: Helena Holý

# 3. Among the purchases recorded in the Chinook database, compare the popularity of the genres of music among customers from North America vs. customers from Europe.

north_america <- c("USA", "Canada", "Mexico")
# Depending on the status of Brexit, you can take the UK off this list.
europe <- c("Germany", "Norway", "Czech Republic", "Austria", "Belgium", "Denmark", "Portugal", "France", "Finland", "Hungary", "Ireland", "Italy", "Netherlands", "Poland", "Spain", "Sweden", "United Kingdom")

sql <- "SELECT * FROM InvoiceLine"
invoice_lines <- dbGetQuery(con, sql)

sql <- "SELECT * FROM Track"
tracks <- dbGetQuery(con, sql)

sql <- "SELECT * FROM Genre"
genres <- dbGetQuery(con, sql)

customers_invoices_lines <- merge(customers_invoices, invoice_lines, by=c("InvoiceId"), all=FALSE)

customers_invoices_lines_tracks <- merge(customers_invoices_lines, tracks, by=c("TrackId"), all=FALSE)

customers_invoices_lines_tracks_genres <- merge(customers_invoices_lines_tracks, genres, by=c("GenreId"), all=FALSE)

# shorter name
ciltg <- customers_invoices_lines_tracks_genres

na_genres <- ciltg[ciltg$Country %in% north_america, "Name.y"]
eu_genres <- ciltg[ciltg$Country %in% europe, "Name.y"]

# Answer: Analysis will vary
# table(na_genres)
# table(eu_genres)

# 4. For each support rep, what is the total value of their customers' invoices? The average value of their customers' invoices?

# Doesn't ask for the rep's name, so we can do this with customers_invoices

total_per_rep <- aggregate(Total ~ SupportRepId, data=customers_invoices, FUN=sum)
average_per_rep <- aggregate(Total ~ SupportRepId, data=customers_invoices, FUN=mean)

# Answer: 3 833.04, 4 775.40, 5 720.16
# Answer: 3 5.705753, 4 5.538571, 5 5.715556

# 5. Break down this data by year: What were the total and average values of each rep's customers' invoices in each year from 2009 - 2013?

customers_invoices$InvoiceDate <- as.POSIXct(customers_invoices$InvoiceDate)
customers_invoices$InvoiceYear <- strftime(customers_invoices$InvoiceDate, format="%Y")

total_per_rep_per_year <- aggregate(Total ~ SupportRepId + InvoiceYear, data=customers_invoices, FUN=sum)
average_per_rep_per_year <- aggregate(Total ~ SupportRepId + InvoiceYear, data=customers_invoices, FUN=mean)

#Answer
#    SupportRepId InvoiceYear  Total
# 1             3        2009 123.75
# 2             4        2009 161.37
# 3             5        2009 164.34
# 4             3        2010 221.92
# 5             4        2010 122.76
# 6             5        2010 136.77
# 7             3        2011 184.34
# 8             4        2011 125.77
# 9             5        2011 159.47
# 10            3        2012 146.60
# 11            4        2012 197.20
# 12            5        2012 133.73
# 13            3        2013 156.43
# 14            4        2013 168.30
# 15            5        2013 125.85

#    SupportRepId InvoiceYear    Total
# 1             3        2009 4.950000
# 2             4        2009 5.379000
# 3             5        2009 5.869286
# 4             3        2010 6.527059
# 5             4        2010 4.546667
# 6             5        2010 6.216818
# 7             3        2011 6.583571
# 8             4        2011 4.491786
# 9             5        2011 5.906296
# 10            3        2012 5.235714
# 11            4        2012 6.800000
# 12            5        2012 5.143462
# 13            3        2013 5.046129
# 14            4        2013 6.473077
# 15            5        2013 5.471739