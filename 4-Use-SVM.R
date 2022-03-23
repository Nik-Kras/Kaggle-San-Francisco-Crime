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

library("e1071")
library(GGally)
library(ggplot2)
library(readxl)

# Reduce dataset
step <- 200
train_step  <- train[seq(1, nrow(train), step),]
labels_step <- Labels_train_numbers[seq(1, nrow(train), step)]

# Merge the data 
train_step_m <- cbind(train_step, labels_step)

# Split data to train and validate
set.seed(1203)
dt           <- sort(sample(nrow(train_step_m), nrow(train_step_m)*0.7))
validate_set <- train_step_m[-dt,]
train_set    <- train_step_m[dt,]

# Find best model (run only once! takes a long)
# tune <- tune.svm(labels_step ~ ., 
#                  data  = train_set, 
#                  gamma = seq(0.1, 0.2, by = .1), 
#                  cost  = seq(1,2, by = 1))
# 
# cat("All output:\n")
# print(tune$performances)
# cat("Best parameters:\n")
# print(tune$best.parameters)

# Make a model
gamma_best  <- 0.1 # tune$best.parameters$gamma # 0.1
cost_best   <- 1   # tune$best.parameters$cost  # 1
kernel_best <- "radial"
svm_model   <- svm(labels_step ~ ., 
                   data   = train_set,
                   kernel = kernel_best,
                   gamma  = gamma_best, 
                   cost   = cost_best)
summary(svm_model)

# Validate SVM model 
svmpredict <- round( predict( svm_model, validate_set, type = "response" ))
table( pred = svmpredict, true=validate_set$labels_step )
cat(sprintf("The accuracy: %f%%", sum(diag(t)/(sum(t)))))

# Plot the model boundary (Isn't working)
# plot(svm_model, data=validate_set,
#      PC1~PC4,
#      slice = list(PC2=0.5, PC3=0.5, PC5=0.5, PC6=0.5))
# 
# plot(svm_model, data=validate_set)

# Ew, Looks bad with PCA
par(mar=c(4,6,1,2))
plot(validate_set$X, validate_set$Time, col=validate_set$labels_step)
plot(validate_set$Y, validate_set$Time, col=validate_set$labels_step)