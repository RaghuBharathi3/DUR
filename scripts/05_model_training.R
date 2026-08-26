library(dplyr)
library(readr)
library(caret)
library(randomForest)
library(rpart)
library(e1071)
library(text2vec)

# Source dependencies
source("scripts/02_clean_text.R")
source("scripts/03_feature_engineering.R")

#' Download Public Datasets
#' Downloads the UpdatedResumeDataSet.csv and a job description CSV from GitHub.
#' If it fails, falls back to generating high-quality synthetic datasets.
#'
#' @return List. Paths to the downloaded/generated files.
download_datasets <- function() {
  data_dir <- "data"
  if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)
  
  resume_path <- file.path(data_dir, "UpdatedResumeDataSet.csv")
  jd_path <- file.path(data_dir, "job_descriptions.csv")
  
  # URLs
  resume_url <- "https://raw.githubusercontent.com/611noorsaeed/Resume-Screening-App/main/UpdatedResumeDataSet.csv"
  # Clean job description CSV url from a public repository
  jd_url <- "https://raw.githubusercontent.com/Justicea83/tmu-mrp/main/datasets/job_descriptions.csv"
  
  # Download Resume Dataset
  if (!file.exists(resume_path)) {
    message("Downloading public resume dataset...")
    tryCatch({
      download.file(resume_url, resume_path, mode = "wb", quiet = TRUE)
      message("Resume dataset downloaded successfully.")
    }, error = function(e) {
      warning("Failed to download resume dataset. Creating synthetic resumes...")
      create_synthetic_resumes(resume_path)
    })
  }
  
  # Download Job Description Dataset (check size > 0 to catch 404 silent failures)
  if (!file.exists(jd_path) || file.info(jd_path)$size == 0) {
    if (file.exists(jd_path)) file.remove(jd_path)  # remove 0-byte file
    message("Downloading public job description dataset...")
    tryCatch({
      download.file(jd_url, jd_path, mode = "wb", quiet = TRUE)
      if (!file.exists(jd_path) || file.info(jd_path)$size == 0) {
        warning("Downloaded JD file is empty. Creating synthetic job descriptions...")
        if (file.exists(jd_path)) file.remove(jd_path)
        create_synthetic_jds(jd_path)
      } else {
        message("Job description dataset downloaded successfully.")
      }
    }, error = function(e) {
      warning("Failed to download job descriptions. Creating synthetic job descriptions...")
      create_synthetic_jds(jd_path)
    })
  }
  
  return(list(resumes = resume_path, jds = jd_path))
}

