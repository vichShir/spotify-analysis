# Spotify Analysis - Demo

# define work directory
setwd(choose.dir())
getwd()

# import necessary libraries
install.packages("rjson")
install.packages("pracma")
install.packages("comprehenr")
library(rjson)
library(pracma)
library(comprehenr)

# import data
library_file <- "../../data/raw/YourLibrary.json"
library_data <- fromJSON(file = library_file)

#################################
# Data Wrangling - Library Data #
#################################
# explore json structure
length(library_data)
names(library_data)

library_names <- names(library_data)
library_isempty <- to_vec(for(name in library_names) isempty(library_data[[name]]))
library_isempty

lib_names <- library_names[!library_isempty]
lib_names

names(library_data$tracks[[1]])
names(library_data$albums[[1]])
names(library_data$artists[[1]])

# structuring streaming data
artists <- sapply(library_data$tracks, function(x) x[1])
albums <- sapply(library_data$tracks, function(x) x[2])
tracks <- sapply(library_data$tracks, function(x) x[3])

# convert to vector
artists <- unlist(artists)
albums <- unlist(albums)
tracks <- unlist(tracks)

# create library data frame
library_hist <- data.frame("artist" = artists, "album" = albums,
                           "track" = tracks, stringsAsFactors = TRUE)
View(library_hist)
str(library_hist)
summary(library_hist)

# export data frame
write.csv(library_hist,"../../data/csv/your_library.csv", row.names = FALSE)
