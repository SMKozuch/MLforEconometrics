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


sample_size <- 0.005

data <- read_feather('C:/Users/Samuel/Documents/ML_Naspers/Data/ph_ads_payment_indicator.feather')

sample <- data %>%
  mutate(rnd = runif(dim(data)[1], min = 0, max = 1)) %>%
  filter(rnd < sample_size)

rm(data)

prep_fun <- function(x){
  #the preprocessing function, which will transfer all inputs to
  #lower, replace 1 and 2 letter words, replace white spaces and digits 
  
  x <- tolower(x)
  x <- str_replace_all(x, '[:digit:]', ' ')
  x <- str_replace_all(x, '\\b\\w{1,2}\\b',' ')
  x <- str_replace_all(x, '[:punct:]', ' ' )
  x <- str_replace_all(x, '\\s+', ' ')
  return(x)
}

tok_fun <- word_tokenizer

it_sample <- itoken(sample$description, 
                    preprocessor = prep_fun,
                    tokenizer = tok_fun,
                    ids = sample$id)

vocab <- create_vocabulary(it_sample, 
                           stopwords = stopwords('en'))

vocab

pruned_vocab <- prune_vocabulary(vocab,
                                 term_count_min = 10, 
                                 doc_proportion_max = 0.7,
                                 doc_proportion_min = 0.001)


vectorizer <- vocab_vectorizer(pruned_vocab)
t1 <- Sys.time()
dtm_train <- create_dtm(it_sample, vectorizer)
print(difftime(Sys.time(), t1, units = 'sec'))

dim(dtm_train)
dtm_train <- dtm_train[row_sums(dtm_train) > 0, ]

sort(col_sums(dtm_train), decreasing = T)[1:10]

rm(sample, vocab, pruned_vocab)

#TF-IDF
# dtm_train[, 'rs'] <- row_sums(dtm_train)
# 
tf_dtm_train <- sweep(dtm_train, 1, row_sums(dtm_train), '/')
tf <- apply(tf_dtm_train, 2, mean)
rm(tf_dtm_train)

idf <- log2(dim(dtm_train)[1] / (col_sums(dtm_train)))

tf_idf <- tf * idf
summary(tf_idf)




dtm_train <- dtm_train[, tf_idf > median(tf_idf) + 1e-4]


library(wordcloud)
freq = data.frame(freqterms=sort(colSums(as.matrix(dtm_train)), decreasing=TRUE))

wordcloud(rownames(freq), freq[,1], max.words=50, colors=brewer.pal(3, "Dark2"))
