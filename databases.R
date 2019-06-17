library(stringr)
library(DBI)
library(RSQLite)

# Get the database here:
# https://github.com/lerocha/chinook-database/blob/master/ChinookDatabase/DataSources/Chinook_Sqlite.sqlite

# Open a connection to the database
# For a SQLite database, include the path to the file
con <- dbConnect(RSQLite::SQLite(), "~/Downloads/Chinook_Sqlite.sqlite")
# Closes the connection on exit
on.exit(dbDisconnect(con))

# Write the query
sql <- "SELECT * FROM Album"

# Get the results; they are stored in a dataframe.
albums <- dbGetQuery(con, sql)

# We can then work with the dataframe using standard methods
albums[albums$ArtistId == 118, ]

# New query
sql <- "SELECT * FROM Artist"

# More results!
artists <- dbGetQuery(con, sql)

# Instead of doing a JOIN in SQL, we can do a merge() in R
albums_with_artists <- merge(albums, artists, by=c("ArtistId"), all.x = TRUE, all.y = TRUE)

# We can write a query to find how many albums are by each artist
# SELECT Name, COUNT(AlbumId) AS Freq
# FROM Album
# INNER JOIN Artist
# USING (ArtistId)
# GROUP BY ArtistID

# Or we could use R functions and the data we've already retrieved.

# When we would use a GROUP BY in SQL, we often use aggregate() in R
album_counts1 <- aggregate(AlbumId ~ Name, data=albums_with_artists, FUN = length)

# When we're counting the number of occurences, we can use table()
album_counts2 <- as.data.frame(table(albums_with_artists$Name))

# I tend to use stringr and str_c() to build queries algorithmically.
# NB: Depending on your situation, be careful to avoid SQL Injection.
# https://xkcd.com/327/

favorite_artist <- sample(1:275, 1)

sql <- str_c("
	SELECT * 
	FROM Album 
	WHERE ArtistId = ", favorite_artist ,"
	AND Title IS NOT NULL
	")
favorite_albums <- dbGetQuery(con, sql)

favorite <- str_c("Your favorite artist released ", favorite_albums[1, "Title"], ".")