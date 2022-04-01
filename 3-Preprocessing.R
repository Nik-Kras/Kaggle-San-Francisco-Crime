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

# Load data --------------------------------------------------
rm(list=ls())

print("Loading data...")
cat(sprintf("Time: %s\n", Sys.time()))

train <- data.table(read.csv("data/output/Clustering/TrainWithClusters.csv"))
test  <- data.table(read.csv("data/output/Clustering/TestWithClusters.csv" ))

# test[, c("Id"):=NULL]

# Convert strings to numbers ---------------------------------
print("Converting strings to numbers...")
cat(sprintf("Time: %s\n", Sys.time()))

print("Convert Day Of Week...")
cat(sprintf("Time: %s\n", Sys.time()))

# Convert Days of Week to categories
key_names <- unique(train$DayOfWeek)
for (i in 1:length(key_names))
{
  train$DayOfWeek[train$DayOfWeek == key_names[i]]  <- as.numeric(i)
  test$DayOfWeek [test$DayOfWeek  == key_names[i]]  <- as.numeric(i)
}
train$DayOfWeek <- as.numeric(train$DayOfWeek)
test$DayOfWeek  <- as.numeric(test$DayOfWeek)

print("Convert Police District...")
cat(sprintf("Time: %s\n", Sys.time()))

# Convert Police District to categories
key_names <- unique(train$PdDistrict)
for (i in 1:length(key_names))
{
  train$PdDistrict[train$PdDistrict == key_names[i]]  <- as.numeric(i)
  test$PdDistrict [test$PdDistrict  == key_names[i]]  <- as.numeric(i)
}
train$PdDistrict <- as.numeric(train$PdDistrict)
test$PdDistrict  <- as.numeric(test$PdDistrict)

print("Convert Street Numbers...")
cat(sprintf("Time: %s\n", Sys.time()))

# Convert Street Numbers to categories
key_names <- unique(train$StreetNumber)
for (i in 1:length(key_names))
{
  train$StreetNumber[train$StreetNumber == key_names[i]]  <- i
  test$StreetNumber [test$StreetNumber  == key_names[i]]  <- i
}

print("Convert Address...")
cat(sprintf("Time: %s\n", Sys.time()))


### Takes too long time! (30min-1hour)
# Convert updated Address field to categories
# key_names <- unique(train$Address_New_train)
# for (i in 1:length(key_names))
# {
#   train$Address_New_train[train$Address_New_train == key_names[i]]  <- i
#   test$Address_New_test  [test$Address_New_test   == key_names[i]]  <- i
#   
#   cat(sprintf("Number of the street: %d/%d\n", i, length(key_names)))
#   print("*****************************************************")
# }
train[, c("Address_New_train"):=NULL]
test [, c("Address_New_test") :=NULL]


rm(i, key_names)

cat(sprintf("Time: %s\n", Sys.time()))
print("Converting / categorisation has been finished.")
print(head(train))

# setcolorder(test, c("Dates", 
#                     "DayOfWeek", 
#                     "PdDistrict",
#                     "X", "Y"))

# Normalization -----------------------------------------------
print("Data normalization...")
cat(sprintf("Time: %s\n", Sys.time()))

# Instead of LOOP: prc_n <- as.data.frame(lapply(prc[2:9], normalize))
# normalize - is a function that normalizes

# for (i in c(1:8))
# {
#   train[,i] <- rescale(as.numeric(array(unlist(train[,..i]))))
#   test[,i]  <- rescale(as.numeric(array(unlist(test[,..i]))))
# }

normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x))) }

# train$DayOfWeek <- lapply(train$DayOfWeek, 
#                          function(x) as.numeric(as.character(x)))

train <- as.data.frame(apply(train, MARGIN=2, normalize))
test  <- as.data.frame(apply(test,  MARGIN=2, normalize))

cat(sprintf("Time: %s\n", Sys.time()))
print("Saving data") 

write.csv(test, file="data/output/Normalization/TestNormalize.csv", 
          row.names=FALSE)
write.csv(train, file="data/output/Normalization/TrainNormalize.csv", 
          row.names=FALSE)

cat(sprintf("Time: %s\n", Sys.time()))
print("Data normalization has been finished")
print(head(train))
print(summary(train))