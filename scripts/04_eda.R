library(ggplot2)
library(dplyr)
library(plotly)
library(reshape2)
library(corrplot)
library(wordcloud)
library(tm)

#' Plot ATS Score Distribution
#' Generates a density and histogram plot of ATS scores.
#'
#' @param data Dataframe. Training/testing data.
#' @param interactive Logical. Return Plotly chart if TRUE.
#' @return ggplot or plotly object.
#' @export
plot_ats_distribution <- function(data, interactive = TRUE) {
  p <- ggplot(data, aes(x = ats_score)) +
    geom_histogram(aes(y = ..density..), binwidth = 5, fill = "#1F77B4", color = "#FFFFFF", alpha = 0.7) +
    geom_density(color = "#FF7F0E", size = 1.2) +
    theme_minimal(base_size = 12) +
    labs(
      title = "Distribution of ATS Scores",
      x = "ATS Score (0 - 100)",
      y = "Density"
    ) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      panel.grid.minor = element_blank()
    )
  
  if (interactive) {
    return(ggplotly(p))
  }
  return(p)
}

#' Plot Experience vs ATS Score
#' Generates a scatter plot of experience vs ATS score.
#'
#' @param data Dataframe.
#' @param interactive Logical.
#' @return ggplot or plotly.
#' @export
plot_experience_vs_ats <- function(data, interactive = TRUE) {
  p <- ggplot(data, aes(x = experience_years, y = ats_score)) +
    geom_point(aes(text = paste("Role:", target_role)), color = "#2CA02C", alpha = 0.6, size = 2.5) +
    geom_smooth(method = "lm", color = "#D62728", se = TRUE) +
    theme_minimal(base_size = 12) +
    labs(
      title = "Experience vs ATS Score",
      x = "Years of Experience",
      y = "ATS Score"
    ) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5))
  
  if (interactive) {
    return(ggplotly(p))
  }
  return(p)
}

#' Plot Education Level vs ATS Score
#' Generates a box and violin plot of education vs ATS score.
#'
#' @param data Dataframe.
#' @param interactive Logical.
#' @return ggplot or plotly.
#' @export
plot_education_vs_ats <- function(data, interactive = TRUE) {
  # Order education levels logically
  edu_order <- c("None", "HighSchool", "Associate", "Bachelor", "Master", "PhD")
  data_filtered <- data %>%
    mutate(education_level = factor(education_level, levels = edu_order)) %>%
    filter(!is.na(education_level))
  
  p <- ggplot(data_filtered, aes(x = education_level, y = ats_score, fill = education_level)) +
    geom_violin(alpha = 0.4, color = NA) +
    geom_boxplot(width = 0.2, color = "#2F2F2F", alpha = 0.7) +
    scale_fill_brewer(palette = "Blues") +
    theme_minimal(base_size = 12) +
    labs(
      title = "Education Level vs ATS Score",
      x = "Education Level",
      y = "ATS Score"
    ) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      legend.position = "none"
    )
  
  if (interactive) {
    return(ggplotly(p))
  }
  return(p)
}

#' Plot Correlation Heatmap
#' Generates a correlation heatmap of numeric features.
#'
#' @param data Dataframe.
#' @return ggplot or plotly object.
#' @export
plot_correlation_heatmap <- function(data) {
  # Select numeric columns
  numeric_cols <- data %>%
    select(where(is.numeric))
  
  # Compute correlation matrix
  cor_matrix <- cor(numeric_cols, use = "pairwise.complete.obs")
  
  # Melt the matrix
  melted_cor <- melt(cor_matrix)
  
  p <- ggplot(melted_cor, aes(x = Var1, y = Var2, fill = value)) +
    geom_tile(color = "white") +
    scale_fill_gradient2(low = "#4A90E2", high = "#E84A5F", mid = "#FFFFFF", 
                         midpoint = 0, limit = c(-1, 1), space = "Lab", 
                         name="Correlation") +
    theme_minimal() + 
    theme(
      axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      panel.grid.major = element_blank(),
      plot.title = element_text(face = "bold", hjust = 0.5)
    ) +
    coord_fixed() +
    labs(title = "Feature Correlation Matrix")
  
  return(ggplotly(p))
}