#' Create Synthetic Resumes (Fallback)
create_synthetic_resumes <- function(output_path) {
  categories <- c("Data Science", "Web Designing", "Java Developer", "DevOps Engineer", "HR", "Advocate")
  resumes_list <- list(
    "Data Science" = "John Doe. Data Scientist with 5 years of experience. Expert in Python, R, machine learning, deep learning, NLP, SQL. Developed an AI-powered resume matching system with PyTorch and TensorFlow. Bachelor of Technology (B.Tech) in Computer Science. Certified AWS Certified Machine Learning Specialist. Solved complex data problems, managed predictive modeling projects, designed data pipelines, and optimized cloud architectures.",
    "Web Designing" = "Jane Smith. Web Designer with 3 years of experience. Proficient in HTML, CSS, JavaScript, React, and Figma. Designed multiple responsive websites, improved user interface speed, and collaborated with marketing teams. Associate degree in Web Design. Certified Salesforce Certified Administrator.",
    "Java Developer" = "David Lee. Java Developer with 6 years of experience in Spring Boot, Hibernate, microservices, and PostgreSQL. Developed scalable web applications, optimized database queries, and implemented REST APIs. Master of Computer Applications (MCA). Certified Oracle Certified Professional Java SE Developer.",
    "DevOps Engineer" = "Alex Johnson. DevOps Engineer with 4 years of experience. Specialized in Docker, Kubernetes, Jenkins, Terraform, Ansible, and AWS. Built CI/CD pipelines, automated cloud infrastructure deployment, and monitored cloud environments using Grafana and Prometheus. Bachelor of Science. Certified AWS Certified DevOps Engineer - Professional.",
    "HR" = "Sarah Connor. HR Manager with 8 years of experience. Skilled in talent acquisition, employee relations, recruitment, and onboarding. Led a team of recruiters, improved hiring processes, and managed employee engagement programs. MBA in Human Resources. Excel, communication, and leadership skills.",
    "Advocate" = "Michael Brown. Legal Counsel and Advocate with 7 years of experience. Expert in corporate law, contract drafting, and dispute resolution. Represented clients in high-stakes litigation, drafted contract templates, and negotiated terms. PhD in Law. Critical thinking, negotiation, and legal writing."
  )
  
  # Generate 120 synthetic resumes (20 for each category)
  set.seed(42)
  records <- data.frame()
  for (i in 1:120) {
    cat <- sample(categories, 1)
    base_text <- resumes_list[[cat]]
    # Add some random variations (extra years of experience, random skills, random projects)
    years <- sample(1:15, 1)
    text <- gsub("5 years|3 years|6 years|4 years|8 years|7 years", paste(years, "years"), base_text)
    
    # Add a random project
    proj_num <- sample(1:5, 1)
    text <- paste(text, sprintf("Completed %d client projects including system design and integration.", proj_num))
    
    records <- rbind(records, data.frame(Category = cat, Resume = text, stringsAsFactors = FALSE))
  }
  
  write_csv(records, output_path)
  message("Synthetic resumes database created.")
}

#' Create Synthetic Job Descriptions (Fallback)
create_synthetic_jds <- function(output_path) {
  jds <- data.frame(
    job_title = c("Data Scientist", "Web Designer", "Java Developer", "DevOps Engineer", "HR Manager", "Legal Counsel"),
    job_description = c(
      "We are looking for a Data Scientist with 4+ years of experience. Must be expert in Python, R, SQL, machine learning, deep learning, NLP, and cloud computing (AWS/GCP). Responsibilities include developing predictive models, analyzing data, designing data pipelines, and implementing AI algorithms using TensorFlow or PyTorch. Bachelor or Master degree in Computer Science or related fields.",
      "Seeking a creative Web Designer with 2+ years of experience. Must be proficient in HTML, CSS, JavaScript, React, and Figma. Responsibilities include creating responsive web layouts, designing user interfaces, and collaborating with cross-functional teams.",
      "Looking for a Java Developer with 5+ years of experience in Java, Spring Boot, microservices, PostgreSQL, and REST APIs. Responsibilities include building scalable backend applications, optimizing database performance, and writing unit tests.",
      "We are hiring a DevOps Engineer with 3+ years of experience in Docker, Kubernetes, Jenkins, Terraform, AWS, and Linux. Duties include building CI/CD pipelines, automating cloud infrastructure, and monitoring server health using Prometheus.",
      "Seeking an HR Manager with 5+ years of experience in recruitment, talent acquisition, onboarding, and employee relations. Must have excellent communication, leadership, and project management skills.",
      "Looking for a Legal Counsel/Advocate with 6+ years of experience. Must be expert in corporate law, contract negotiation, drafting contract agreements, and dispute resolution."
    ),
    stringsAsFactors = FALSE
  )
  
  write_csv(jds, output_path)
  message("Synthetic job descriptions database created.")
}

#' Parse Job Description Dataset
#' Maps job description text to the closest standard category.
parse_jds <- function(jds_df) {
  # Standardize column names
  col_names <- colnames(jds_df)
  desc_col <- col_names[grepl("desc|post|text", col_names, ignore.case = TRUE)][1]
  title_col <- col_names[grepl("title|role|name", col_names, ignore.case = TRUE)][1]
  
  if (is.na(desc_col)) {
    # If no description column, create one or rename
    jds_df$job_description <- jds_df[[1]]
    desc_col <- "job_description"
  } else {
    jds_df$job_description <- jds_df[[desc_col]]
  }
  
  if (is.na(title_col)) {
    jds_df$job_title <- "Technical Specialist"
  } else {
    jds_df$job_title <- jds_df[[title_col]]
  }
  
  # Clean columns
  jds_cleaned <- jds_df %>%
    mutate(
      job_title = trimws(job_title),
      job_description = trimws(job_description)
    ) %>%
    filter(!is.na(job_description) & job_description != "")
  
  return(jds_cleaned)
}

