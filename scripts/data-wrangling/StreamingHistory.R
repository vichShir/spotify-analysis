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

get_uri_from_search <- function(result_spotify, trackName)
{
  album_names <- result_spotify$album.name
  track_names <- result_spotify$name
  album_size <- length(album_names)
  
  cat("\014")
  print(trackName)
  
  # search is empty
  if(is.null(album_names))
  {
    return("null")
  }
  
  # matchs first album track
  if(trackName == track_names[1] || length(album_names) == 1)
  {
    album_index <- 1
  }
  else
  {
    cat("Albuns:\n")
    for(i in 1:album_size)
    {
      print(paste("(", i, ")", album_names[i], "(", track_names[i], ")"))
    }
    
    cat("\nDigite um numero entre 1 e", album_size, "para selecionar o album da musica\n")
    album_index <- as.numeric(readline(">> ")) 
  }
  
  return(result_spotify$id[album_index])
}

# unique streaming tracks
all_tracks <- streaming_hist[!duplicated(streaming_hist$trackName),]
nrow(all_tracks)
View(all_tracks)

# get ids
ids <- c()
for (row in 1:nrow(all_tracks))
{
  isPodcast <- all_tracks[row, "isPodcast"]
  artistName <- all_tracks[row, "artistName"]
  trackName <- all_tracks[row, "trackName"]
  
  if(isPodcast == "Yes")
  {
    ids <- c(ids, "null")
    next
  }
  
  cat(row, "de", nrow(all_tracks))
  src <- search_track_id(artistName, trackName)
  trackID <- get_uri_from_search(src, trackName)
  print(trackID)
  ids <- c(ids, trackID)
}
ids
length(ids)

# append to dataframe
all_tracks$id <- ids
View(all_tracks)

# export data frame
write.csv(all_tracks,"../../data/csv/streaming_unique.csv", row.names = FALSE)

# export data frame
write.csv(streaming_hist,"../../data/csv/streaming_history.csv", row.names = FALSE)