#' Plot Feature Importance
#'
#' @param rf_model randomForest object.
#' @param interactive Logical.
#' @return ggplot or plotly.
#' @export
plot_feature_importance <- function(rf_model, interactive = TRUE) {
  importance_matrix <- randomForest::importance(rf_model)
  imp_df <- data.frame(
    Feature = rownames(importance_matrix),
    Importance = importance_matrix[, 1]
  ) %>%
    arrange(desc(Importance))
  
  # Make names human readable
  imp_df$Feature <- gsub("_", " ", imp_df$Feature)
  imp_df$Feature <- stringr::str_to_title(imp_df$Feature)
  
  # Order factor levels for plotting
  imp_df$Feature <- factor(imp_df$Feature, levels = rev(imp_df$Feature))
  
  p <- ggplot(imp_df, aes(x = Importance, y = Feature, fill = Importance)) +
    geom_bar(stat = "identity") +
    scale_fill_gradient(low = "#ABC4FF", high = "#3B82F6") +
    theme_minimal(base_size = 12) +
    labs(
      title = "Random Forest Feature Importance (MDI)",
      x = "Mean Decrease in Impurity",
      y = "Feature"
    ) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      legend.position = "none"
    )
  
  if (interactive) {
    return(ggplotly(p))
  }
  return(p)
}

#' Plot Skill Frequencies
#' Bar plot of skill matches in the resumes database.
#'
#' @param skills_vector Character vector of all detected skills.
#' @param top_n Integer. Number of top skills to display.
#' @param interactive Logical.
#' @return ggplot or plotly.
#' @export
plot_skills_frequency <- function(skills_vector, top_n = 15, interactive = TRUE) {
  if (length(skills_vector) == 0) {
    # Return empty plot
    p <- ggplot() + 
      annotate("text", x = 1, y = 1, label = "No skills data available") + 
      theme_void()
    return(p)
  }
  
  skills_df <- data.frame(Skill = skills_vector) %>%
    group_by(Skill) %>%
    summarise(Frequency = n(), .groups = 'drop') %>%
    arrange(desc(Frequency)) %>%
    head(top_n)
  
  skills_df$Skill <- factor(skills_df$Skill, levels = rev(skills_df$Skill))
  
  p <- ggplot(skills_df, aes(x = Frequency, y = Skill, fill = Frequency)) +
    geom_bar(stat = "identity", fill = "#805AD5", alpha = 0.8) +
    theme_minimal(base_size = 12) +
    labs(
      title = paste("Top", top_n, "Skills Requested/Detected"),
      x = "Frequency",
      y = "Skill Name"
    ) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      legend.position = "none"
    )
  
  if (interactive) {
    return(ggplotly(p))
  }
  return(p)
}

#' Generate Word Cloud
#' Generates a static wordcloud and saves it to a temporary file.
#'
#' @param text Character. Raw text.
#' @param stopwords_list Character vector.
#' @return Nothing. Generates plot in active graphics device.
#' @export
generate_resume_wordcloud <- function(text, stopwords_list = NULL) {
  if (is.null(text) || nchar(trimws(text)) == 0) return(NULL)
  
  tokens <- tokenize_text(text)
  tokens_clean <- remove_stopwords_from_tokens(tokens, stopwords_list)
  
  if (length(tokens_clean) == 0) return(NULL)
  
  word_freq <- data.frame(word = tokens_clean) %>%
    group_by(word) %>%
    summarise(freq = n(), .groups = 'drop') %>%
    arrange(desc(freq))
  
  # Generate wordcloud
  wordcloud::wordcloud(
    words = word_freq$word,
    freq = word_freq$freq,
    min.freq = 2,
    max.words = 80,
    random.order = FALSE,
    colors = brewer.pal(8, "Dark2")
  )
}
