# Kaggle-San-Francisco-Crime
This is my solution for the Kaggle challenge named "San Francisco Crime Classification" in R. The idea is to predict the type of commited crime by given time, adress and other information. The given train data consists of  878,000+ observations and test data has 884,000+ observations. So the optimizaton of code plays significat role

The project is constructed in next way. There are numbered scripts, starting from "0-Load-and-convert.R" and finishing with "6-Use-LogReg.R". The main Idea is to run them one by one and read the console output to get a feedback of what is happening.

Description of scripts
<ul>
  <li>"0-Load-and-convert.R". The script loads training and testing sets from dataset folder. It process them in a way that all strings will be replaced by numbers. The special field Data which showed information like "2015-05-13 23:53:00" was expanded to 4 different numerical fields - Year, Month, Day and Time where Time is a number of minutes in a Day   </li>
  <li>"1-Normalize.R". The script normalizes all features as all of them are numerical. They are scaled from 0 to 1</li>
  <li>"2-Apply-PCA.R". The script alalyses the features and provides a dimension reduction. It makes all plots important for explanation and visualisation</li>
  <li>"3-Use-KNN.R". The script uses built-in KNN model to make a predictions of test labels based on training samples</li>
  <li>"4-Use-SVM.R". The script uses built-in SVM model to train based on training dataset and then predict test labels</li>
  <li>"5-Use-DNN.R". The script uses TensorFlow 2 fully connected neural network to train based on training dataset and then predict test labels</li>
  <li>"6-Use-LogReg.R". The script shows implementation of a logistic regression based on pure math and theory. The model trains based on training dataset and then predicts test labels</li>
</ul>

