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

# install.packages("randomForest") # For randomForest
library(randomForest)
library(caret)
library(e1071)
library(class)
library(data.table)

# Load data --------------------------------------------------
rm(list=ls())

print("Loading data...")
cat(sprintf("Time: %s\n", Sys.time()))

train <- data.table(read.csv("data/output/Normalization/TrainNormalize.csv"))
test  <- data.table(read.csv("data/output/Normalization/TestNormalize.csv" ))
train_labels <- data.table(read.csv("data/output/TrainLabelsExtracted1.csv"))

colnames(train_labels) <- "Category"
train_labels <- sapply(train_labels, FUN=factor)
train_labels <- factor(train_labels)
train <- cbind(train, Category = train_labels)

# Search Random Forest parameters  ---------------------------

# Methods to find best parameters:
# 1. Random Search
# 2. Grid Search

# Lit Review shows: 
#    number of trees = 200, 250 (ntree)
#    max depth       = 13,  25  (maxnodes)

# Use 10-Fold-Validation

print("Search for the parameters...")
cat(sprintf("Time: %s\n", Sys.time()))

set.seed(1203)

step <- 10
train_step  <- train[seq(1, nrow(train), step),]

dt           <- sort(sample(nrow(train_step), nrow(train_step)*0.7))
validate_set <- train_step[-dt,]
train_set    <- train_step[dt,]

# $Category <- factor(train_step$Category)

rf_default1 <- randomForest(Category ~ ., 
                            train_set,
                            ntree=250,
                            mtry=4,        # Try 3 or 4
                            maxnodes=20)

predict_valid <- predict(rf_default1, validate_set[,1:12])

print(confusionMatrix(predict_valid, validate_set$Category))

plot(predict_valid)

# Takes too long (and probably stucks)
# rf_default <- train(formula = Category ~ ., 
#                     data = train_step,
#                     method = 'rf',
#                     importance=TRUE)

# rf_default <- train(formula = Category ~ ., 
#                     data = train_step,
#                     method = 'rf',
#                     importance=TRUE,
#                     trControl = trainControl(method = 'cv', # Use cross-validation
#                                              number = 5)    # Use 5 folds for cross-validation
#                     )

# rf_default <- train(formula = Category ~ ., 
#       data = train_step, 
#       method = "rpart",
#       metric= "Accuracy", 
#       trControl = trainControl(), 
#       tuneGrid = NULL)

# Print the results
print(rf_default1)


# test_Category <- predict(model, newdata = test)