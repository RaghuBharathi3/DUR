library(stringr)
library(tm)

#' Clean Raw Text
#' Normalizes casing, removes special characters, but preserves structure.
#' Good for regex matching (e.g. years of experience, education levels).
#'
#' @param text Character. Raw text.
#' @return Character. Cleaned text.
#' @export
clean_text_raw <- function(text) {
  if (is.null(text) || length(text) == 0 || is.na(text)) return("")
  
  # Standardize line endings and convert to lower case
  text_clean <- tolower(text)
  
  # Replace non-breaking spaces and tabs with standard space
  text_clean <- gsub("[\\r\\t\\v\\f]", " ", text_clean)
  
  # Remove email addresses and URLs to avoid bias in matching
  text_clean <- gsub("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}", "", text_clean)
  text_clean <- gsub("http[s]?://\\S+|www\\.\\S+", "", text_clean)
  
  # Replace multiple newlines/spaces with a single newline or space
  text_clean <- gsub(" +", " ", text_clean)
  text_clean <- gsub("\\n+", "\n", text_clean)
  
  return(text_clean)
}

#' Tokenize Text
#' Converts a text string into a vector of words, removing punctuation and numbers.
#'
#' @param text Character. Input text.
#' @return Character vector. Individual words.
#' @export
tokenize_text <- function(text) {
  if (is.null(text) || length(text) == 0 || is.na(text)) return(character(0))
  
  # Lowercase
  t_low <- tolower(text)
  
  # Replace punctuation and numbers with space
  t_nopunct <- gsub("[[:punct:]]", " ", t_low)
  t_nonum <- gsub("[[:digit:]]", " ", t_nopunct)
  
  # Split by whitespace
  tokens <- unlist(strsplit(t_nonum, "\\s+"))
  
  # Remove empty tokens
  tokens <- tokens[tokens != ""]
  
  return(tokens)
}

#' Remove Stopwords
#' Removes common stopwords from a token vector.
#'
#' @param tokens Character vector. Tokenized text.
#' @param custom_stopwords Character vector. Optional custom stopwords.
#' @return Character vector. Tokens without stopwords.
#' @export
remove_stopwords_from_tokens <- function(tokens, custom_stopwords = NULL) {
  if (length(tokens) == 0) return(character(0))
  
  # Default stopwords from tm package
  default_stop <- tm::stopwords("en")
  
  # Combine with custom stopwords if provided
  all_stop <- unique(c(default_stop, custom_stopwords))
  
  # Filter tokens
  clean_tokens <- tokens[!(tokens %in% all_stop)]
  
  return(clean_tokens)
}

#' Stem Tokens
#' Apply porter stemming to a vector of tokens.
#'
#' @param tokens Character vector.
#' @return Character vector. Stemmed tokens.
#' @export
stem_tokens <- function(tokens) {
  if (length(tokens) == 0) return(character(0))
  
  # Apply stemmer from tm / SnowballC
  stemmed <- tm::stemDocument(tokens)
  return(stemmed)
}

#' Full Preprocessing Pipeline for Vectorization
#' Combines cleaning, tokenization, stopword removal, and stemming.
#' Returns a single string with words separated by spaces.
#'
#' @param text Character. Input raw text.
#' @param custom_stopwords Character vector. Optional custom stopwords.
#' @return Character. Preprocessed, space-separated string.
#' @export
preprocess_for_similarity <- function(text, custom_stopwords = NULL) {
  tokens <- tokenize_text(text)
  tokens_no_stop <- remove_stopwords_from_tokens(tokens, custom_stopwords)
  tokens_stemmed <- stem_tokens(tokens_no_stop)
  
  return(paste(tokens_stemmed, collapse = " "))
}
