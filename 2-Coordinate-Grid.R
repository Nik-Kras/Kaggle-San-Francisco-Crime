# 
# Copyright 2022 Nikita Krasnytskyi
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


# Installing Packages
# install.packages("ClusterR")
install.packages("cluster")
# install.packages("imager")

# Loading package
# library(ClusterR)
library(cluster)
# library(imager)

set.seed(1203)

# 
# rm(list=ls())
# 
# train <- data.table(read.csv("./data/output/TrainExtracted1.csv"))
# test  <- data.table(read.csv("./data/output/TestExtracted1.csv"))

# Search for the K --------------------------------------------

# Check wss for different K
#  fviz_nbclust() - makes estimation of optimal K
# By checking kmeans.re$size -- can build HeatMap

# cat(sprintf("Time: %s\n", Sys.time()))
# # step <- 20
# # train_step  <- train[seq(1, nrow(train), step),]
# 
# coordinates <- cbind(train$X, train$Y)
# 
# wss <- rep(0, 100)
# between <- rep(0, 100)
# size <- matrix(rep(rep(0, 100), 100), nrow=100)
# for (i in 1:100)
# {
#   kmeans.re <- kmeans(coordinates, 
#                       centers = i,
#                       iter.max = 20,
#                       nstart = 25)
#   wss[i] <- kmeans.re$tot.withinss
#   between[i] <- kmeans.re$betweenss
#   size[1:i,i] <- kmeans.re$size
#   
#   cat(sprintf("Time: %s\n", Sys.time()))
#   cat(sprintf("The number of K: %d\n", i))
#   print("********************************")
# }
# 
# plot(wss)
# plot(wss[1:20])
# 
# # Best K lays in range(5-10) according to elbow rule
# k_clusters <- 6
# 
# write.csv(wss, file="data/output/Clustering/Models_wss.csv", 
#           row.names=FALSE)
# write.csv(between, file="data/output/Clustering/Models_between.csv", 
#           row.names=FALSE)
# write.csv(size, file="data/output/Clustering/Models_size_in_clusters.csv", 
#           row.names=FALSE)

# Best K lays in range(5-10) according to elbow rule

# Train clustering --------------------------------------------

k_clusters <- 6
coordinates <- cbind(train$X, train$Y)
kmeans.re <- kmeans(coordinates, 
                    centers = k_clusters,
                    nstart = 25)
print(kmeans.re)

# View Clusters -----------------------------------------------

plot(train$X, train$Y, 
     col = kmeans.re$cluster)

# clusplot(coordinates,
#          kmeans.re$cluster,
#          lines = 0,
#          shade = TRUE,
#          color = TRUE,
#          labels = 9,
#          plotchar = FALSE,
#          span = TRUE,
#          main = paste("Cluster coordinates"),
#          xlab = 'Latitude',
#          ylab = 'Longitude')

# Use clusters to add new feature -----------------------------



### For future improvement
############################################################################
# Add a San Francisco picture on the top -------------------------------
# Notes:

# To make a map image
# https://dev.virtualearth.net/REST/v1/Imagery/Map/imagerySet?mapArea={mapArea}&mapSize={mapSize}&pushpin={pushpin}&mapLayer={mapLayer}&format={format}&mapMetadata=mapMetadata}&key={BingMapsKey} 
# "boundingbox":["37.7075","37.8350","-122.5176","-122.3271"]
# south Latitude, north Latitude, west Longitude, east Longitude

# -122.5176,37.7075,-122.3271,37.8350


# addImg <- function(
#   obj, # an image file imported as an array (e.g. png::readPNG, jpeg::readJPEG)
#   x = NULL, # mid x coordinate for image
#   y = NULL, # mid y coordinate for image
#   width = NULL, # width of image (in x coordinate units)
#   interpolate = TRUE # (passed to graphics::rasterImage) A logical vector (or scalar) indicating whether to apply linear interpolation to the image when drawing. 
# ){
#   if(is.null(x) | is.null(y) | is.null(width)){stop("Must provide args 'x', 'y', and 'width'")}
#   USR <- par()$usr # A vector of the form c(x1, x2, y1, y2) giving the extremes of the user coordinates of the plotting region
#   PIN <- par()$pin # The current plot dimensions, (width, height), in inches
#   DIM <- dim(obj) # number of x-y pixels for the image
#   ARp <- DIM[1]/DIM[2] # pixel aspect ratio (y/x)
#   WIDi <- width/(USR[2]-USR[1])*PIN[1] # convert width units to inches
#   HEIi <- WIDi * ARp # height in inches
#   HEIu <- HEIi/PIN[2]*(USR[4]-USR[3]) # height in units
#   rasterImage(image = obj, 
#               xleft = x-(width/2), xright = x+(width/2),
#               ybottom = y-(HEIu/2), ytop = y+(HEIu/2), 
#               interpolate = interpolate)
# }
# 
# library(png)
# pic <- readPNG("./data/San_Francisco_Map/mapbox1200x800@2x.png")
# dim(pic)
# 
# png("./data/San_Francisco_Map/mapbox1200x800@2x.png", width = 5, 
#     height = 4, units = "in", res = 400)
# par(mar = c(3,3,0.5,0.5))
# image(volcano)
# dev.off()
# 
# 
# dev.print(png, file = "myplot.png", width = 1024, height = 768)
# 
# png(file = "./data/San_Francisco_Map/mapbox1200x800@2x.png", bg = "transparent")
# plot(1:10)
# rect(1, 5, 3, 7, col = "white")
# dev.off()