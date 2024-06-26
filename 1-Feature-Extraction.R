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

# Delete unnecessary features -------------------------------

train[, c("Descript","Resolution"):=NULL]


# Expand dates features --------------------------------------

# New method 
# test$Dates <- strptime(test$Dates, format="%Y-%m-%d %H:%M:%S")
# test$Hour <- test$Dates$hour

print("Increasing feature count by dates detalisation...")
cat(sprintf("Time: %s\n", Sys.time()))
ExpandDates <- function(Dates){
  
  dates    <- Dates
  date_sep <- matrix(unlist(strsplit(dates, split=' ', fixed=TRUE)),        nrow=2)
  y_m_d    <- matrix(unlist(strsplit(date_sep[1,], split="-", fixed=TRUE)), nrow=3)
  h_m_s    <- matrix(unlist(strsplit(date_sep[2,], split=":", fixed=TRUE)), nrow=3)
  
  time_table <- data.table(
    Year    = as.numeric(unlist(y_m_d[1,])),
    Month   = as.numeric(unlist(y_m_d[2,])),
    Day     = as.numeric(unlist(y_m_d[3,])),
    Hours   = as.numeric(h_m_s[1,]),
    Minutes = as.numeric(h_m_s[2,])
  )
  return (time_table)
}

expanded_time <- ExpandDates(train$Dates)
train <- cbind(expanded_time, train)  
train[, c("Dates"):=NULL]

expanded_time <- ExpandDates(test$Dates)
test <- cbind(expanded_time, test)
test[, c("Dates"):=NULL]

rm(expanded_time)

cat(sprintf("Time: %s\n", Sys.time()))
print("Dates detalisation is finished")
print("The training data currently looks like: ")
# print(head(train))
print(str(train))

# Address feature expansion ----------------------------------

# Create boolean feature: "BLOCK" present in address or not
cat(sprintf("Checking for the word \"Block\" in Address field...\n"))
cat(sprintf("Time: %s\n", Sys.time()))

# Cheching how many addresses include word Block
# Checking the index of the word in Address
# Table shows that if the Block is present - it is second word
block_index <- rep(0, nrow(test))
for (i in 1:nrow(test))
{
  temp <- which(unlist(strsplit(test$Address[i], " ")) %in% c("Block"))
  if ( length(temp)>0 )
  {
    block_index[i] <- temp
  }
}
print("Testing data")
print(table(block_index))

block_index <- rep(0, nrow(train))
for (i in 1:nrow(train))
{
  temp <- which(unlist(strsplit(train$Address[i], " ")) %in% c("Block"))
  if ( length(temp)>0 )
  {
    block_index[i] <- temp
  }
}
print("Training data")
print(table(block_index))
cat(sprintf("Time: %s\n", Sys.time()))

Block <- c()
Address_New_test <- test$Address
for (i in 1:nrow(test)){
  
  Block[i] <- as.integer(grepl("Block", test$Address[i], fixed = TRUE))
  
  if ( Block[i] )
  {
    each_word <- unlist(strsplit(test$Address[i], split=' ', fixed=TRUE))
    Address_New_test[i] <- paste(each_word[-2], collapse = " ")
  }

}
test <- cbind(test, Block)

print("Test Blocks detected")
cat(sprintf("Time: %s\n", Sys.time()))

Block <- c()
Address_New_train <- train$Address
for (i in 1:nrow(train)){
  Block[i] <- as.integer(grepl("Block", train$Address[i], fixed = TRUE))
  
  if ( Block[i] )
  {
    each_word <- unlist(strsplit(train$Address[i], split=' ', fixed=TRUE))
    Address_New_train[i] <- paste(each_word[-2], collapse = " ")
  }
}
train <- cbind(train, Block)

print("Train Blocks detected")
cat(sprintf("Time: %s\n", Sys.time()))
# print(head(train))
print(str(train))

rm(Block)

# Create categorical feature with address number
# 85 unique categories of street numbers will be created
# 29.7% of addresses doesn't have a street number. They are replaced with 1203
print("Storing the street number as separate feature...")
cat(sprintf("Time: %s\n", Sys.time()))
StreetNumber <- rep(1203, nrow(train))
for (i in 1:nrow(test)){
  
  each_word <- unlist(strsplit(Address_New_test[i], split=' ', fixed=TRUE))
  
  # If the first word is a number - store it
  if (!is.na(as.numeric(each_word[1]))) {
    StreetNumber[i] <- as.numeric(each_word[1])
    Address_New_test[i] <- paste(each_word[-1], collapse = " ")
  }

}
test <- cbind(test, StreetNumber)

StreetNumber <- rep(1203, nrow(train))
for (i in 1:nrow(train)){
  
  each_word <- unlist(strsplit(Address_New_train[i], split=' ', fixed=TRUE))
  
  # If the first word is a number - store it
  if (!is.na(as.numeric(each_word[1]))) {
    StreetNumber[i] <- as.numeric(each_word[1])
    Address_New_train[i] <- paste(each_word[-1], collapse = " ")
  }
  
}
train <- cbind(train, StreetNumber)

cat(sprintf("Time: %s\n", Sys.time()))
print("Storing has been finished")
# print(head(train))
print(str(train))

# Add new Address feature without Block and Number
# It decreases number of categories for training data
# From 23,228 to 14,268

train <- cbind(train, Address_New_train)
test  <- cbind(test,  Address_New_test )

train[, c("Address"):=NULL]
test [, c("Address"):=NULL]

rm(Address_New_train, Address_New_test, block_index)

# Add coordinates grid  --------------------------------------

# Remove training coordinates outliners
# COMMENT: for testing data outliners will be assigned to most frequent 
# crime type as the sample is not valid for ML
# Boarder coordinates: Myself using Google Maps
X_max = -122.3271
X_min = -122.5176
Y_max = 37.8350
Y_min = 37.7075

index_delete <- which( train$X > X_max | train$X < X_min | 
                         train$Y > Y_max | train$Y < Y_min )

cat(sprintf("Total number of coordinates outliners: %d\n", 
            length(index_delete)))
cat(sprintf("The outliners consisted %.6f%% of the dataset\n", 
            100 * length(index_delete)/nrow(train)))


train <- train[-index_delete]
train_labels <- data.table(read.csv("data/output/TrainLabels.csv"))
train_labels <- train_labels[-index_delete]
write.csv(train_labels, file="data/output/TrainLabelsExtracted1.csv", 
          row.names=FALSE)


write.csv(train, file="data/output/TrainExtracted1.csv", 
          row.names=FALSE)
write.csv(test,  file="data/output/TestExtracted1.csv", 
          row.names=FALSE)