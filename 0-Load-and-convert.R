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

# Import libraries --------------------------------------------
library(scales)
library(class)
library(data.table)

rm(list=ls())

# Load data ---------------------------------------------------
print("Loading training data...")
cat(sprintf("Time: %s\n", Sys.time()))

train <- data.table(read.csv("./data/dataset/train.csv"))
test  <- data.table(read.csv("./data/dataset/test.csv"))  

cat(sprintf("Time: %s\n", Sys.time()))
print("Training data is loaded.")
print("The training data currently looks like: ")
print(head(train))

# Delete unnecessary features ---------------------------------
# They are not present in testing data
# Reorder for comfort
print("Deleting features and reordering...")

train[, c("Descript","Resolution","Address"):=NULL]
setcolorder(train, c("Dates", 
                     "DayOfWeek", 
                     "PdDistrict",
                     "X", "Y", 
                     "Category"))     
test[, c("Address", "Id"):=NULL]
setcolorder(test, c("Dates", 
                    "DayOfWeek", 
                    "PdDistrict",
                    "X", "Y"))

cat(sprintf("Time: %s\n", Sys.time()))
print("Deleting features and reordering is finished")
print("The training data currently looks like: ")
print(head(train))

# Expand dates features --------------------------------------
print("Increasing feature count by dates detalisation...")
ExpandDates <- function(Dates){
  
  dates    <- Dates
  date_sep <- matrix(unlist(strsplit(dates, split=' ', fixed=TRUE)),        nrow=2)
  y_m_d    <- matrix(unlist(strsplit(date_sep[1,], split="-", fixed=TRUE)), nrow=3)
  h_m_s    <- matrix(unlist(strsplit(date_sep[2,], split=":", fixed=TRUE)), nrow=3)
  
  time_table <- data.table(
    Years  = as.numeric(unlist(y_m_d[1,])),
    Months = as.numeric(unlist(y_m_d[2,])),
    Days   = as.numeric(unlist(y_m_d[3,])),
    Time   = as.numeric(h_m_s[1,])*60 + as.numeric(h_m_s[2,])
  )
  return (time_table)
}

expanded_time <- ExpandDates(train$Dates)
train <- cbind(expanded_time, train)  

expanded_time <- ExpandDates(test$Dates)
test <- cbind(expanded_time, test)

rm(expanded_time)

cat(sprintf("Time: %s\n", Sys.time()))
print("Dates detalisation is finished")
print("The training data currently looks like: ")
print(head(train))
