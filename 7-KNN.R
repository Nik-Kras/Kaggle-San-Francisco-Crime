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

# install.packages('caret')
library(ggplot2)
library(lattice)
library(caret)
library(scales)
library(class)
library(data.table)

# Load data --------------------------------------------------
rm(list=ls())

print("Loading data...")
cat(sprintf("Time: %s\n", Sys.time()))

train <- data.table(read.csv("data/output/Normalization/TrainNormalize.csv"))
test  <- data.table(read.csv("data/output/Normalization/TestNormalize.csv" ))
train_labels <- data.table(read.csv("data/output/TrainLabelsExtracted1.csv"))

SubmitTable <- data.table(read.csv("./data/dataset/sampleSubmission.csv",
                                   check.names=FALSE))
# First name is "ID" all next are categories
ListCategories <- colnames(SubmitTable)[-1]  

colnames(train_labels) <- "Category"
train_labels <- sapply(train_labels, FUN=factor)
train_labels <- factor(train_labels)
train <- cbind(train, Category = train_labels)

# Definition of metrics ----------------------------------------

# *The function which calcs accuracy or loss*
# Or I can use confusionMatrix(xtab) form caret package!

# Reducing the data set ----------------------------------------

# For the big search of the best hyperparameters I will take 
# Relatively small part of dataset to spend hours, not days
# 878,000 samples ---> 17,560 samples

step <- 100
train_step  <- train[seq(1, nrow(train), step),]
labels_step <- train_labels[seq(1, nrow(train), step)]

# tabulate - includes zero frequency, necessary for plot
# table - doesn't include zero frequency
frequency_labels_step <- table(labels_step)
plot(frequency_labels_step)

