# Spotify Analysis - Tracks Audio Features

# define work directory
setwd(choose.dir())
getwd()

# import necessary libraries
install.packages("rjson")
install.packages("spotifyr")
library(rjson)
library(spotifyr)
library(tidyverse)

# import data
tracks_df <- read.csv("../../data/csv/tracks/tracks.csv")
View(tracks_df)

####################################
# Spotify authentication
####################################
# import credentials
credentials <- fromJSON(file = "spotify-credentials.json")

# authentication
Sys.setenv(SPOTIFY_CLIENT_ID = credentials$client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = credentials$client_secret)
access_token <- get_spotify_access_token()

####################################
# Audio Features
# 
# Interested features:
# - acousticness
# - danceability
# - duration_ms
# - energy
# - instrumentalness
# - key
# - liveness
# - loudness
# - mode
# - speechiness
# - tempo
# - time_signature
# - valence
#
# reference: (https://developer.spotify.com/documentation/web-api/reference/#/operations/get-several-audio-features)
####################################

get_audio_features <- function(trackID)
{
  # get audio features
  track <- get_track_audio_features(trackID)
  
  # remove unwanted features
  track$id <- NULL
  track$uri <- NULL
  track$track_href <- NULL
  track$type <- NULL
  track$analysis_url <- NULL

  return(unlist(track))
}

# get audio features
tracks_features <- as.data.frame(sapply(tracks_df$trackID, function(id) get_audio_features(id)))
View(tracks_features)

# convert to dataframe
tracks_features <- t(tracks_features)
tracks_features <- as.data.frame(tracks_features)
View(tracks_features)

# move index to a new column "trackID"
tracks_features <- cbind(trackID = rownames(tracks_features), tracks_features)
rownames(tracks_features) <- 1:nrow(tracks_features)
View(tracks_features)
str(tracks_features)

# remove the extra 'X' in the ID's column
tracks_features$trackID <- substring(tracks_features$trackID, 2)
View(tracks_features)

# put all data frames into list
df_list <- list(tracks_df, tracks_features)

# merge all data frames together
tracks <- df_list %>% reduce(full_join, by='trackID')
View(tracks)
summary(tracks)

# NA rows
tracks[rowSums(is.na(tracks)) > 0,]

# remove NA rows
tracks <- na.omit(tracks)
View(tracks)

# export data frame
write.csv(tracks,"../../data/csv/tracks/tracks_features.csv", row.names = FALSE)

