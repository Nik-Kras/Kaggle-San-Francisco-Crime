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
# install.packages('MLmetrics')    # For LogLoss

library(randomForest)
library(caret)
library(e1071)
library(class)
library(data.table)
library(MLmetrics)

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

# Search for ntree ###################################

# print("Search for the best number of trees")
# accuracy_ntree <- rep(0, 20)
# n_trees = seq(100,1500,100)
# for (i in n_trees)
# {
#   temp_acc1 <- rep(0,10)
#   for (j in 1:10)
#   {
#     rf_default1 <- randomForest(Category ~ .,
#                                 train_set,
#                                 ntree=i,
#                                 mtry=3)
#     predict_valid1 <- predict(rf_default1, validate_set[,1:12])
#     temp_acc1[j] <- confusionMatrix(predict_valid1, validate_set$Category)$overall[1]
#     
#     cat(sprintf("Attempt number %d/10\n", j))
#     cat(sprintf("Temp accuracy %f\n", temp_acc1[j]))
#   }
#   
#   temp_acc2 <- rep(0,10)
#   for (j in 1:10)
#   {
#     rf_default1 <- randomForest(Category ~ .,
#                                 train_set,
#                                 ntree=i,
#                                 mtry=4)
#     predict_valid1 <- predict(rf_default1, validate_set[,1:12])
#     temp_acc2[j] <- confusionMatrix(predict_valid1, validate_set$Category)$overall[1]
#     
#     cat(sprintf("Attempt number %d/10\n", j))
#     cat(sprintf("Temp accuracy %f\n", temp_acc2[j]))
#   }
#   
#   accuracy_ntree[i/100] <- (sum(temp_acc2)+sum(temp_acc1))/20
#   
#   cat(sprintf("ntree = %d/2000\n", i))
#   cat(sprintf("Accuracy is: %.2f%%\n", 100*accuracy_ntree[i/100]))
#   print("###################################")
# }
# 
# plot(x=n_trees, y=accuracy_ntree)
# 
# write.csv(accuracy_ntree, file="data/output/Random Forest/Accuracy_ntree.csv", 
#           row.names=FALSE)

best_ntrees <- 700 # Rising from 100 to 700, then constant

# print("Search for the best number of features")
# accuracy_mtry <- rep(0, 12)
# mtry = 1:12
# for (i in mtry)
# {
#   
#   temp_acc2 <- rep(0,10)
#   for (j in 1:10)
#   {
#     rf_default1 <- randomForest(Category ~ .,
#                                 train_set,
#                                 ntree=400,
#                                 mtry=i)
#     predict_valid1 <- predict(rf_default1, validate_set[,1:12])
#     temp_acc2[j] <- confusionMatrix(predict_valid1, validate_set$Category)$overall[1]
# 
#     cat(sprintf("Attempt number %d/10\n", j))
#     cat(sprintf("Temp accuracy %f\n", temp_acc2[j]))
#   }
#   
#   accuracy_mtry[i] <- sum(temp_acc2)/10
#   
#   cat(sprintf("Time: %s\n", Sys.time()))
#   cat(sprintf("mtry = %d/12\n", i))
#   cat(sprintf("Accuracies are: %.2f\n", 100*accuracy_mtry[i]))
#   print("###################################")
# }
# 
# write.csv(accuracy_mtry, file="data/output/Random Forest/Accuracy_mtry.csv",
#           row.names=FALSE)

accuracy_mtry <- read.csv("data/output/Random Forest/Accuracy_mtry.csv")
accuracy_mtry <- as.numeric(unlist(accuracy_mtry))
best_mtry <- which.max(accuracy_mtry)   # max mtry 2 or 3

rf_default1 <- randomForest(Category ~ .,
                            train_set,
                            ntree=best_ntrees,
                            mtry=best_mtry)

# To check important variables
importance(rf_default1)
varImpPlot(rf_default1)

# Visualisation
hist(treesize(rf_default1),
     main = "No. of Nodes for the Trees",
     col = "green")

# Variable Importance
varImpPlot(rf_default1,
           sort = T,
           n.var = 10,
           main = "Top 10 - Variable Importance")
importance(rf_default1)
# MeanDecreaseGini

# Worked 30 mins for "each 10th sample"!!!
# rf_default1 <- train(Category ~ .,
#                data = train_set, 
#                method = 'rf',
#                trControl = trainControl(method = 'cv', 
#                                         number = 5)
# )

predict_valid <- predict(rf_default1, validate_set[,1:12])

print(confusionMatrix(predict_valid, validate_set$Category))

cat(sprintf("Log-loss: %f", LogLoss(as.numeric(levels(validate_set$Category))[validate_set$Category],
                                    as.numeric(levels(predict_valid))[predict_valid])))

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

# Apply to test data -----------------------------------------
cat(sprintf("Time: %s\n", Sys.time()))
print("Predict test daatset...")

rf.pred <- predict(rf_default1, test)

write.csv(rf.pred, file="data/output/Submit/RF_each_10_train.csv", 
          row.names=FALSE)

print("Random Forest is finished working.")
cat(sprintf("Time: %s\n", Sys.time()))

# Make and save the submission  --------------------------------

cat("Making submission file!")

source('make_submission.R')

SubmitTable <- data.table(read.csv("./data/dataset/sampleSubmission.csv",
                                   check.names=FALSE))
# First name is "ID" all next are categories
ListCategories <- colnames(SubmitTable)[-1]  

make_submit(labesl_predict = rf.pred,
            category_names = ListCategories,
            name = "RF_submission.csv",
            path = "data/output/Submit/")