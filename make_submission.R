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

library(mltools)

make_submit <- function(labesl_predict = knn.pred,
                        category_names = ListCategories,
                        name = "KNN_submission.csv",
                        path = "data/output/Submit/"){
  
  submit           <- one_hot(as.data.table(labesl_predict))
  colnames(submit) <- category_names
  
  Id = data.frame(0:(nrow(submit)-1))
  colnames(Id) <- "Id"
  submit <- cbind(Id, submit)
  
  write.csv(submit, file=paste(path, pname, sep=""), row.names=FALSE)
}