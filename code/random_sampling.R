#Kaggle Dataset - Random Sampling 
#24th July 2025 

#WARNING: The following command will clear RStudio environment
#Clearing RStudio 
rm(list=ls())

#Importing and calling packages and libraries 
library(readr)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(lubridate)

#Loading full Bollywood dataset

#PLEASE CHANGE FILE PATH ACCORDINGLY 
#INPUT FILE: bollywood_full_1950-2019.csv 

getwd()
setwd("/Users/rishabhbijani/Desktop/ra_app")
full_bollywood_list <- read_csv("bollywood_full_1950-2019.csv")

#Inspecting this dataset 
str(full_bollywood_list)

#Converting year_of_release into integer 
#Filtering the dataset for movies released post 2010
full_bollywood_list <- full_bollywood_list %>% 
  mutate(year_of_release_int = as.integer(year_of_release)) %>% 
  filter(year_of_release_int >2010)

#Checking for duplicates 
length(unique(full_bollywood_list$imdb_id))

#No of unique imdb_id = 816
#No of rows = 819
#Therefore, checking for and removing duplicates 
table(duplicated(full_bollywood_list$imdb_id))
full_bollywood_unique <- full_bollywood_list[!duplicated(full_bollywood_list$imdb_id), ]

#Random Sampling 
set.seed(05042004)
movies_randomly_sampled <- full_bollywood_unique[sample(nrow(full_bollywood_unique), 100), ]

#Cleaning random sample 
colnames(movies_randomly_sampled)
movies_randomly_sampled <- movies_randomly_sampled %>% 
  select(-c(title_y, 
            year_of_release)) %>% 
  rename("title_kaggle" = "title_x", 
         "story_kaggle" = "story", 
         "summary_kaggle" = "summary", 
         "tagline_kaggle" = "tagline")

#Checking structure of the dataset 
str(movies_randomly_sampled)
colnames(movies_randomly_sampled)
summary(movies_randomly_sampled)

#Saving the random sample as a csv 
write_csv(movies_randomly_sampled, "movies_random_sample.csv")



