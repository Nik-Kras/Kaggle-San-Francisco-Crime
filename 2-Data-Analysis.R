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

# Make plots

# Show crime types distribution

# Show crime types over variables like hours, day, coordinates

# 

block_index <- rep(0, nrow(test))
for (i in 1:nrow(test))
{
  temp <- which(unlist(strsplit(test$Address[i], " ")) %in% c("Block"))
  if ( length(temp)>0 )
  {
    block_index[i] <- temp
  }
}
print("Testing data")
print(table(block_index))

block_index <- rep(0, nrow(train))
for (i in 1:nrow(train))
{
  temp <- which(unlist(strsplit(train$Address[i], " ")) %in% c("Block"))
  if ( length(temp)>0 )
  {
    block_index[i] <- temp
  }
}
print("Training data")
print(table(block_index))

plot(table(train$Minutes))


# Categories distribution ------------------------------------
print("The plot will show the distribution of categories/labels in traning set")
cat("The distribution of training labels can be used to compare with 
       Distribution of a testing set labels. They must have the similar nature
       If sets were splitted equally")

frequency_labels <- table(Labels_train_numbers)

# Increase margin so the text is visiable and plot the bar
par(mar=c(15,4,2,2))
barplot(height=frequency_labels, names=ListCategories, las=2)