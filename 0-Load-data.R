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
# update.packages() # Probably need to run once!
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

# Save labels ------------------------------------------------
print("Labels saving...")
cat(sprintf("Time: %s\n", Sys.time()))

write.csv(Labels_train_numbers, file="data/output/TrainLabels.csv", 
          row.names=FALSE)

rm(SubmitTable, i)

cat(sprintf("Time: %s\n", Sys.time()))
print("Labels are saved")