library(stringr)
library(dplyr)
library(tidytext)
library(tm)
library(text2vec)

#' Count Syllables in a Word
#' Simple English syllable counting heuristic.
#'
#' @param word Character. A single word.
#' @return Integer. Syllable count.
count_syllables_word <- function(word) {
  word <- tolower(word)
  # Strip punctuation
  word <- gsub("[[:punct:]]", "", word)
  if (nchar(word) <= 3) return(1)
  
  # Remove endings like "es", "ed", and silent "e"
  word <- gsub("es$", "", word)
  word <- gsub("ed$", "", word)
  word <- gsub("e$", "", word)
  
  # Count vowel groups (consecutive vowels count as one)
  vowels <- gregexpr("[aeiouy]+", word)[[1]]
  count <- length(vowels)
  
  if (vowels[1] == -1) count <- 0
  if (count == 0) count <- 1
  return(count)
}

#' Count Syllables in Text
#'
#' @param words Character vector. Words in the text.
#' @return Integer. Total syllables.
count_syllables_text <- function(words) {
  if (length(words) == 0) return(0)
  sum(sapply(words, count_syllables_word))
}

#' Flesch-Kincaid Readability Ease Score
#' Calculates readability score: 206.835 - 1.015 * (words/sentences) - 84.6 * (syllables/words)
#'
#' @param text Character. Input raw text.
#' @return Numeric. Readability score.
calculate_readability <- function(text) {
  if (is.null(text) || length(text) == 0 || is.na(text) || nchar(trimws(text)) == 0) return(0)
  
  # Count sentences: split by period, exclamation, or question mark
  sentences <- unlist(strsplit(text, "[.!?]+"))
  sentences <- sentences[trimws(sentences) != ""]
  num_sentences <- max(length(sentences), 1)
  
  # Tokenize to get words
  words <- tokenize_text(text)
  num_words <- length(words)
  
  if (num_words == 0) return(0)
  
  # Count syllables
  num_syllables <- count_syllables_text(words)
  
  # Calculate score
  score <- 206.835 - 1.015 * (num_words / num_sentences) - 84.6 * (num_syllables / num_words)
  
  # Clamp score between 0 and 100
  score <- max(0, min(100, score))
  return(score)
}

#' Extract Years of Experience
#' Searches for date ranges and years of experience patterns.
#'
#' @param text Character. Raw resume text.
#' @return Numeric. Years of experience.
#' @export
extract_experience_years <- function(text) {
  if (is.null(text) || length(text) == 0 || is.na(text)) return(0)
  
  text_clean <- tolower(text)
  
  # Look for explicit "X years of experience" pattern
  exp_pattern <- "(\\d+\\.?\\d*)\\s*(?:\\+)?\\s*(?:years?|yrs?)(?:\\s+of)?\\s+experience"
  exp_matches <- str_match_all(text_clean, exp_pattern)[[1]]
  
  exp_from_phrase <- 0
  if (nrow(exp_matches) > 0) {
    # Extract the first matching experience number
    exp_from_phrase <- max(as.numeric(exp_matches[, 2]), na.rm = TRUE)
  }
  
  # Look for date ranges: e.g., 2018 - 2022, 2015-Present, May 2019 to Aug 2021
  # Matches: YYYY - YYYY or YYYY - present/current
  current_year <- as.numeric(format(Sys.Date(), "%Y"))
  if (is.na(current_year) || current_year < 2026) current_year <- 2026  # Fallback to current system metadata year
  
  year_range_pattern <- "(19\\d{2}|20\\d{2})\\s*[-–to]\\s*(19\\d{2}|20\\d{2}|present|current|now)"
  range_matches <- str_match_all(text_clean, year_range_pattern)[[1]]
  
  exp_from_ranges <- 0
  if (nrow(range_matches) > 0) {
    durations <- sapply(1:nrow(range_matches), function(i) {
      start_year <- as.numeric(range_matches[i, 2])
      end_str <- range_matches[i, 3]
      
      end_year <- if (end_str %in% c("present", "current", "now")) {
        current_year
      } else {
        as.numeric(end_str)
      }
      
      # Basic sanity check
      if (!is.na(start_year) && !is.na(end_year) && end_year >= start_year && start_year > 1980) {
        return(end_year - start_year)
      }
      return(0)
    })
    exp_from_ranges <- sum(durations, na.rm = TRUE)
  }
  
  # Take the maximum of phrase-extracted experience and range-calculated experience
  total_exp <- max(exp_from_phrase, exp_from_ranges, na.rm = TRUE)
  
  # Cap experience to a reasonable maximum (e.g. 40 years)
  total_exp <- min(total_exp, 40)
  
  return(total_exp)
}

