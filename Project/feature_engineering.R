setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(feather)
library(slam)
library(text2vec)
library(stringr)
library(dplyr)
library(tokenizers)
library(tidyverse)
library(tm)
library(profvis)
library(MASS)

sample <- 0.01
data <- read_feather('C:/Users/Samuel/Documents/ML_Naspers/Data/ph_ads_payment_indicator.feather')
data <- data %>% mutate(rnd = runif(dim(data)[1], min = 0, max = 1)) %>% filter(rnd < sample)
data <- data %>% filter(price < 8e+08 | is.na(price))



