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
step = 3000
test_step <- test[seq(1, nrow(test), step),]
plot(test_step)
rm(test_20, test_step, step)

cat(sprintf("Time: %s\n", Sys.time()))
print("Making dependencies plot is finished")
cat('The plot shows that the variance of X and partically Y is lower than others.
     It means that PCA analysis may be used to reduce the number of features, 
     Replacing them by new orthogonal ones.')
# PCA dimension reduction  ------------------------------------
print("PCA analysis...")
cat(sprintf("Time: %s\n", Sys.time()))

pc <- prcomp(train)

cat(sprintf("Time: %s\n", Sys.time()))
print("PCA analysis is finished")