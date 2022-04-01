
# https://dzone.com/articles/a-comprehensive-guide-to-random-forest-in-r

install.packages("caret", dependencies = TRUE)
install.packages("randomForest")

library(caret)
library(randomForest)

data("iris")

# To say explisitly that I want a classification model
iris$Species <- factor(iris$Species)

set.seed(51)

model <- train(Species ~ ., 
               data = iris, 
               method = 'rf',
               trControl = trainControl(method = 'cv', # Use cross-validation
                                        number = 5)    # Use 5 folds for cross-validation
               )

print(model)

# MDSplot(rf, train$Species)
               
               