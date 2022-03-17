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
# 878,000 samples ---> 8,780 samples

step <- 100
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

dt           <- sort(sample(nrow(train_step), nrow(train_step)*0.7))
validate_set <- train_step[-dt,]
train_set    <- train_step[dt,]
labels_valid <- labels_step[-dt]
labels_train <- labels_step[dt]

cat("The training and validation sets were created using random indexes
     The plots of their label frequency proofs that they are not distored\n")

frequency_labels_step <- tabulate(labels_valid)
par(mar=c(15,4,2,2))
barplot(height=frequency_labels_step, names=ListCategories, las=2)

frequency_labels_step <- tabulate(labels_train)
par(mar=c(15,4,2,2))
barplot(height=frequency_labels_step, names=ListCategories, las=2)

# The search for the best model  -------------------------------

knn.pred <- knn(train=train_set, test=validate_set, cl=labels_train, k=1)
knn.pred <- factor(as.character(knn.pred), levels = 1:39)

labels_valid_factor <- factor(as.character(knn.pred),
                              levels = 1:39)

confusionMatrix(table(knn.pred,labels_valid))

frequency_labels_step <- tabulate(knn.pred)
par(mar=c(15,4,2,2))
barplot(height=frequency_labels_step, names=ListCategories, las=2)
