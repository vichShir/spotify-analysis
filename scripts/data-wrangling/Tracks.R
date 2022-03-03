# Spotify Analysis - All Unique Tracks

# define work directory
setwd(choose.dir())
getwd()

# import necessary libraries
library(plyr)
library(dplyr)
library(readr)

# import data
streaming_df <- read.csv("../../data/csv/streaming/streaming_unique.csv")
library_df <- read.csv("../../data/csv/library/library_tracks.csv")
playlist_df <- list.files(path = "../../data/csv/playlists/", 
                       pattern = "*.csv", full.names = TRUE) %>%
  lapply(read_csv) %>%                                          
  bind_rows

View(streaming_df)
View(library_df)
View(playlist_df)

####################################
# Remove unecessary columns
####################################
streaming_df$isPodcast <- NULL
library_df$albumName <- NULL
playlist_df$albumName <- NULL

# rename column
streaming_df <- rename(streaming_df, trackID = id)
# change column position
streaming_df <- streaming_df %>% select(trackID, artistName, trackName)

####################################
# Bind rows - dataframes
####################################
tracks_df <- bind_rows(streaming_df, library_df, playlist_df)
View(tracks_df)
str(tracks_df)

# change attributes to factor
tracks_df$trackID <- as.factor(tracks_df$trackID)
tracks_df$artistName <- as.factor(tracks_df$artistName)
tracks_df$trackName <- as.factor(tracks_df$trackName)
View(tracks_df)
str(tracks_df)
summary(tracks_df)

####################################
# Remove duplicated IDs
####################################
tracks_df <- tracks_df[!duplicated(tracks_df$trackID),]
head(tracks_df)
str(tracks_df)
summary(tracks_df)

# export tracks data frame
write.csv(tracks_df,"../../data/csv/tracks/tracks.csv", row.names = FALSE)










