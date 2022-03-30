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

# Convert strings to numbers ---------------------------------
print("Converting strings to numbers...")
cat(sprintf("Time: %s\n", Sys.time()))

key_names <- unique(train$DayOfWeek)
for (i in 1:length(key_names))
{
  train$DayOfWeek[train$DayOfWeek == key_names[i]]  <- i
  test$DayOfWeek [test$DayOfWeek  == key_names[i]]  <- i
}

key_names <- unique(train$PdDistrict)
for (i in 1:length(key_names))
{
  train$PdDistrict[train$PdDistrict == key_names[i]]  <- i
  test$PdDistrict [test$PdDistrict  == key_names[i]]  <- i
}

rm(i, key_names)

cat(sprintf("Time: %s\n", Sys.time()))
print("Converting strings to numbers has been finished.")
print(head(train))


# Delete unnecessary features ---------------------------------
# They are not present in testing data
# Reorder for comfort
print("Deleting features and reordering...")
cat(sprintf("Time: %s\n", Sys.time()))

train[, c("Descript","Resolution","Address"):=NULL]
setcolorder(train, c("Dates", 
                     "DayOfWeek", 
                     "PdDistrict",
                     "X", "Y", 
                     "Category"))     
test[, c("Address", "Id"):=NULL]
setcolorder(test, c("Dates", 
                    "DayOfWeek", 
                    "PdDistrict",
                    "X", "Y"))
print("Comment: In future the Adress may be not deleted, but used")

cat(sprintf("Time: %s\n", Sys.time()))
print("Deleting features and reordering is finished")
print("The training data currently looks like: ")
print(head(train))

# Convert strings to numbers ---------------------------------
print("Converting strings to numbers...")
cat(sprintf("Time: %s\n", Sys.time()))

key_names <- unique(train$DayOfWeek)
for (i in 1:length(key_names))
{
  train$DayOfWeek[train$DayOfWeek == key_names[i]]  <- i
  test$DayOfWeek [test$DayOfWeek  == key_names[i]]  <- i
}

key_names <- unique(train$PdDistrict)
for (i in 1:length(key_names))
{
  train$PdDistrict[train$PdDistrict == key_names[i]]  <- i
  test$PdDistrict [test$PdDistrict  == key_names[i]]  <- i
}

rm(i, key_names)

cat(sprintf("Time: %s\n", Sys.time()))
print("Converting strings to numbers has been finished.")
print(head(train))

# Delete unnecessary features ---------------------------------
# They are not present in testing data
# Reorder for comfort
print("Deleting features and reordering...")
cat(sprintf("Time: %s\n", Sys.time()))

train[, c("Descript","Resolution","Address"):=NULL]
setcolorder(train, c("Dates", 
                     "DayOfWeek", 
                     "PdDistrict",
                     "X", "Y", 
                     "Category"))     
test[, c("Address", "Id"):=NULL]
setcolorder(test, c("Dates", 
                    "DayOfWeek", 
                    "PdDistrict",
                    "X", "Y"))
print("Comment: In future the Adress may be not deleted, but used")

cat(sprintf("Time: %s\n", Sys.time()))
print("Deleting features and reordering is finished")
print("The training data currently looks like: ")
print(head(train))


# Normalization -----------------------------------------------
print("Data normalization...")
cat(sprintf("Time: %s\n", Sys.time()))


# Instead of LOOP: prc_n <- as.data.frame(lapply(prc[2:9], normalize))
# normalize - is a function that normalizes

for (i in c(1:8))
{
  train[,i] <- rescale(as.numeric(array(unlist(train[,..i]))))
  test[,i]  <- rescale(as.numeric(array(unlist(test[,..i]))))
}

rm(i)

cat(sprintf("Time: %s\n", Sys.time()))
print("Data normalization has been finished")
print(head(train))