#' Train Models
#'
#' @export
train_ats_models <- function() {
  message("--- Starting Model Training Pipeline ---")
  
  # 1. Download/Load Data
  paths <- download_datasets()
  
  res_df <- read_csv(paths$resumes, show_col_types = FALSE)
  jds_df <- read_csv(paths$jds, show_col_types = FALSE)
  jds_df <- parse_jds(jds_df)
  
  # Limit dataset size for feature extraction efficiency
  # We select up to 100 representative samples to build a high-quality model quickly
  set.seed(42)
  res_sample <- res_df %>% sample_n(min(nrow(res_df), 120))
  
  # Load skill and cert databases
  skills_df <- read_csv("data/skills.csv", show_col_types = FALSE)
  certs_df <- read_csv("data/certifications.csv", show_col_types = FALSE)
  stopwords_df <- read_csv("data/stopwords.csv", show_col_types = FALSE)
  custom_stopwords <- stopwords_df$word
  
  # 2. Extract Features
  message("Extracting features from resumes against matched/unmatched jobs...")
  
  dataset_list <- list()
  row_count <- 1
  
  for (i in 1:nrow(res_sample)) {
    res_text <- res_sample$Resume[i]
    res_cat <- res_sample$Category[i]
    
    # Select a job description
    # To get realistic training data, 50% of the time pair it with a MATCHING job,
    # and 50% of the time pair it with a random UNMATCHING job.
    is_matching <- runif(1) > 0.5
    
    jd_row <- NULL
    if (is_matching) {
      # Try to find a matching job description
      jd_row <- jds_df %>% 
        filter(grepl(res_cat, job_title, ignore.case = TRUE) | grepl(res_cat, job_description, ignore.case = TRUE)) %>%
        safe_slice(1)
    }
    
    # Fallback to random JD
    if (is.null(jd_row) || nrow(jd_row) == 0) {
      jd_row <- jds_df[sample(1:nrow(jds_df), 1), ]
    }
    
    jd_text <- jd_row$job_description[1]
    jd_title <- jd_row$job_title[1]
    
    # Clean text raw
    clean_res <- clean_text_raw(res_text)
    clean_jd <- clean_text_raw(jd_text)
    
    # Readability, counts
    readability <- calculate_readability(clean_res)
    word_count <- length(tokenize_text(clean_res))
    char_count <- nchar(clean_res)
    sentence_count <- max(length(unlist(strsplit(clean_res, "[.!?]+"))), 1)
    unique_words <- length(unique(tokenize_text(clean_res)))
    unique_ratio <- unique_words / max(word_count, 1)
    avg_sentence_len <- word_count / sentence_count
    
    # Skills and Certs
    sc_features <- extract_skills_and_certs(clean_res, skills_df, certs_df)
    
    # Experience, Education, Projects
    exp <- extract_experience_years(clean_res)
    edu <- extract_education_level(clean_res)
    proj <- extract_projects_count(clean_res)
    verbs <- count_action_verbs(clean_res)
    
    # Similarity
    cos_sim <- calculate_cosine_similarity(res_text, jd_text, custom_stopwords)
    kw_info <- calculate_keyword_match(res_text, jd_text, custom_stopwords)
    
    # Categorize skills counts
    sc_cats <- sc_features$skills_count_by_category
    
    # Combine features into a single observation
    features <- list(
      character_count = char_count,
      word_count = word_count,
      sentence_count = sentence_count,
      readability_score = readability,
      tech_skills_count = sc_features$tech_skills_count,
      soft_skills_count = sc_features$soft_skills_count,
      certs_count = sc_features$certs_count,
      experience_years = exp,
      education_level = edu,
      projects_count = proj,
      action_verbs_count = verbs,
      cosine_similarity = cos_sim,
      keyword_match_percent = kw_info$match_percent,
      unique_word_ratio = unique_ratio,
      avg_sentence_length = avg_sentence_len,
      
      # Tech stacks
      prog_skills_count = sc_cats$Programming,
      cloud_skills_count = sc_cats$Cloud,
      db_skills_count = sc_cats$Databases,
      ai_skills_count = sc_cats$MachineLearning,
      analytics_skills_count = sc_cats$DataAnalytics
    )
    
    # Compute the ground truth target: ATS score (0-100) using feature engineering formula
    ats_score <- generate_ats_score(features)
    
    # Add a tiny bit of random noise (between -2 and +2) to make models learn relationship
    ats_score <- max(0, min(100, ats_score + rnorm(1, 0, 1.5)))
    
    # Target 2: Pass ATS (Pass = 1, Fail = 0)
    pass_ats <- ifelse(ats_score >= 70, "Pass", "Fail")
    
    obs <- data.frame(
      char_count = char_count,
      word_count = word_count,
      sentence_count = sentence_count,
      readability_score = readability,
      tech_skills_count = sc_features$tech_skills_count,
      soft_skills_count = sc_features$soft_skills_count,
      certs_count = sc_features$certs_count,
      experience_years = exp,
      education_level = edu,
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
      target_role = jd_title,
      ats_score = ats_score,
      pass_ats = factor(pass_ats, levels = c("Fail", "Pass")),
      stringsAsFactors = FALSE
    )
    
    dataset_list[[row_count]] <- obs
    row_count <- row_count + 1
  }
  
  training_data <- bind_rows(dataset_list)
  
  # Ensure both Pass and Fail classes exist (inject synthetic extremes if needed)
  n_pass <- sum(training_data$pass_ats == "Pass")
  n_fail <- sum(training_data$pass_ats == "Fail")
  message(sprintf("Class distribution before balancing: Pass=%d, Fail=%d", n_pass, n_fail))
  
  if (n_pass == 0 || n_fail == 0) {
    message("Injecting balanced synthetic records to ensure both classes exist...")
    # Create 30 forced-Pass rows (high-quality resumes)
    pass_rows <- training_data[1:min(10, nrow(training_data)), ]
    pass_rows$ats_score <- runif(nrow(pass_rows), 75, 95)
    pass_rows$cosine_similarity <- runif(nrow(pass_rows), 0.6, 0.9)
    pass_rows$keyword_match_percent <- runif(nrow(pass_rows), 60, 90)
    pass_rows$tech_skills_count <- sample(8:15, nrow(pass_rows), replace = TRUE)
    pass_rows$experience_years <- sample(4:10, nrow(pass_rows), replace = TRUE)
    pass_rows$pass_ats <- factor("Pass", levels = c("Fail", "Pass"))
    # Create 30 forced-Fail rows (weak resumes)
    fail_rows <- training_data[1:min(10, nrow(training_data)), ]
    fail_rows$ats_score <- runif(nrow(fail_rows), 20, 55)
    fail_rows$cosine_similarity <- runif(nrow(fail_rows), 0.0, 0.3)
    fail_rows$keyword_match_percent <- runif(nrow(fail_rows), 5, 30)
    fail_rows$tech_skills_count <- sample(0:3, nrow(fail_rows), replace = TRUE)
    fail_rows$experience_years <- sample(0:2, nrow(fail_rows), replace = TRUE)
    fail_rows$pass_ats <- factor("Fail", levels = c("Fail", "Pass"))
    training_data <- bind_rows(training_data, pass_rows, fail_rows)
  }
  
  # Factorize categorical variables
  training_data$education_level <- factor(training_data$education_level, 
                                          levels = c("None", "HighSchool", "Associate", "Bachelor", "Master", "PhD"))
  training_data$pass_ats <- factor(training_data$pass_ats, levels = c("Fail", "Pass"))
  
  # 3. Model Training
  message("Splitting dataset into 80/20 train/test...")
  set.seed(42)
  train_index <- createDataPartition(training_data$ats_score, p = 0.8, list = FALSE)
  train_set <- training_data[train_index, ]
  test_set <- training_data[-train_index, ]
  
  # Define modeling formulas
  formula_reg <- ats_score ~ word_count + readability_score + tech_skills_count + 
                 soft_skills_count + certs_count + experience_years + education_level + 
                 projects_count + action_verbs_count + cosine_similarity + keyword_match_percent + 
                 prog_skills_count + cloud_skills_count + db_skills_count + ai_skills_count + analytics_skills_count
                 
  formula_clf <- pass_ats ~ word_count + readability_score + tech_skills_count + 
                 soft_skills_count + certs_count + experience_years + education_level + 
                 projects_count + action_verbs_count + cosine_similarity + keyword_match_percent + 
                 prog_skills_count + cloud_skills_count + db_skills_count + ai_skills_count + analytics_skills_count
  
  message("Training Regression Models (ATS Score Prediction)...")
  # 1. Linear Regression
  lm_model <- lm(formula_reg, data = train_set)
  
  # 2. Decision Tree
  dt_model <- rpart(formula_reg, data = train_set)
  
  # 3. Random Forest
  rf_model <- randomForest(formula_reg, data = train_set, ntree = 100, importance = TRUE)
  
  # 4. Support Vector Machine (Regression)
  svm_model <- svm(formula_reg, data = train_set)
  
  message("Training Classification Models (Pass/Fail Prediction)...")
  # Ensure train_set has both classes
  train_set$pass_ats <- factor(train_set$pass_ats, levels = c("Fail", "Pass"))
  test_set$pass_ats  <- factor(test_set$pass_ats,  levels = c("Fail", "Pass"))
  
  if (length(unique(train_set$pass_ats)) < 2) {
    # Force both classes by resampling
    pass_idx <- which(training_data$pass_ats == "Pass")
    fail_idx <- which(training_data$pass_ats == "Fail")
    balanced_idx <- c(sample(pass_idx, min(length(pass_idx), 30), replace = TRUE),
                      sample(fail_idx, min(length(fail_idx), 30), replace = TRUE))
    train_set <- training_data[balanced_idx, ]
    train_set$pass_ats <- factor(train_set$pass_ats, levels = c("Fail", "Pass"))
    train_set$education_level <- factor(train_set$education_level,
      levels = c("None", "HighSchool", "Associate", "Bachelor", "Master", "PhD"))
  }
  
  # 1. Random Forest Classifier
  rf_clf <- randomForest(formula_clf, data = train_set, ntree = 100)
  
  # 2. Naive Bayes Classifier
  nb_clf <- naiveBayes(formula_clf, data = train_set)
  
  # 3. SVM Classifier
  svm_clf <- svm(formula_clf, data = train_set, probability = TRUE)
  
  # 4. Evaluate Regression Models
  message("Evaluating regression models...")
  eval_reg <- function(model, name) {
    preds <- predict(model, test_set)
    rmse <- sqrt(mean((test_set$ats_score - preds)^2))
    mae <- mean(abs(test_set$ats_score - preds))
    r2 <- cor(test_set$ats_score, preds)^2
    return(data.frame(Model = name, RMSE = rmse, MAE = mae, R_Squared = r2, stringsAsFactors = FALSE))
  }
  
  metrics_reg <- bind_rows(
    eval_reg(lm_model, "Linear Regression"),
    eval_reg(dt_model, "Decision Tree"),
    eval_reg(rf_model, "Random Forest"),
    eval_reg(svm_model, "Support Vector Machine")
  )
  
  print(metrics_reg)
  
  # Evaluate Classification Models
  message("Evaluating classification models...")
  eval_clf <- function(model, name) {
    preds <- predict(model, test_set)
    
    # Handle factor vs class names
    if (is.matrix(preds) || is.list(preds)) {
      # Some models return probabilities or lists
      preds <- factor(preds, levels = c("Fail", "Pass"))
    }
    
    cm <- confusionMatrix(preds, test_set$pass_ats)
    acc <- cm$overall["Accuracy"]
    sens <- cm$byClass["Sensitivity"]  # Recall
    spec <- cm$byClass["Specificity"]
    prec <- cm$byClass["Precision"]
    f1 <- cm$byClass["F1"]
    
    # Handle NA precision/recall
    if (is.na(prec)) prec <- 0
    if (is.na(f1)) f1 <- 0
    
    return(data.frame(
      Model = name, 
      Accuracy = acc, 
      Precision = prec, 
      Recall = sens, 
      F1_Score = f1, 
      stringsAsFactors = FALSE
    ))
  }
  
  # Custom predictions for Naive Bayes and SVM to match class factors
  preds_nb <- predict(nb_clf, test_set)
  preds_svm <- predict(svm_clf, test_set)
  preds_rf <- predict(rf_clf, test_set)
  
  metrics_clf <- bind_rows(
    eval_clf(rf_clf, "Random Forest Classifier"),
    data.frame(Model = "Naive Bayes", 
               Accuracy = mean(preds_nb == test_set$pass_ats), 
               Precision = pos_metric(preds_nb, test_set$pass_ats, "Precision"), 
               Recall = pos_metric(preds_nb, test_set$pass_ats, "Recall"),
               F1_Score = pos_metric(preds_nb, test_set$pass_ats, "F1"),
               stringsAsFactors = FALSE),
    data.frame(Model = "Support Vector Machine", 
               Accuracy = mean(preds_svm == test_set$pass_ats), 
               Precision = pos_metric(preds_svm, test_set$pass_ats, "Precision"), 
               Recall = pos_metric(preds_svm, test_set$pass_ats, "Recall"),
               F1_Score = pos_metric(preds_svm, test_set$pass_ats, "F1"),
               stringsAsFactors = FALSE)
  )
  
  print(metrics_clf)
  
  # Select best model based on R-squared/RMSE
  best_idx <- which.min(metrics_reg$RMSE)
  best_model_name <- metrics_reg$Model[best_idx]
  message("Best Regression Model: ", best_model_name)
  
  # 5. Export Model Package
  model_dir <- "models"
  if (!dir.exists(model_dir)) dir.create(model_dir, recursive = TRUE)
  
  # Package models, evaluations, training data summaries for use in the dashboard
  model_package <- list(
    regression_model = rf_model,       # Random Forest regression model
    classification_model = svm_clf,   # SVM classifier with probabilities
    reg_metrics = metrics_reg,
    clf_metrics = metrics_clf,
    feature_importance = randomForest::importance(rf_model),
    training_summary = list(
      n_samples = nrow(training_data),
      avg_ats_score = mean(training_data$ats_score),
      pass_rate = mean(training_data$pass_ats == "Pass")
    ),
    sample_data = training_data %>% head(20)
  )
  
  saveRDS(model_package, file.path(model_dir, "randomForest_model.rds"))
  message("Model package saved to models/randomForest_model.rds successfully.")
}

# Helper to slice dataframe safely
safe_slice <- function(df, n) {
  if (is.null(df) || nrow(df) == 0) return(NULL)
  return(df[1:min(nrow(df), n), ])
}

# Helper to calculate classification metrics manually
pos_metric <- function(preds, actuals, metric) {
  tbl <- table(factor(preds, levels = c("Fail", "Pass")), factor(actuals, levels = c("Fail", "Pass")))
  
  # TN: tbl[1,1], FN: tbl[1,2]
  # FP: tbl[2,1], TP: tbl[2,2]
  tp <- tbl[2, 2]
  fp <- tbl[2, 1]
  fn <- tbl[1, 2]
  tn <- tbl[1, 1]
  
  prec <- tp / max(tp + fp, 1)
  rec <- tp / max(tp + fn, 1)
  
  if (metric == "Precision") return(prec)
  if (metric == "Recall") return(rec)
  if (metric == "F1") return(2 * (prec * rec) / max(prec + rec, 0.001))
  return(0)
}
