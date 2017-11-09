setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(feather)
library(slam)
library(text2vec)
library(stringi)
library(dplyr)
library(tokenizers)

data <- read_feather('C:/Users/Samuel/OneDrive/UvA/S01P02/Machine Learning for Econometrics/Project/Data/ph_ads_payment_indicator.feather')

sample <- data %>%
  mutate(rnd = runif(dim(data)[1], min = 0, max = 1)) %>%
  filter(rnd < 0.05)

