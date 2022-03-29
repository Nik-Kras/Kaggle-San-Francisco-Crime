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
print("Dataset reduces to accelerate the search of hyperparameters")
step <- 50
train_step  <- train[seq(1, nrow(train), step),]
labels_step <- Labels_train_numbers[seq(1, nrow(train), step)]

# Merge the data 
train_step_m <- cbind(train_step, labels_step)

# Split data to train and validate
set.seed(1203)
dt           <- sort(sample(nrow(train_step_m), nrow(train_step_m)*0.7))
validate_set <- train_step_m[-dt,]
train_set    <- train_step_m[dt,]

# Find best model with Cross-Validation (run only once! takes a long)
# print("Use of tuning, Cross-Validation - to find the best parameters")
# tune <- tune.svm(labels_step ~ ., 
#                  data  = train_set, 
#                  gamma = seq(0.1, 0.2, by = .1), 
#                  cost  = seq(1,2, by = 1))
# 
# cat("All output:\n")
# print(tune$performances)
# cat("Best parameters:\n")
# print(tune$best.parameters)

# **************************************************************************
# !!! TAKES 19 HOURS !!! Run Once Only !!!
# Find the best model comparing testing
# I used different basises to make equal numbers in the list
print("Search for the best parameters:")

normal_gamma_list <- 3 ^(1:10) / 10000   # Range 0.0001 -- 10
normal_cost_list  <- 2^(1:10) / 10       # Range 0.1    -- 100
normal_kernel_list <- c("linear", "polynomial", "radial", "sigmoid")

gamma_list <- rep(normal_gamma_list, 1, each=length(normal_cost_list))
cost_list  <- rep(normal_cost_list, length(normal_gamma_list))

kernel_list <- rep(normal_kernel_list, each=length(cost_list)) 

gamma_list <- rep(gamma_list, length(normal_kernel_list))
cost_list  <- rep(cost_list, length(normal_kernel_list))
Accuracy    <- data.frame(gamma_list, cost_list, 
                          kernel_list, accuracy=rep(0,400))

cnt <- 1
for (k in normal_kernel_list)
{
  for (c in normal_cost_list)
  {
    for (g in normal_gamma_list)
    {
      svm_model <- svm(labels_step ~ ., 
                       data   = train_set,
                       kernel = k,
                       gamma  = g, 
                       cost   = c)
      svmpredict <- round( predict( svm_model, 
                                    validate_set, 
                                    type = "response" ))
      t <- table( pred = svmpredict, true=validate_set$labels_step )
      Accuracy$accuracy[cnt] <- sum(diag(t)/(sum(t)))
      
      
      cat("---------------------------------------------------\n")
      cat(sprintf("The SVM model parameters: gamma=%f, cost=%f, kernel=%s\n", 
                  g, c, k))
      cat(sprintf("Number of iteration: %d/400\n", cnt))
      cat(sprintf("The accuracy is %.2f%% \n", Accuracy$accuracy[cnt]*100))
      cat(sprintf("Time: %s\n", Sys.time()))
      
      cnt <- cnt + 1
    }
  }
}
write.csv(Accuracy, file="data/output/SVM/Accuracy_gamma_cost_kernel.csv", 
          row.names=FALSE)
# **************************************************************************

# Make 3D plots of accuracy

Accuracy <- read.csv(file = 'data/output/SVM/Accuracy_gamma_cost_kernel.csv')
axx <- list(
  title = "Cost"
)

axy <- list(
  title = "Gamma"
)

axz <- list(
  title = "Accuracy"
)
x <- normal_cost_list
y <- normal_gamma_list
z_lin <- matrix(Accuracy$accuracy[1:100],   nrow = 10, byrow = TRUE)
z_pol <- matrix(Accuracy$accuracy[101:200], nrow = 10, byrow = TRUE)
z_rad <- matrix(Accuracy$accuracy[201:300], nrow = 10, byrow = TRUE)
z_sig <- matrix(Accuracy$accuracy[301:400], nrow = 10, byrow = TRUE)

fig <- plot_ly(z=z_lin, type = 'surface') 
fig <- fig %>% layout(scene = list(xaxis=axx,yaxis=axy,zaxis=axz), 
                      title = "SVM Linear")
fig

fig <- plot_ly(z=z_pol, type = 'surface') 
fig <- fig %>% layout(scene = list(xaxis=axx,yaxis=axy,zaxis=axz), 
                      title = "SVM Polynomial")
fig

fig <- plot_ly(z=z_rad, type = 'surface') 
fig <- fig %>% layout(scene = list(xaxis=axx,yaxis=axy,zaxis=axz), 
                      title = "SVM Radial")
fig

fig <- plot_ly(z=z_sig, type = 'surface') 
fig <- fig %>% layout(scene = list(xaxis=axx,yaxis=axy,zaxis=axz), 
                      title = "SVM Sigmoid")
fig


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
