# Spotify Analysis - Shuffle Audio Features

# define work directory
setwd(choose.dir())
getwd()

# import data
tracks_df <- read.csv("../../data/csv/tracks/tracks_features.csv", stringsAsFactors = TRUE)
View(tracks_df)
str(tracks_df)
summary(tracks_df)

# shuffle tracks
shuffled_tracks <- tracks_df[sample(1:nrow(tracks_df)), ]

# reset index
row.names(shuffled_tracks) <- NULL
View(shuffled_tracks)

head(shuffled_tracks)
tail(shuffled_tracks)

# export data frame
write.csv(shuffled_tracks,"../../data/csv/tracks/tracks_features.csv", row.names = FALSE)
