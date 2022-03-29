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

# Expand dates features --------------------------------------
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
print(head(train))

# Address feature expansion ----------------------------------

# Create boolean feature: "BLOCK" present in address or not
print("Checking for the word \"Block\" in Address field...")
cat(sprintf("Time: %s\n", Sys.time()))
Block <- c()
for (i in nrow(test)){
  Block[i] <- as.integer(grepl("Block", test$Address[i], fixed = TRUE))
}
test <- cbind(test, Block)

Block <- c()
for (i in 1:nrow(train)){
  Block[i] <- as.integer(grepl("Block", train$Address[i], fixed = TRUE))
}
train <- cbind(train, Block)

cat(sprintf("Time: %s\n", Sys.time()))
print("Check has been finished")
print(head(train))

rm(Block)

# Create categorical feature with address number
# 85 unique categories of street numbers will be created
# 29.7% of addresses doesn't have a street number. They are replaced with 1203
print("Storing the street number as separate feature...")
cat(sprintf("Time: %s\n", Sys.time()))
Street_Number <- c()
for (i in 1:nrow(test)){
  each_word <- matrix(unlist(strsplit(test$Address[i], split=' ', fixed=TRUE)))
  
  # If the first word is a number - store it
  if (!is.na(as.numeric(each_word[1]))) {
    Street_Number[i] <- as.numeric(each_word[1])
  }else{
    Street_Number[i] <- 1203
  }

}
test <- cbind(test, Street_Number)

Street_Number <- c()
for (i in 1:nrow(train)){
  each_word <- matrix(unlist(strsplit(train$Address[i], split=' ', fixed=TRUE)))
  
  # If the first word is a number - store it
  if (!is.na(as.numeric(each_word[1]))) {
    Street_Number[i] <- as.numeric(each_word[1])
  }else{
    Street_Number[i] <- 1203
  }
  
}
train <- cbind(train, Street_Number)

cat(sprintf("Time: %s\n", Sys.time()))
print("Storing has been finished")
print(head(train))

#