#' Extract Education Level
#'
#' @param text Character. Raw resume text.
#' @return Character. Highest education level found.
#' @export
extract_education_level <- function(text) {
  if (is.null(text) || length(text) == 0 || is.na(text)) return("None")
  
  text_clean <- tolower(text)
  
  # Map keywords to education levels
  edu_levels <- list(
    PhD = c("phd", "ph.d", "doctor of philosophy", "doctorate"),
    Master = c("master", "m.s.", "m.tech", "mba", "m.c.a.", "msc", "postgraduate"),
    Bachelor = c("bachelor", "b.s.", "b.tech", "b.e.", "b.c.a.", "bsc", "undergraduate"),
    Associate = c("associate degree", "diploma", "associate's"),
    HighSchool = c("high school", "secondary school", "matriculation", "12th")
  )
  
  highest_level <- "None"
  level_hierarchy <- c("None", "HighSchool", "Associate", "Bachelor", "Master", "PhD")
  max_rank <- 1
  
  for (level in names(edu_levels)) {
    keywords <- edu_levels[[level]]
    # Create regex pattern for exact word boundary or standard abbreviations
    pattern <- paste0("\\b(", paste(keywords, collapse = "|"), ")\\b")
    # Clean pattern to be regex safe (e.g. escaping periods)
    pattern <- gsub("\\.", "\\\\.", pattern)
    
    if (str_detect(text_clean, pattern)) {
      rank <- which(level_hierarchy == level)
      if (rank > max_rank) {
        max_rank <- rank
        highest_level <- level
      }
    }
  }
  
  return(highest_level)
}

#' Count Projects
#' Identifies projects by finding headers or project bullet points.
#'
#' @param text Character. Raw resume text.
#' @return Integer. Projects count.
#' @export
extract_projects_count <- function(text) {
  if (is.null(text) || length(text) == 0 || is.na(text)) return(0)
  
  text_clean <- tolower(text)
  
  # Method 1: Count occurrences of project headings
  project_headings <- c("project description", "academic projects", "key projects", "selected projects", "personal projects")
  heading_pattern <- paste0("(", paste(project_headings, collapse = "|"), ")")
  heading_count <- length(gregexpr(heading_pattern, text_clean)[[1]])
  if (heading_count == 1 && gregexpr(heading_pattern, text_clean)[[1]][1] == -1) heading_count <- 0
  
  # Method 2: Search for bullets/sections starting with words commonly describing a project
  # e.g., "project name:", "designed a", "developed a", "spearheaded the development"
  project_indicators <- c("project name", "developed a", "designed a", "built a", "created a", "spearheaded the", "github.com/[^\\s/]+/[^\\s/]+")
  indicator_pattern <- paste(project_indicators, collapse = "|")
  indicator_matches <- gregexpr(indicator_pattern, text_clean)[[1]]
  indicator_count <- length(indicator_matches)
  if (indicator_count == 1 && indicator_matches[1] == -1) indicator_count <- 0
  
  # Combine counts and ensure a reasonable return value (usually between 0 and 10)
  total_projects <- max(heading_count * 2, indicator_count)
  
  # If 0 but we find "project" mentioned multiple times, estimate project count
  if (total_projects == 0) {
    project_mentions <- length(gregexpr("\\bproject\\b", text_clean)[[1]])
    if (project_mentions > 0 && gregexpr("\\bproject\\b", text_clean)[[1]][1] != -1) {
      total_projects <- ceiling(project_mentions / 3)
    }
  }
  
  # Clamp between 0 and 12
  return(min(max(total_projects, 0), 12))
}

#' Count Action Verbs
#' Counts occurrences of action verbs in the text.
#'
#' @param text Character. Input text.
#' @return Integer. Action verbs count.
#' @export
count_action_verbs <- function(text) {
  if (is.null(text) || length(text) == 0 || is.na(text)) return(0)
  
  action_verbs <- c(
    "implemented", "developed", "designed", "created", "spearheaded",
    "managed", "led", "directed", "supervised", "improved", "increased",
    "decreased", "saved", "solved", "analyzed", "built", "programmed",
    "coordinated", "executed", "formulated", "generated", "monitored",
    "optimized", "produced", "streamlined", "transformed", "tested",
    "collaborated", "facilitated", "negotiated", "strengthened", "engineered"
  )
  
  text_clean <- tolower(text)
  tokens <- tokenize_text(text_clean)
  
  count <- sum(tokens %in% action_verbs)
  return(count)
}