cat("To find a best hyperparameters for a ML methods there is no need
     to work on whole dataset and spend huge amount of time. THat is why
     only 1/100 of dataset was taken for it\n")
cat("For reducing the dataset the decimation technique was used.
     To make sure that reduced daatset is not distored the frequency
     Analysis of output labels is provided.
     Comparison of the frequencies for whole dataset and for reduced one
     shows that dataset nature is similar to original\n")

# Creating the training and validation sets --------------------

cat("To get a feedbakc of a ML model the training data is divided
     to training and validation sets\n")
set.seed(1203)
dt           <- sort(sample(nrow(train_step), nrow(train_step)*0.7))
validate_set <- train_step[-dt,]
train_set    <- train_step[dt,]
labels_valid <- labels_step[-dt]
labels_train <- labels_step[dt]

# Bad piece of code DELETE
# Prevents from errors with bug step!
for (i in 1:39)
{
  train_set    <- rbind(train_set,    train[train$Category == i][1])
  validate_set <- rbind(validate_set, train[train$Category == i][1])
  
  labels_train<-append(labels_train, i)
  labels_valid<-append(labels_valid, i)
}
validate_set <- validate_set[,1:12]
train_set    <- train_set[,1:12]

cat("The training and validation sets were created using random indexes
     The plots of their label frequency proofs that they are not distored\n")

rm(dt, step, labels_step, train_step)

# The search for the best model  -------------------------------

K_check = c(1, 10, 50, 100, 501, 1000, 2000, 4000)
Accuracy <- c()

cat(sprintf("The loop is setting which will try all K from the list\n"))

for (i in K_check)
{
  K <- i
  knn.pred <- knn(train=train_set, 
                  test=validate_set, 
                  cl=labels_train, 
                  k=K,
                  l=1,
                  use.all = FALSE)
  
  knn.pred <- factor(as.character(knn.pred), levels = 1:39)

  labels_valid_factor <- factor(as.character(labels_valid),
                                levels = 1:39)

  CM <- confusionMatrix(table(knn.pred,labels_valid_factor))
  Accuracy <- append(Accuracy, CM$overall["Accuracy"])

  cat("---------------------------------------------------\n")
  cat(sprintf("The KNN model parameters: K=%d\n", K))
  cat(sprintf("The accuracy is %.2f%% \n", CM$overall["Accuracy"]*100))
  cat(sprintf("Time: %s\n", Sys.time()))
}

cat("The loop is finished. The accuracy for each K number
    can be seen on the plot\n")

#############################
# set.seed(400)
# knnGrid <-  expand.grid(k = c(1, 10, 50, 100, 500, 1000, 2000, 4000))
# fitControl <- trainControl(method = "cv",
#                            number = 10)
# 
# knnFit <- train(Category ~ .,
#                 data = train_set,
#                 method = "knn",
#                 trControl = fitControl,
#                 tuneGrid = knnGrid)
# 
# #Output of kNN fit
# knnFit
# 
# knnPredict <- predict(knnFit,newdata = validate_set[,1:12])
# confusionMatrix(knnPredict, validate_set[,13])

# par(mar=c(5,4,2,2))
# plot(Accuracy, type="p", main = "KNN accuracy over param. K")
# 
# cat(sprintf("Max accuracy has been achieved with K=%d\n", which.max(Accuracy)))
# cat("While looking at the plot it could be seen that after apx.K=30
#      The accuracy almost stops rising\n")
# 


# # Validating the best KNN model  -------------------------------
# 
# cat(sprintf("The original train dataset will be divided to 
#     Validation and Training sets. The two models will be applied for them
#     One with K=30 and another with K=%d. The model with best accuracy will
#     be used for Testing set.\n", which.max(Accuracy)))
# 
# dt           <- sort(sample(nrow(train), nrow(train)*0.7))
# validate_set <- train[-dt,]
# train_set    <- train[dt,]
# labels_valid <- Labels_train_numbers[-dt]
# labels_train <- Labels_train_numbers[dt]
# 
# # According to theory generall K is choosen as sqrt(nrow(train)) -> 940
# K_chosen = K_check[which.max(Accuracy)] #c(30, which.max(Accuracy))
# Accuracy_all <- c()
# 
# for (K in K_chosen)
# {
#   knn.pred <- knn(train=train_set, test=validate_set, cl=labels_train, k=K)
#   knn.pred <- factor(as.character(knn.pred), levels = 1:39)
#   
#   labels_valid_factor <- factor(as.character(labels_valid),
#                                 levels = 1:39)
#   
#   CM <- confusionMatrix(table(knn.pred,labels_valid_factor))
#   Accuracy_all <- append(Accuracy_all, CM$overall["Accuracy"])
# }
# 
# cat(sprintf("Time: %s\n", Sys.time()))
# cat(sprintf("The accuracy is %.2f%% \n", Accuracy_all*100))
# 
# par(mar=c(5,4,2,2))
# plot(Accuracy_all, y=30,
#      xlab = "K",
#      ylab = "Accuracy",
#      main = "KNN accuracy for whole dataset")
# 
# write.csv(Accuracy_all, file="data/output/KNN_accuracy_all_dataset.csv", 
#           row.names=FALSE)
# 
# write.csv(Accuracy, file="data/output/KNN_accuracy_each_50.csv", 
#           row.names=FALSE)
# 
# # Using model for Kaggle submission  ---------------------------
# 
# cat("Applying the same hyperparameters to make a predictions
#      On real testing data for a Kaggle submission\n")
# cat(sprintf("Time: %s\n", Sys.time()))
# 
# knn.pred <- knn(train=train, 
#                 test=test, 
#                 cl=Labels_train_numbers, 
#                 k=30)
# 
# write.csv(knn.pred, file="data/output/Submit/KNN_output_labels.csv", 
#           row.names=FALSE)
# 
# cat(sprintf("Time: %s\n", Sys.time()))
# 
# # Make and save the submission  --------------------------------
# 
# cat("Making submission file!")
# 
# source('make_submission.R')
# 
# make_submit(labesl_predict = knn.pred,
#             category_names = ListCategories,
#             name = "KNN_submission.csv",
#             path = "data/output/Submit/")