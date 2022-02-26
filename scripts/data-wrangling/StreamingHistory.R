# Spotify Analysis - Streaming History

# define work directory
setwd(choose.dir())
getwd()

# import necessary libraries
install.packages("rjson")
library(rjson)

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

# export data frame
write.csv(streaming_hist,"../../data/csv/streaming_history.csv", row.names = FALSE)
