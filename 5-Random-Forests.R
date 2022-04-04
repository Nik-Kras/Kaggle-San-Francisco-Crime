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

# Will try to use 200 accordingly to stop decreasing of the loss in CV model!
best_ntrees <- 700 # Rising from 100 to 700, then constant

# mtry 2 is better for Accuracy by 0.1%, mtry 3 is better for Kappa by 0.1
best_mtry <- 3 #which.max(accuracy_mtry)   # max mtry 2 or 3

# Create the best model and predict  -------------------------

cat(sprintf("Time: %s\n", Sys.time()))
print("Applying 10-fold Cross Validation...")

library(caret)
library(e1071)

# Using full data it can not allocate 8 Gb of memory (16 Gb in total)
# So, 1/step of training data was chosen
# (While previously I could work on whole data, something is wrong)
step <- 40
train_step  <- train[seq(1, nrow(train), step),]

print("Doing ntrees = 700")
cat(sprintf("Time: %s\n", Sys.time()))

numFolds <- trainControl(method = "cv", number = 10)

# Frequency Analysis showed that most trees has 2000 nodes, so setting 
# Min number as 1200 qill increase growth
best_nodesize <- 1200

tuneGrid <- expand.grid(.mtry = c(best_mtry))
rf_CV <- train(Category ~ .,
               data = train_step,
               method = "rf",
               trControl = numFolds,
               tuneGrid = tuneGrid,
               ntree = best_ntrees,
               nodesize= 20)

# Deeper trees reduces the bias; more trees reduces the variance.
# maxnodes = 20
# nodesize = 13 or 20 ??? (could be 1% of data, so 8700)

rf.pred <- predict(rf_CV, test, 
                   type = 'prob')
# To make a submission with ptobabilities -- Preparation
SubmitTable <- data.table(read.csv("./data/dataset/sampleSubmission.csv",
                                   check.names=FALSE))
# First name is "ID" all next are categories
ListCategories <- colnames(SubmitTable)[-1]  

# To make a submission with ptobabilities
rf.pred2 = data.frame(rf.pred)
colnames(rf.pred2) <- as.numeric(substr(names(rf.pred2), 2, 3))
right_order_names <- as.character(1:39)
df<-rf.pred2[right_order_names]

colnames(df) <- ListCategories
Id = data.frame(0:(nrow(df)-1))
colnames(Id) <- "Id"
df <- cbind(Id, df)

path = "data/output/Submit/"
name = "RF_submission_all_train_CV_prob_ntree_700_each_50_nodesize.csv"
# write.csv(df, file=paste(path, name, sep=""), row.names=FALSE)

# save(rf_CV,file = "data/output/Random Forest/RF_model_m3_n700_CV_prob_each_50_nodesize.RData")


z <- colSums(df)
barplot(height=z[-1], names=ListCategories, las=2)

hist(treesize(rf_CV$finalModel),
     main = "No. of Nodes for the Trees",
     col = "green")

# Variable Importance
varImpPlot(rf_CV$finalModel,
           sort = T,
           n.var = 10,
           main = "Top 10 - Variable Importance")
importance(rf_CV$finalModel)
     
     
# # To check important variables
# importance(rf_final_CV)
# varImpPlot(rf_final_CV)
# 
# # Visualisation
# hist(treesize(rf_final_CV),
#      main = "No. of Nodes for the Trees",
#      col = "green")
# 
# # Variable Importance
# varImpPlot(rf_final_CV,
#            sort = T,
#            n.var = 10,
#            main = "Top 10 - Variable Importance")
# importance(rf_final_CV)

# To load model
# load("data/output/Random Forest/RF_model_CV_each_10.RData")

# write.csv(rf.pred2, file="data/output/Submit/RF_10F_CV_each_10_train.csv", 
#           row.names=FALSE)

# Make and save the submission  --------------------------------

# cat("Making submission file!")
# 
# source('make_submission.R')
# 
# make_submit(labesl_predict = rf.pred2,
#             category_names = ListCategories,
#             name = "RF_submission_all_train.csv",
#             path = "data/output/Submit/")
# 

print("Random Forest is finished working.")
cat(sprintf("Time: %s\n", Sys.time()))