#' Extract Skills and Certifications counts
#' Matches resume words with predefined lists.
#'
#' @param text Character. Cleaned resume text.
#' @param skills_df Dataframe. Skills database containing 'skill' and 'category'.
#' @param certs_df Dataframe. Certifications database containing 'certification'.
#' @return List. Skill counts by category.
#' @export
extract_skills_and_certs <- function(text, skills_df, certs_df) {
  text_clean <- tolower(text)
  
  # Standardize skill names in dataframe for regex search
  skills_df <- skills_df %>%
    mutate(skill_lower = tolower(skill))
  
  # Match skills using exact boundaries where possible
  matched_skills <- sapply(skills_df$skill_lower, function(sk) {
    # If the skill is an abbreviation (like R or C++ or C#), we need special word boundaries
    if (sk == "r") {
      # Match R with surrounding space or punctuation, but not inside words
      pattern <- "\\b[rR]\\b"
    } else if (sk == "c++") {
      pattern <- "\\bc\\+\\+"
    } else if (sk == "c#") {
      pattern <- "\\bc\\#"
    } else if (nchar(sk) <= 3) {
      pattern <- paste0("\\b", sk, "\\b")
    } else {
      pattern <- paste0("\\b", sk, "\\b")
    }
    
    # Clean regex patterns
    pattern <- gsub("([+])", "\\\\\\1", pattern)
    
    str_detect(text_clean, pattern)
  })
  
  detected_skills_df <- skills_df[matched_skills, ]
  
  # Match certifications
  certs_df <- certs_df %>%
    mutate(cert_lower = tolower(certification),
           code_lower = tolower(code))
  
  matched_certs <- sapply(1:nrow(certs_df), function(i) {
    c_name <- certs_df$cert_lower[i]
    c_code <- certs_df$code_lower[i]
    
    # Match by name or code
    name_pat <- paste0("\\b", c_name, "\\b")
    name_pat <- gsub("([+()\\-])", "\\\\\\1", name_pat)
    
    code_pat <- paste0("\\b", c_code, "\\b")
    code_pat <- gsub("([+()\\-])", "\\\\\\1", code_pat)
    
    str_detect(text_clean, name_pat) || (!is.na(c_code) && c_code != "" && str_detect(text_clean, code_pat))
  })
  
  detected_certs <- certs_df$certification[matched_certs]
  
  # Summarize skills by category
  skill_summary <- detected_skills_df %>%
    group_by(category) %>%
    summarise(count = n(), .groups = 'drop')
  
  # Create a named list of skill counts by category
  skill_counts <- list(
    Programming = 0, Cloud = 0, Databases = 0, WebFrameworks = 0, 
    DevOps = 0, MachineLearning = 0, DataAnalytics = 0, 
    Mobile = 0, Testing = 0, Security = 0, SoftSkills = 0, Agile = 0
  )
  
  for (cat in skill_summary$category) {
    if (cat %in% names(skill_counts)) {
      skill_counts[[cat]] <- skill_summary$count[skill_summary$category == cat]
    }
  }
  
  # Total tech skills vs soft skills
  total_tech <- detected_skills_df %>% 
    filter(type == "Technical") %>% 
    nrow()
  
  total_soft <- detected_skills_df %>% 
    filter(type == "Soft") %>% 
    nrow()
  
  return(list(
    skills_list = detected_skills_df$skill,
    certs_list = detected_certs,
    skills_count_by_category = skill_counts,
    tech_skills_count = total_tech,
    soft_skills_count = total_soft,
    certs_count = length(detected_certs)
  ))
}

#' Calculate Cosine Similarity using text2vec
#'
#' @param resume_text Character. Full raw resume text.
#' @param jd_text Character. Full raw job description text.
#' @param custom_stopwords Character vector. Optional custom stopwords.
#' @return Numeric. Cosine similarity.
#' @export
calculate_cosine_similarity <- function(resume_text, jd_text, custom_stopwords = NULL) {
  if (is.null(resume_text) || nchar(trimws(resume_text)) == 0) return(0)
  if (is.null(jd_text) || nchar(trimws(jd_text)) == 0) return(0)
  
  # Preprocess texts
  prep_res <- preprocess_for_similarity(resume_text, custom_stopwords)
  prep_jd <- preprocess_for_similarity(jd_text, custom_stopwords)
  
  if (nchar(prep_res) == 0 || nchar(prep_jd) == 0) return(0)
  
  # Tokenization
  it_res <- itoken(prep_res, tokenizer = word_tokenizer)
  it_jd <- itoken(prep_jd, tokenizer = word_tokenizer)
  
  # Create vocabulary from both documents
  vocab <- create_vocabulary(itoken(c(prep_res, prep_jd), tokenizer = word_tokenizer))
  
  if (nrow(vocab) == 0) return(0)
  
  vectorizer <- vocab_vectorizer(vocab)
  
  # Document Term Matrix
  dtm_res <- create_dtm(it_res, vectorizer)
  dtm_jd <- create_dtm(it_jd, vectorizer)
  
  # Transform via TF-IDF
  tfidf <- TfIdf$new()
  dtm_res_tfidf <- tfidf$fit_transform(dtm_res)
  dtm_jd_tfidf <- tfidf$transform(dtm_jd)
  
  # Compute Cosine Similarity
  cos_sim <- sim2(dtm_res_tfidf, dtm_jd_tfidf, method = "cosine", norm = "l2")[1, 1]
  
  if (is.nan(cos_sim) || is.na(cos_sim)) {
    return(0)
  }
  
  return(as.numeric(cos_sim))
}

