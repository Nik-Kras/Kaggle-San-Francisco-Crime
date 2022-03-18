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

source("0-Load-and-convert.R")

source("1-Normalize.R")

source("2-Apply-PCA.R")


# Ml technique takes a lot of time
# Comment if it is not needed
# Better use only one of scripts 3-6 and comment others
source("3-Use-KNN.R")

source("4-Use-SVM.R")

source("5-Use-DNN.R")

source("6-Use-LogReg.R")