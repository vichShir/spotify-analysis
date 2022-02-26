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

get_id_from_uri <- function(uri)
{
  # split
  splitted <- strsplit(uri, split = ":")
  
  # get id from split
  id <- sapply(splitted, function(x) x[3])
  
  return(unlist(id))
}

### Library Tracks ###
# structuring tracks data
artists <- sapply(library_data$tracks, function(x) x[1])
albums <- sapply(library_data$tracks, function(x) x[2])
tracks <- sapply(library_data$tracks, function(x) x[3])
uris <- sapply(library_data$tracks, function(x) x[4])

# convert to vector
artists <- unlist(artists)
albums <- unlist(albums)
tracks <- unlist(tracks)
uris <- unlist(uris)

# split track uri
uris <- get_id_from_uri(uris)

# create library data frame
library_tracks <- data.frame("artist" = artists, "album" = albums,
                             "track" = tracks, "uri" = uris,
                             stringsAsFactors = TRUE)
View(library_tracks)
str(library_tracks)
summary(library_tracks)

# export data frame
write.csv(library_tracks,"../../data/csv/library/library_tracks.csv", row.names = FALSE)

### Library Albums ###
# structuring tracks data
artists <- sapply(library_data$albums, function(x) x[1])
albums <- sapply(library_data$albums, function(x) x[2])
uris <- sapply(library_data$albums, function(x) x[3])

# convert to vector
artists <- unlist(artists)
albums <- unlist(albums)
uris <- unlist(uris)

# split track uri
uris <- get_id_from_uri(uris)

# create library data frame
library_albums <- data.frame("artist" = artists, "album" = albums,
                            "uri" = uris, stringsAsFactors = TRUE)
View(library_albums)
str(library_albums)
summary(library_albums)

# export data frame
write.csv(library_albums,"../../data/csv/library/library_albums.csv", row.names = FALSE)

### Library Artists ###
# structuring tracks data
names <- sapply(library_data$artists, function(x) x[1])
uris <- sapply(library_data$artists, function(x) x[2])

# convert to vector
names <- unlist(names)
uris <- unlist(uris)

# split track uri
uris <- get_id_from_uri(uris)

# create library data frame
library_artists <- data.frame("name" = names, "uri" = uris, stringsAsFactors = TRUE)
View(library_artists)
str(library_artists)
summary(library_artists)

# export data frame
write.csv(library_artists,"../../data/csv/library/library_artists.csv", row.names = FALSE)
