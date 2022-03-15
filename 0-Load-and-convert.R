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

set.seed(1203)

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
cat(sprintf("Time: %s\n", Sys.time()))

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
cat(sprintf("Time: %s\n", Sys.time()))
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
train[, c("Dates"):=NULL]

expanded_time <- ExpandDates(test$Dates)
test <- cbind(expanded_time, test)
test[, c("Dates"):=NULL]

rm(expanded_time)

cat(sprintf("Time: %s\n", Sys.time()))
print("Dates detalisation is finished")
print("The training data currently looks like: ")
print(head(train))

# Convert strings to numbers ---------------------------------
print("Converting strings to numbers...")
cat(sprintf("Time: %s\n", Sys.time()))

key_names <- unique(train$DayOfWeek)
for (i in 1:length(key_names))
{
  train$DayOfWeek[train$DayOfWeek == key_names[i]]  <- i
  test$DayOfWeek [test$DayOfWeek  == key_names[i]]  <- i
}

key_names <- unique(train$PdDistrict)
for (i in 1:length(key_names))
{
  train$PdDistrict[train$PdDistrict == key_names[i]]  <- i
  test$PdDistrict [test$PdDistrict  == key_names[i]]  <- i
}

rm(i, key_names)

cat(sprintf("Time: %s\n", Sys.time()))
print("Converting strings to numbers has been finished.")
print(head(train))

# Separate labels --------------------------------------------
print("Separating labels...")
cat(sprintf("Time: %s\n", Sys.time()))

# Separate thr Category from the train data
Labels_train <- train$Category
train[, c("Category"):=NULL]

print("Currently labels looks like this")
print(Labels_train[1:10])

SubmitTable <- data.table(read.csv("./data/dataset/sampleSubmission.csv",
                                   check.names=FALSE))
# First name is "ID" all next are categories
ListCategories <- colnames(SubmitTable)[-1]   
                          
# Convert labels to numbers
for (i in 1:length(ListCategories))
{
  Labels_train[Labels_train == ListCategories[i]] <- as.integer(i)
}

Labels_train_numbers <- as.integer(Labels_train)

print("UPD: Currently labels looks like this")
print(Labels_train_numbers[1:10])

cat(sprintf("Time: %s\n", Sys.time()))
print("Separating labels is finished")

# Categories distribution ------------------------------------
print("The plot will show the distribution of categories/labels in traning set")
print("The distribution of training labels can be used to compare with 
       Distribution of a testing set labels. They must have the similar nature
       If sets were splitted equally")

frequency_labels <- table(Labels_train_numbers)

# Increase margin so the text is visiable and plot the bar
par(mar=c(15,4,2,2))
barplot(height=frequency_labels, names=ListCategories, las=2)

# Save labels ------------------------------------------------
print("Labels saving...")
cat(sprintf("Time: %s\n", Sys.time()))

write.csv(Labels_train_numbers, file="data/output/TrainLabels.csv", 
          row.names=FALSE)

cat(sprintf("Time: %s\n", Sys.time()))
print("Labels are saved")