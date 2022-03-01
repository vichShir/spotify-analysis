# Spotify Analysis - Streaming History

# define work directory
setwd(choose.dir())
getwd()

# import necessary libraries
install.packages("rjson")
install.packages("spotifyr")
library(rjson)
library(dplyr)
library(spotifyr)

# import data
streaming_file <- "../../data/raw/StreamingHistory0.json"
streaming_data <- fromJSON(file = streaming_file)

###################################
# Data Wrangling - Streaming Data #
###################################
# explore json structure
length(streaming_data)
names(streaming_data)
streaming_data[[1]]
names(streaming_data[[1]])

# structuring streaming data
endTimes <- sapply(streaming_data, function(x) x[[1]])
artistNames <- sapply(streaming_data, function(x) x[[2]])
trackNames <- sapply(streaming_data, function(x) x[[3]])
msPlayed <- sapply(streaming_data, function(x) x[[4]])

# create streaming data frame
streaming_hist <- data.frame("endTime" = endTimes, "artistName" = artistNames,
                             "trackName" = trackNames, "msPlayed" = msPlayed,
                             stringsAsFactors = TRUE)
View(streaming_hist)
str(streaming_hist)
summary(streaming_hist)

#####################
# Duplicated Tracks #
#####################
# see trackName structure
streaming_hist[sample(nrow(streaming_hist), 10),]
typeof(streaming_hist$trackName)

# get only the music title
?strsplit
streaming_hist$trackName <- sapply(streaming_hist$trackName, function(x) trimws(unlist(strsplit(as.character(x), split = "-"))[1]))
streaming_hist$trackName <- sapply(streaming_hist$trackName, function(x) trimws(unlist(strsplit(as.character(x), split = "(", fixed = TRUE))[1]))
streaming_hist$trackName <- sapply(streaming_hist$trackName, function(x) trimws(unlist(strsplit(as.character(x), split = ":", fixed = TRUE))[1]))
streaming_hist$trackName <- sapply(streaming_hist$trackName, function(x) trimws(unlist(strsplit(as.character(x), split = "/", fixed = TRUE))[1]))
streaming_hist$trackName <- sapply(streaming_hist$trackName, function(x) trimws(gsub("\"", "", x)))
streaming_hist$trackName <- as.factor(streaming_hist$trackName)

# remove missing values
# NAs -> (Don't Fear) The Reaper?
streaming_hist <- streaming_hist[complete.cases(streaming_hist), ]

View(streaming_hist)
str(streaming_hist)
summary(streaming_hist)

streaming_hist[sample(nrow(streaming_hist), 100),]

############################
# Create is_podcast column #
############################
# all artists
all_artists <- unique(streaming_hist$artistName)
all_artists

# filter podcast artists
podcast_artists = all_artists[c(1, 21, 22)]
podcast_artists

# create column
streaming_hist <- streaming_hist %>%
  mutate(isPodcast = c("No", "Yes")[(streaming_hist$artistName %in% podcast_artists)+1])

# verify all podcast tracks
filter(streaming_hist, artistName %in% podcast_artists)
View(streaming_hist)

#########################
# Create trackID column #
#########################
# import spotify credentials
credentials <- fromJSON(file = "spotify-credentials.json")

# authentication
Sys.setenv(SPOTIFY_CLIENT_ID = credentials$client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = credentials$client_secret)
access_token <- get_spotify_access_token()

search_track_id <- function(artistName, trackName)
{
  track <- paste(trackName, artistName, sep = " ")
  result <- search_spotify(track, 'track')
  return(result)
}

get_id_from_search <- function(result_spotify, trackName)
{
  # search attributes
  album_names <- result_spotify$album.name
  track_names <- result_spotify$name
  album_size <- length(album_names)
  
  # display
  cat("\014")
  print(trackName)
  
  # track not found
  if(is.null(album_names))
  {
    return("null")
  }
  
  # matchs first album track
  album_index <- 0
  if(track_names[1] == trackName || length(album_names) == 1)
  {
    album_index <- 1
  }
  else
  {
    # verify each album
    for(i in 2:album_size)
    {
      if(track_names[i] == trackName)
      {
        album_index <- i
        break
      }
    }
    
    # manual search
    if(album_index == 0)
    {
      cat("Albuns:\n")
      for(i in 1:album_size)
      {
        print(paste("(", i, ")", album_names[i], "(", track_names[i], ")"))
      }
      
      cat("\nDigite um numero entre 1 e", album_size, "para selecionar o album da musica\n")
      album_index <- as.numeric(readline(">> "))  
    }
  }
  
  return(result_spotify$id[album_index])
}

# unique streaming tracks
all_tracks <- streaming_hist[!duplicated(streaming_hist$trackName),]

# remove unlike columns
all_tracks$endTime <- NULL
all_tracks$msPlayed <- NULL

# sort by artist
all_tracks <- all_tracks[order(all_tracks$artistName, all_tracks$trackName),]
row.names(all_tracks) <- NULL
nrow(all_tracks)
View(all_tracks)
str(all_tracks)

# get ids
ids <- c()
for (row in 1:nrow(all_tracks))
{
  isPodcast <- all_tracks[row, "isPodcast"]
  artistName <- all_tracks[row, "artistName"]
  trackName <- all_tracks[row, "trackName"]
  
  # skip podcasts
  if(isPodcast == "Yes")
  {
    ids <- c(ids, "null")
    next
  }
  
  cat(row, "de", nrow(all_tracks))
  src <- search_track_id(artistName, trackName)
  trackID <- get_id_from_search(src, trackName)
  print(trackID)
  
  # store trackID
  ids <- c(ids, trackID)
}
head(ids)
length(ids)

# append ids to dataframe
all_tracks$id <- ids
all_tracks$id <- as.factor(all_tracks$id)
View(all_tracks)
summary(all_tracks)

#####################
# Merge Data Frames #
#####################
# merge unique tracks ids with streaming history
streaming_hist <- merge(streaming_hist, all_tracks, by = "trackName")
streaming_hist <- streaming_hist %>% select(id, endTime, artistName.x, trackName, msPlayed, isPodcast.x)

# sort by endTime
streaming_hist <- streaming_hist[order(streaming_hist$endTime),]
row.names(streaming_hist) <- NULL

# rename columns
streaming_hist <- rename(streaming_hist, trackID = id, artistName = artistName.x, isPodcast = isPodcast.x)
View(streaming_hist)
str(streaming_hist)
summary(streaming_hist)

# export data frame
write.csv(all_tracks,"../../data/csv/streaming/streaming_unique.csv", row.names = FALSE)

# export data frame
write.csv(streaming_hist,"../../data/csv/streaming/streaming_history.csv", row.names = FALSE)
