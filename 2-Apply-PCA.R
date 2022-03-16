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

# Feature analysis --------------------------------------------
print("Making dependencies plot...")
cat(sprintf("Time: %s\n", Sys.time()))

# Take a smaller dataset to make a plot of it to see if the PCA can be applied
step <- 3000
test_step <- test[seq(1, nrow(test), step),]
plot(test_step)

rm(test_step, step)

cat(sprintf("Time: %s\n", Sys.time()))
print("Making dependencies plot is finished")
cat('The plot shows that the variance of X and partically Y is lower than others.
     It means that PCA analysis may be used to reduce the number of features, 
     Replacing them by new orthogonal ones.\n')

# Principal component analysis---------------------------------
print("PCA analysis...")
cat(sprintf("Time: %s\n", Sys.time()))

# Show the Principal Components
pc <- princomp(train)
par(mar=c(4,6,1,2))
plot(pc, type = "l")

# Show the variance of each feature
par(mar=c(4,6,1,2))
barplot(sapply(train, var), horiz=T, las=1, cex.names=0.8, log='x')

cat(sprintf("Time: %s\n", Sys.time()))
print("PCA analysis is finished")
cat("Analysing the feature variance it could be seen that the X and Y
    have much less variance than all others. It is a reason why PCA will
    be used efficiently.\n\nThe next plot shows variances of Principal Components
    The new projections were built and as it could be notice, only 6 of 8
    PC consist of almost all information. So the dimensionality may be reduced 
    from 8 to 6!\n")

# PCA dimension reduction  ------------------------------------
print("Dimension reduction...")
cat(sprintf("Time: %s\n", Sys.time()))

PCA_number <- 6

train_pc <- prcomp(train)
test_pc  <- prcomp(test)

train <- data.frame(train_pc$x[,1:PCA_number])
test  <- data.frame(test_pc$x[,1:PCA_number])

rm(train_pc, test_pc, pc, PCA_number)

cat(sprintf("Time: %s\n", Sys.time()))
print("Dimension reduction is finished.")
print(head(train))

# Check the variance of new features of the data set -----------

# Show the variance of each feature
par(mar=c(4,6,1,2))
barplot(sapply(train, var), horiz=T, las=1, cex.names=0.8, log='x')

# Take a smaller dataset to make a plot of it to see if the PCA can be applied
step <- 3000
test_step <- test[seq(1, nrow(test), step),]
plot(test_step)

rm(test_step, step)