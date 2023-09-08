####make a virtual SQL connection, some basic SQL functionality from R
#install.packages("RSQLite")
#install.packages("DBI")
library("DBI")
library("RSQLite")

# Prep some data
data = iris
colnames(data) = c("SL","SW","PL","PW","Species") # give column names that sql works easily with
speciesID = data.frame(sID = 1:3, Species = unique(data$Species)) # a second table to give an id number to the species

# make a sql server connection
con = dbConnect(RSQLite::SQLite(), dbname = ":memory:")
dbWriteTable(con, "data", data)
dbWriteTable(con, "speciesID", speciesID)
dbListTables(con) # just to check that we have 2 tables
rm(list = c("data", "speciesID")) # clear from memory the table

# Basic selection
dbGetQuery(con, "SELECT * FROM data") # select all columns
dbGetQuery(con, "SELECT SL,SW FROM data WHERE Species = 'virginica' ") # select some columns based on some other column value
dbGetQuery(con, "SELECT SL,SW FROM data WHERE Species != 'virginica' ") # a 'not' case
dbGetQuery(con, "SELECT SL,SW FROM data WHERE Species LIKE 'V%' ") # same as above, but filter based on pattern
dbGetQuery(con, "SELECT SL,SW FROM data WHERE Species IN ('setosa','virginica') ") # note the IN

#AND / OR / XOR / BETWEEN / distinct
dbGetQuery(con, "SELECT * FROM data WHERE PW > 0.5 OR  PL > 5.0")
dbGetQuery(con, "SELECT * FROM data WHERE PW > 0.5 AND  PL > 5.0")
dbGetQuery(con, "SELECT * FROM data WHERE (PW > 0.5 AND PL < 5.0) OR (PW <= 0.5 AND PL >= 5.0) ") #XOR case
dbGetQuery(con, "SELECT * FROM data WHERE PW BETWEEN 0.5 AND 1.0") # inclusive
dbGetQuery(con, "SELECT * FROM data WHERE Species LIKE 's%' OR Species LIKE 'v%' ")
dbGetQuery(con, "SELECT distinct(Species) FROM data WHERE PW > 0.5 OR  PL > 5.0") # get unique values

# SUM / minmax / count / avg
dbGetQuery(con, "SELECT COUNT(SW) FROM data WHERE PW > 0.5 OR  PL > 5.0")
dbGetQuery(con, "SELECT COUNT(SW) FROM data WHERE PW > 0.5 AND  PL > 5.0")
dbGetQuery(con, "SELECT MIN(SW),AVG(SW),MAX(SW) FROM data WHERE PW > 0.5 AND  PL > 5.0")
dbGetQuery(con, "SELECT AVG(SW) FROM data WHERE PW > 0.5 AND  PL > 5.0")
dbGetQuery(con, "SELECT AVG(SW)/AVG(SL) FROM data WHERE PW > 0.5 AND  PL > 5.0") #output a computation
dbGetQuery(con, "SELECT round(AVG(SL),2) FROM data WHERE PW > 0.5 AND  PL > 5.0") # round off to x dp [negative numbers work too, eg -3 to round off to nearest 1000]
dbGetQuery(con, "SELECT length(Species) FROM data WHERE PW > 0.5") #output length of string
dbGetQuery(con, "SELECT Species,PW,PL FROM data WHERE PW < (PL/4)") # selection on compute

# ORDER BY
dbGetQuery(con, "SELECT * FROM data WHERE PW > 0.5 ORDER BY PW")
dbGetQuery(con, "SELECT * FROM data WHERE PW > 0.5 ORDER BY PW desc")
dbGetQuery(con, "SELECT * FROM data WHERE PW > 0.5 ORDER BY species,PW")

# NULL case
dbGetQuery(con, "SELECT * FROM data WHERE PL is NULL")
dbGetQuery(con, "SELECT * FROM data WHERE PL is not NULL")
dbGetQuery(con, "SELECT AVG(PL) FROM data") # avg function ignores nulls
dbGetQuery(con, "SELECT AVG(PL) FROM data WHERE PL is not NULL")
dbGetQuery(con, "SELECT COUNT(PL) FROM data") # count function does not ignore nulls
dbGetQuery(con, "SELECT COUNT(PL) FROM data WHERE PL is not NULL")

# JOIN 2 tables based on some common attribute (e.g. data and speciesID both have a "Species" column)
dbGetQuery(con, "SELECT * FROM data INNER JOIN speciesID ON data.Species=speciesID.Species")
dbGetQuery(con, "SELECT data.SL,speciesID.sID FROM data INNER JOIN speciesID ON data.Species=speciesID.Species")

# End
dbDisconnect(con)
