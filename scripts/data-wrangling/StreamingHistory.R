# Spotify Analysis - Streaming History

# define work directory
setwd(choose.dir())
getwd()

# import necessary libraries
install.packages("rjson")
library(rjson)
library(dplyr)

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

# export data frame
write.csv(streaming_hist,"../../data/csv/streaming_history.csv", row.names = FALSE)
