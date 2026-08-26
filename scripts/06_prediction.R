library(dplyr)
library(readr)
library(randomForest)
library(e1071)

# Source dependencies
source("scripts/01_extract_resume.R")
source("scripts/02_clean_text.R")
source("scripts/03_feature_engineering.R")

#' Predict ATS compatibility for a new resume
#'
#' @param resume_path Character. Path to the candidate's resume PDF.
#' @param jd_text Character. Target job description.
#' @param target_title Character. Title of target role.
#' @return List. Predictions, features, and recommendations.
#' @export
predict_resume_ats <- function(resume_path, jd_text, target_title = "Technical Specialist") {
  model_path <- "models/randomForest_model.rds"
  
  # Auto-train if model doesn't exist (Self-healing bootstrap)
  if (!file.exists(model_path)) {
    message("Model file not found. Running training pipeline to build the models...")
    source("scripts/05_model_training.R")
    train_ats_models()
  }
  
  # Load model package
  model_pkg <- readRDS(model_path)
  
  # Extract text from resume PDF
  resume_text <- extract_text_from_pdf(resume_path)
  clean_res <- clean_text_raw(resume_text)
  clean_jd <- clean_text_raw(jd_text)
  
  # Load dependencies
  skills_df <- read_csv("data/skills.csv", show_col_types = FALSE)
  certs_df <- read_csv("data/certifications.csv", show_col_types = FALSE)
  stopwords_df <- read_csv("data/stopwords.csv", show_col_types = FALSE)
  custom_stopwords <- stopwords_df$word
  
  # Calculate basic text metrics
  word_count <- length(tokenize_text(clean_res))
  char_count <- nchar(clean_res)
  sentence_count <- max(length(unlist(strsplit(clean_res, "[.!?]+"))), 1)
  unique_words <- length(unique(tokenize_text(clean_res)))
  unique_ratio <- unique_words / max(word_count, 1)
  avg_sentence_len <- word_count / sentence_count
  readability <- calculate_readability(clean_res)
  
  # Extract Skills and Certifications
  sc_features <- extract_skills_and_certs(clean_res, skills_df, certs_df)
  
  # Extract experience, education, projects, verbs
  exp <- extract_experience_years(clean_res)
  edu <- extract_education_level(clean_res)
  proj <- extract_projects_count(clean_res)
  verbs <- count_action_verbs(clean_res)
  
  # Calculate match scores
  cos_sim <- calculate_cosine_similarity(resume_text, jd_text, custom_stopwords)
  kw_info <- calculate_keyword_match(resume_text, jd_text, custom_stopwords)
  
  # Skill counts by category
  sc_cats <- sc_features$skills_count_by_category
  
  # Build features dataframe for model predictions
  new_data <- data.frame(
    char_count = char_count,
    word_count = word_count,
    sentence_count = sentence_count,
    readability_score = readability,
    tech_skills_count = sc_features$tech_skills_count,
    soft_skills_count = sc_features$soft_skills_count,
    certs_count = sc_features$certs_count,
    experience_years = exp,
    education_level = factor(edu, levels = c("None", "HighSchool", "Associate", "Bachelor", "Master", "PhD")),
    projects_count = proj,
    action_verbs_count = verbs,
    cosine_similarity = cos_sim,
    keyword_match_percent = kw_info$match_percent,
    unique_word_ratio = unique_ratio,
    avg_sentence_length = avg_sentence_len,
    prog_skills_count = sc_cats$Programming,
    cloud_skills_count = sc_cats$Cloud,
    db_skills_count = sc_cats$Databases,
    ai_skills_count = sc_cats$MachineLearning,
    analytics_skills_count = sc_cats$DataAnalytics,
    stringsAsFactors = FALSE
  )
  
  # Predict ATS Score (Regression Model)
  pred_ats <- predict(model_pkg$regression_model, new_data)
  pred_ats <- max(0, min(100, as.numeric(pred_ats)))
  
  # Predict Pass/Fail Class and Probabilities (Classifier Model)
  # SVM requires probability = TRUE to predict probabilities, but if there's any factor issue, fallback to random forest
  pred_prob <- tryCatch({
    pred_prob_svm <- predict(model_pkg$classification_model, new_data, probability = TRUE)
    prob_matrix <- attr(pred_prob_svm, "probabilities")
    prob_matrix[1, "Pass"]
  }, error = function(e) {
    # Fallback probability calculation from regression score
    # e.g., 70 is threshold, sigmoidal mapping
    1 / (1 + exp(-0.15 * (pred_ats - 70)))
  })
  
  pred_prob <- max(0, min(1, as.numeric(pred_prob)))
  
  # Get missing skills by category
  # We extract words from the job description that represent skills, and find which ones are missing
  jd_skills <- extract_skills_from_jd(clean_jd, skills_df)
  missing_skills <- setdiff(jd_skills, sc_features$skills_list)
  
  return(list(
    ats_score = round(pred_ats, 1),
    pass_probability = round(pred_prob * 100, 1),
    features = new_data,
    detected_skills = sc_features$skills_list,
    detected_certs = sc_features$certs_list,
    missing_skills = missing_skills,
    matched_keywords = kw_info$matched,
    missing_keywords = kw_info$missing,
    model_metrics = list(
      reg = model_pkg$reg_metrics,
      clf = model_pkg$clf_metrics
    )
  ))
}

#' Extract Skills from Job Description
#'
#' @param clean_jd Character. Cleaned job description text.
#' @param skills_df Dataframe. Skills database.
#' @return Character vector. Skills detected in the JD.
extract_skills_from_jd <- function(clean_jd, skills_df) {
  skills_df <- skills_df %>%
    mutate(skill_lower = tolower(skill))
  
  matched <- sapply(skills_df$skill_lower, function(sk) {
    if (sk == "r") {
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
    pattern <- gsub("([+])", "\\\\\\1", pattern)
    str_detect(clean_jd, pattern)
  })
  
  return(skills_df$skill[matched])
}
