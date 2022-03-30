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
install.packages("ClusterR")
install.packages("cluster")

# Loading package
library(ClusterR)
library(cluster)

# set.seed(1203)
# 
# rm(list=ls())
# 
# train <- data.table(read.csv("./data/output/TrainExtracted1.csv"))
# test  <- data.table(read.csv("./data/output/TestExtracted1.csv"))

step <- 1000
train_step  <- train[seq(1, nrow(train), step),]

coordinates <- cbind(train_step$X, train_step$Y)

kmeans.re <- kmeans(coordinates), 
                    centers = 10, 
                    nstart = 20)
kmeans.re

plot(train_step$X, train_step$Y, 
     col = kmeans.re$cluster)