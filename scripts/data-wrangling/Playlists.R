# Spotify Analysis - Playlists

# define work directory
setwd(choose.dir())
getwd()

# import necessary libraries
install.packages("rjson")
install.packages("comprehenr")
library(rjson)
library(comprehenr)

# import data
playlist_file <- "../../data/raw/Playlist1.json"
playlist_data <- fromJSON(file = playlist_file)

##################################
# Data Wrangling - Playlist Data #
##################################
# explore json structure
length(playlist_data)
names(playlist_data)

length(playlist_data$playlists)

playlist_names <- to_vec(for(i in 1:10) playlist_data$playlists[[i]]$name)
playlist_names

playlist_data_to_dataframe <- function(playlist_data, index)
{
  # structuring playlist data
  trackNames <- sapply(playlist_data$playlists[[index]][[3]], function(x) x[[1]][1])
  artistNames <- sapply(playlist_data$playlists[[index]][[3]], function(x) x[[1]][2])
  albumNames <- sapply(playlist_data$playlists[[index]][[3]], function(x) x[[1]][3])
  trackUris <- sapply(playlist_data$playlists[[index]][[3]], function(x) x[[1]][4])
  
  # convert to vector
  trackNames <- unlist(trackNames)
  artistNames <- unlist(artistNames)
  albumNames <- unlist(albumNames)
  trackUris <- unlist(trackUris)
  
  # split track uri
  trackUris <- unlist(sapply(strsplit(trackUris, split = ":"), function(x) x[3]))
  
  # create playlist data frame
  playlist_hist <- data.frame("trackID" = trackUris, "artistName" = artistNames,
                              "trackName" = trackNames, "albumName" = albumNames,
                              stringsAsFactors = TRUE)
  return(playlist_hist)
}

# export data frame
export_filenames <- c("minha_playlist_10.csv", "best.csv", "rush_inspiration.csv", "sono.csv", "ita.csv", "inspiracao.csv",
                      "animada_rock.csv", "animada_inspirada.csv", "thewho_playlist.csv", "playlist_1.csv")
for(i in 1:10)
  write.csv(playlist_data_to_dataframe(playlist_data, i), paste("../../data/csv/playlists/", export_filenames[i], sep = ""), row.names = FALSE)
