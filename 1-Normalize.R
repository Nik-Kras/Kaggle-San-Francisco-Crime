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
# Normalization -----------------------------------------------
print("Data normalization...")
cat(sprintf("Time: %s\n", Sys.time()))

for (i in c(1:8))
{
  train[,i] <- rescale(as.numeric(array(unlist(train[,..i]))))
  test[,i]  <- rescale(as.numeric(array(unlist(test[,..i]))))
}

cat(sprintf("Time: %s\n", Sys.time()))
print("Data normalization has been finished")
print(head(train))