#' Keyword Match Percentage
#'
#' @param resume_text Character. Raw resume text.
#' @param jd_text Character. Raw job description.
#' @param custom_stopwords Character vector. List of stopwords.
#' @return List. keyword match %, matched keywords, missing keywords.
#' @export
calculate_keyword_match <- function(resume_text, jd_text, custom_stopwords = NULL) {
  # Clean and tokenize job description
  jd_tokens <- tokenize_text(jd_text)
  jd_clean_tokens <- remove_stopwords_from_tokens(jd_tokens, custom_stopwords)
  
  # We focus on unique keywords from the job description
  jd_keywords <- unique(jd_clean_tokens)
  
  # Clean and tokenize resume
  res_tokens <- tokenize_text(resume_text)
  res_clean_tokens <- remove_stopwords_from_tokens(res_tokens, custom_stopwords)
  res_unique_words <- unique(res_clean_tokens)
  
  if (length(jd_keywords) == 0) {
    return(list(match_percent = 0, matched = character(0), missing = character(0)))
  }
  
  # Identify matched and missing keywords
  matched_keywords <- intersect(jd_keywords, res_unique_words)
  missing_keywords <- setdiff(jd_keywords, res_unique_words)
  
  match_percent <- (length(matched_keywords) / length(jd_keywords)) * 100
  
  return(list(
    match_percent = match_percent,
    matched = matched_keywords,
    missing = missing_keywords
  ))
}

#' Generate ATS Score based on Feature Engineering
#' Generates a weighted composite score between 0 and 100.
#'
#' @param features List. Calculated features.
#' @return Numeric. ATS Score.
#' @export
generate_ats_score <- function(features) {
  # Weights:
  # 1. Cosine Similarity (TF-IDF): 30%
  # 2. Keyword Match Percentage: 20%
  # 3. Technical Skills Match: 15%
  # 4. Years of Experience (vs industry baseline): 10%
  # 5. Education Level matching: 10%
  # 6. Projects Count: 5%
  # 7. Certifications Count: 5%
  # 8. Readability & Formatting (Action verbs, sentence structure): 5%
  
  # 1. Cosine similarity score (0 to 100)
  cos_score <- features$cosine_similarity * 100
  
  # 2. Keyword match score (0 to 100)
  kw_score <- features$keyword_match_percent
  
  # 3. Technical skills count score (cap at 15 skills as 100%)
  skills_score <- min((features$tech_skills_count / 15) * 100, 100)
  
  # 4. Experience score (cap at 8 years as 100%)
  exp_score <- min((features$experience_years / 8) * 100, 100)
  
  # 5. Education score (PhD=100, Master=90, Bachelor=75, Associate=50, HighSchool=30, None=0)
  edu_scores <- c(PhD = 100, Master = 90, Bachelor = 75, Associate = 50, HighSchool = 30, None = 0)
  edu_level <- features$education_level
  edu_score <- ifelse(edu_level %in% names(edu_scores), edu_scores[edu_level], 0)
  
  # 6. Projects score (cap at 4 projects as 100%)
  proj_score <- min((features$projects_count / 4) * 100, 100)
  
  # 7. Certifications score (cap at 3 certifications as 100%)
  cert_score <- min((features$certs_count / 3) * 100, 100)
  
  # 8. Readability & Formatting (Flesch-Kincaid: optimal range is 30 to 70 for professional docs)
  # Give full points if readability is between 30 and 75, discount if too simple or too complex.
  read_val <- features$readability_score
  read_score <- if (read_val >= 30 && read_val <= 75) {
    100
  } else if (read_val > 75) {
    100 - (read_val - 75) * 1.5  # Penurize for overly simplified text
  } else {
    100 - (30 - read_val) * 2    # Penurize for overly dense/hard to read text
  }
  read_score <- max(0, read_score)
  
  # Also count action verbs (cap at 10 as 100%)
  action_score <- min((features$action_verbs_count / 10) * 100, 100)
  formatting_score <- (read_score + action_score) / 2
  
  # Calculate Weighted Score
  ats_score <- (cos_score * 0.30) + 
                (kw_score * 0.20) + 
                (skills_score * 0.15) + 
                (exp_score * 0.10) + 
                (edu_score * 0.10) + 
                (proj_score * 0.05) + 
                (cert_score * 0.05) + 
                (formatting_score * 0.05)
  
  # Clamp score between 0 and 100
  ats_score <- max(0, min(100, ats_score))
  
  return(round(ats_score, 1))
}
