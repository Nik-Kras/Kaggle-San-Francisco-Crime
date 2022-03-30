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
library(class)

# Definition of metrics ----------------------------------------

# *The function which calcs accuracy or loss*
# Or I can use confusionMatrix(xtab) form caret package!

# Reducing the data set ----------------------------------------

# For the big search of the best hyperparameters I will take 
# Relatively small part of dataset to spend hours, not days
# 878,000 samples ---> 17,560 samples

step <- 50
train_step  <- train[seq(1, nrow(train), step),]
labels_step <- Labels_train_numbers[seq(1, nrow(train), step)]

# tabulate - includes zero frequency, necessary for plot
# table - doesn't include zero frequency
frequency_labels_step <- tabulate(labels_step)

# Increase margin so the text is visiable and plot the bar
par(mar=c(15,4,2,2))
barplot(height=frequency_labels_step, names=ListCategories, las=2)

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

cat("The training and validation sets were created using random indexes
     The plots of their label frequency proofs that they are not distored\n")

rm(dt, step, labels_step, train_step)

frequency_labels_step <- tabulate(labels_valid)
par(mar=c(15,4,2,2))
barplot(height=frequency_labels_step, names=ListCategories, las=2)

frequency_labels_step <- tabulate(labels_train)
par(mar=c(15,4,2,2))
barplot(height=frequency_labels_step, names=ListCategories, las=2)

# The search for the best model  -------------------------------

MaxK = 100
Accuracy <- c()

cat(sprintf("The loop is setting which will try all K from 1 to %d\n", MaxK))

for (i in 1:MaxK)
{
  K <- i
  knn.pred <- knn(train=train_set, test=validate_set, cl=labels_train, k=K)
  knn.pred <- factor(as.character(knn.pred), levels = 1:39)
  
  labels_valid_factor <- factor(as.character(labels_valid),
                                levels = 1:39)
  
  CM <- confusionMatrix(table(knn.pred,labels_valid_factor))
  Accuracy <- append(Accuracy, CM$overall["Accuracy"])
  
  cat("---------------------------------------------------\n")
  cat(sprintf("The KNN model parameters: K=%d\n", K))
  cat(sprintf("The accuracy is %.2f%% \n", Accuracy[i]*100))
  cat(sprintf("Time: %s\n", Sys.time()))
}

cat("The loop is finished. The accuracy for each K number 
    can be seen on the plot\n")

par(mar=c(5,4,2,2))
plot(Accuracy, type="p", main = "KNN accuracy over param. K")

cat(sprintf("Max accuracy has been achieved with K=%d\n", which.max(Accuracy)))
cat("While looking at the plot it could be seen that after apx.K=30
     The accuracy almost stops rising\n")

# Validating the best KNN model  -------------------------------

cat(sprintf("The original train dataset will be divided to 
    Validation and Training sets. The two models will be applied for them
    One with K=30 and another with K=%d. The model with best accuracy will
    be used for Testing set.\n", which.max(Accuracy)))

dt           <- sort(sample(nrow(train), nrow(train)*0.7))
validate_set <- train[-dt,]
train_set    <- train[dt,]
labels_valid <- Labels_train_numbers[-dt]
labels_train <- Labels_train_numbers[dt]

# According to theory generall K is choosen as sqrt(nrow(train)) -> 940
K_chosen = 30 #c(30, which.max(Accuracy))
Accuracy_all <- c()

for (K in K_chosen)
{
  knn.pred <- knn(train=train_set, test=validate_set, cl=labels_train, k=K)
  knn.pred <- factor(as.character(knn.pred), levels = 1:39)
  
  labels_valid_factor <- factor(as.character(labels_valid),
                                levels = 1:39)
  
  CM <- confusionMatrix(table(knn.pred,labels_valid_factor))
  Accuracy_all <- append(Accuracy_all, CM$overall["Accuracy"])
}

cat(sprintf("Time: %s\n", Sys.time()))
cat(sprintf("The accuracy is %.2f%% \n", Accuracy_all*100))

par(mar=c(5,4,2,2))
plot(Accuracy_all, y=30,
     xlab = "K",
     ylab = "Accuracy",
     main = "KNN accuracy for whole dataset")

write.csv(Accuracy_all, file="data/output/KNN_accuracy_all_dataset.csv", 
          row.names=FALSE)

write.csv(Accuracy, file="data/output/KNN_accuracy_each_50.csv", 
          row.names=FALSE)

# Using model for Kaggle submission  ---------------------------

cat("Applying the same hyperparameters to make a predictions
     On real testing data for a Kaggle submission\n")
cat(sprintf("Time: %s\n", Sys.time()))

knn.pred <- knn(train=train, 
                test=test, 
                cl=Labels_train_numbers, 
                k=30)

write.csv(knn.pred, file="data/output/Submit/KNN_output_labels.csv", 
          row.names=FALSE)

cat(sprintf("Time: %s\n", Sys.time()))

# Make and save the submission  --------------------------------

cat("Making submission file!")

source('make_submission.R')

make_submit(labesl_predict = knn.pred,
            category_names = ListCategories,
            name = "KNN_submission.csv",
            path = "data/output/Submit/")