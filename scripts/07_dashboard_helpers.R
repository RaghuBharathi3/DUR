library(ggplot2)
library(dplyr)

#' Generate Resume Improvement Suggestions
#'
#' @param predictions List. Results from predict_resume_ats.
#' @return Character vector. List of actionable suggestions.
#' @export
generate_improvement_suggestions <- function(predictions) {
  feats <- predictions$features
  missing_skills <- predictions$missing_skills
  missing_kws <- predictions$missing_keywords
  
  suggestions <- c()
  
  # 1. Readability feedback
  read_val <- feats$readability_score
  if (read_val < 30) {
    suggestions <- c(suggestions, "Readability Score is very low (dense/complex text). Simplify sentences, use shorter words, and avoid overly academic jargon.")
  } else if (read_val > 75) {
    suggestions <- c(suggestions, "Readability Score is very high (overly simple text). Increase technical depth and use professional industry terminology.")
  }
  
  # 2. Word count feedback
  w_count <- feats$word_count
  if (w_count < 300) {
    suggestions <- c(suggestions, "Resume is too short (less than 300 words). Add more details about your project contributions, roles, and technical achievements.")
  } else if (w_count > 900) {
    suggestions <- c(suggestions, "Resume is too long (over 900 words). Condense your bullet points. Keep description focused on high-impact outcomes.")
  }
  
  # 3. Action Verbs feedback
  verb_count <- feats$action_verbs_count
  if (verb_count < 6) {
    suggestions <- c(suggestions, "Low action verb usage. Start resume bullets with strong active verbs (e.g., 'Spearheaded', 'Optimized', 'Engineered') instead of passive statements like 'Responsible for'.")
  }
  
  # 4. Projects feedback
  proj_count <- feats$projects_count
  if (proj_count < 2) {
    suggestions <- c(suggestions, "Few projects detected. Add 2-3 detailed project sections detailing the business problem, technology stack, and your specific contribution.")
  }
  
  # 5. Certifications feedback
  cert_count <- feats$certs_count
  if (cert_count == 0) {
    suggestions <- c(suggestions, "No cloud or professional certifications detected. Consider acquiring certifications (e.g. AWS Cloud Practitioner, CCNA, or Salesforce Administrator) to validate your skills.")
  }
  
  # 6. Keyword Match feedback
  match_pct <- feats$keyword_match_percent
  if (match_pct < 40) {
    suggestions <- c(suggestions, paste("Low job description keyword matching (", round(match_pct, 1), "%). Incorporate matching terms from the job posting into your experience bullets.", sep = ""))
  }
  
  # 7. Missing Technical Skills feedback
  if (length(missing_skills) > 0) {
    top_missing <- head(missing_skills, 5)
    suggestions <- c(suggestions, paste("Add missing high-priority skills found in the job description: ", paste(top_missing, collapse = ", "), ".", sep = ""))
  }
  
  # 8. Missing Keywords feedback
  if (length(missing_kws) > 0) {
    top_missing_kws <- head(missing_kws, 8)
    suggestions <- c(suggestions, paste("Incorporate these missing keywords to improve search relevance: ", paste(top_missing_kws, collapse = ", "), ".", sep = ""))
  }
  
  # Fallback if everything is perfect
  if (length(suggestions) == 0) {
    suggestions <- c("Excellent work! Your resume is highly optimized for this role. Consider minor visual formatting tweaks and verifying that your contact information is up to date.")
  }
  
  return(suggestions)
}

#' Get Role Benchmarks and Recommendations
#'
#' @param target_role Character. Selected job title.
#' @return List. Stats, average salaries, and key required skills.
#' @export
get_role_benchmarks <- function(target_role) {
  roles <- list(
    "Data Scientist" = list(
      salary = "$125,000",
      demand = "Very High (+36% growth)",
      skills = c("Python", "R", "SQL", "Machine Learning", "Deep Learning", "TensorFlow/PyTorch", "Tableau/PowerBI"),
      certs = c("AWS Certified Machine Learning", "Google Cloud Professional Data Engineer", "Microsoft Azure Data Scientist"),
      description = "Analyzes complex datasets to extract insights, build predictive models, and guide business strategy."
    ),
    "Web Designer" = list(
      salary = "$80,000",
      demand = "High (+16% growth)",
      skills = c("HTML", "CSS", "JavaScript", "React", "Figma", "UI/UX Design", "Responsive Design"),
      certs = c("Salesforce Platform App Builder", "Google UX Design Professional Certificate"),
      description = "Creates visually engaging and highly responsive user interfaces and websites that optimize user experience."
    ),
    "Java Developer" = list(
      salary = "$110,000",
      demand = "High (+22% growth)",
      skills = c("Java", "Spring Boot", "Microservices", "PostgreSQL", "REST APIs", "JUnit", "Hibernate"),
      certs = c("Oracle Certified Professional: Java SE Developer", "Spring Certified Professional"),
      description = "Builds robust, scalable backend services, API endpoints, and enterprise integrations using the Java ecosystem."
    ),
    "DevOps Engineer" = list(
      salary = "$135,000",
      demand = "Very High (+24% growth)",
      skills = c("Docker", "Kubernetes", "Jenkins", "Terraform", "Ansible", "AWS/Azure", "Linux/Bash"),
      certs = c("AWS Certified DevOps Engineer - Professional", "Certified Kubernetes Administrator (CKA)", "HashiCorp Certified: Terraform Associate"),
      description = "Automates code deployment, manages infrastructure as code, and maintains CI/CD pipeline health and monitoring."
    ),
    "HR Manager" = list(
      salary = "$95,000",
      demand = "Medium (+7% growth)",
      skills = c("Recruitment", "Talent Acquisition", "Employee Relations", "Onboarding", "Excel", "Communication", "Leadership"),
      certs = c("SHRM Certified Professional (SHRM-CP)", "PHR - Professional in Human Resources"),
      description = "Manages corporate hiring pipelines, implements onboarding guidelines, handles employee benefits, and leads recruitment teams."
    ),
    "Legal Counsel" = list(
      salary = "$140,000",
      demand = "Medium (+10% growth)",
      skills = c("Corporate Law", "Contract Drafting", "Legal Research", "Dispute Resolution", "Negotiation", "Risk Assessment"),
      certs = c("Bar Certification", "CIPP/E - Certified Information Privacy Professional"),
      description = "Drafts legal contracts, ensures corporate compliance, handles litigation risk assessments, and conducts negotiations."
    )
  )
  
  # Default match if not found
  matched_role <- NULL
  for (r_name in names(roles)) {
    if (grepl(r_name, target_role, ignore.case = TRUE) || grepl(target_role, r_name, ignore.case = TRUE)) {
      matched_role <- roles[[r_name]]
      break
    }
  }
  
  if (is.null(matched_role)) {
    # Fallback default benchmarks
    matched_role <- list(
      salary = "$100,000",
      demand = "High",
      skills = c("Programming", "Cloud", "Databases", "Version Control", "Problem Solving"),
      certs = c("AWS Cloud Practitioner", "CompTIA Security+"),
      description = "Technical professional contributing to business objectives through specialized skill execution."
    )
  }
  
  return(matched_role)
}

#' Generate PDF Evaluation Report
#' Draws a beautiful PDF document utilizing R's graphics engine.
#'
#' @param candidate_name Character. Candidate name.
#' @param target_role Character. Target job.
#' @param predictions List. Predictions from predict_resume_ats.
#' @param filepath Character. Destination file path.
#' @export
generate_resume_pdf_report <- function(candidate_name, target_role, predictions, filepath) {
  # Setup directory
  dir_path <- dirname(filepath)
  if (!dir.exists(dir_path)) dir.create(dir_path, recursive = TRUE)
  
  # Open PDF graphics device
  pdf(filepath, width = 8.5, height = 11)
  
  # Set margins and fonts
  par(mar = c(3, 3, 3, 3))
  
  # Page 1 Background & Title
  plot.new()
  plot.window(xlim = c(0, 100), ylim = c(0, 100))
  
  # Header band (Dark Navy Blue)
  rect(0, 85, 100, 100, col = "#1F2937", border = NA)
  
  # Title text
  text(50, 94, "RESUME ATS FIT ASSESSMENT REPORT", col = "white", cex = 1.8, font = 2, adj = 0.5)
  text(50, 89, paste("Target Role:", target_role), col = "#F3F4F6", cex = 1.1, font = 3, adj = 0.5)
  
  # Candidate details
  text(10, 80, paste("Candidate Name:", candidate_name), col = "#374151", cex = 1.1, font = 2, adj = 0)
  text(10, 77, paste("Assessment Date:", format(Sys.Date(), "%d %B %Y")), col = "#6B7280", cex = 0.9, adj = 0)
  
  # Draw a horizontal line
  abline(h = 75, col = "#D1D5DB", lwd = 1.5)
  
  # Score section
  ats_score <- predictions$ats_score
  pass_prob <- predictions$pass_probability
  
  # Draw score boxes
  # ATS Score Box
  rect(10, 56, 45, 71, col = "#F3F4F6", border = "#E5E7EB", lwd = 2)
  text(27.5, 66, "ATS Match Score", col = "#4B5563", cex = 1.0, font = 2)
  text(27.5, 61, paste(ats_score, "/ 100", sep = ""), col = ifelse(ats_score >= 70, "#10B981", "#EF4444"), cex = 1.8, font = 2)
  
  # Pass Probability Box
  rect(55, 56, 90, 71, col = "#F3F4F6", border = "#E5E7EB", lwd = 2)
  text(72.5, 66, "Pass Probability", col = "#4B5563", cex = 1.0, font = 2)
  text(72.5, 61, paste(pass_prob, "%", sep = ""), col = ifelse(pass_prob >= 70, "#10B981", "#EF4444"), cex = 1.8, font = 2)
  
  # Status Text
  status <- ifelse(ats_score >= 70, "PASSED (Highly Compatible)", "REJECTED (Needs Optimization)")
  rect(10, 48, 90, 53, col = ifelse(ats_score >= 70, "#D1FAE5", "#FEE2E2"), border = NA)
  text(50, 50.5, paste("ATS Screening Status:", status), col = ifelse(ats_score >= 70, "#065F46", "#991B1B"), cex = 1.1, font = 2, adj = 0.5)
  
  # Summary table
  text(10, 44, "Key Metrics Summary:", col = "#111827", cex = 1.1, font = 2, adj = 0)
  
  # Table Grid
  y_grid <- seq(24, 40, length.out = 6)
  for (y in y_grid) {
    abline(h = y, col = "#E5E7EB", lwd = 0.8)
  }
  rect(10, 24, 90, 40, border = "#D1D5DB", lwd = 1.2)
  
  # Headers
  text(12, 38, "Metric Category", font = 2, adj = 0, cex = 0.9)
  text(50, 38, "Extracted Value", font = 2, adj = 0, cex = 0.9)
  text(75, 38, "ATS Evaluation", font = 2, adj = 0, cex = 0.9)
  
  feats <- predictions$features
  metrics <- list(
    list("Experience", paste(feats$experience_years, "Years"), ifelse(feats$experience_years >= 3, "Adequate", "Junior")),
    list("Education", as.character(feats$education_level), ifelse(feats$education_level %in% c("Master", "PhD", "Bachelor"), "Meets Criteria", "Low")),
    list("Readability (Flesch)", round(feats$readability_score, 1), ifelse(feats$readability_score >= 30 && feats$readability_score <= 75, "Excellent", "Poor Formatting")),
    list("Keyword Match %", paste(round(feats$keyword_match_percent, 1), "%"), ifelse(feats$keyword_match_percent >= 50, "Good Match", "Incomplete")),
    list("Tech Skills Count", feats$tech_skills_count, ifelse(feats$tech_skills_count >= 8, "Highly Skilled", "Add Core Skills"))
  )
  
  for (idx in 1:length(metrics)) {
    y_row <- y_grid[idx+1] + 1.6
    text(12, y_row, metrics[[idx]][[1]], adj = 0, cex = 0.85)
    text(50, y_row, metrics[[idx]][[2]], adj = 0, cex = 0.85)
    text(75, y_row, metrics[[idx]][[3]], adj = 0, cex = 0.85, col = ifelse(metrics[[idx]][[3]] %in% c("Adequate", "Meets Criteria", "Excellent", "Good Match", "Highly Skilled"), "#059669", "#D97706"))
  }
  
  # Footer Page 1
  text(50, 5, "Page 1 of 2  -  Generated by Resume ATS Score Analytics Engine", col = "#9CA3AF", cex = 0.8, adj = 0.5)
  
  # Page 2 Details & Action Plan
  plot.new()
  plot.window(xlim = c(0, 100), ylim = c(0, 100))
  
  # Header
  rect(0, 92, 100, 100, col = "#1F2937", border = NA)
  text(50, 96, "RESUME OPTIMIZATION PLAN", col = "white", cex = 1.5, font = 2, adj = 0.5)
  
  # Detected Skills Box
  text(10, 88, "Top Detected Skills in Resume:", col = "#111827", cex = 1.1, font = 2, adj = 0)
  detected_str <- ifelse(length(predictions$detected_skills) > 0, 
                         paste(head(predictions$detected_skills, 12), collapse = "  |  "),
                         "No core skills detected.")
  rect(10, 78, 90, 86, col = "#EFF6FF", border = "#BFDBFE", lwd = 1)
  text(12, 82, detected_str, col = "#1E40AF", cex = 0.8, adj = 0, font = 3)
  
  # Missing High-Priority Skills
  text(10, 74, "Critical Missing Role Skills (Add These):", col = "#111827", cex = 1.1, font = 2, adj = 0)
  missing_str <- ifelse(length(predictions$missing_skills) > 0,
                        paste(head(predictions$missing_skills, 12), collapse = "  |  "),
                        "No high-priority missing skills.")
  rect(10, 64, 90, 72, col = "#FFFBEB", border = "#FDE68A", lwd = 1)
  text(12, 68, missing_str, col = "#92400E", cex = 0.8, adj = 0, font = 3)
  
  # Action Plan list
  text(10, 60, "Actionable Improvements Checklist:", col = "#111827", cex = 1.1, font = 2, adj = 0)
  
  suggestions <- generate_improvement_suggestions(predictions)
  y_pos <- 55
  for (sug in head(suggestions, 6)) {
    # Text wrapping if too long
    wrapped <- strwrap(sug, width = 85)
    for (line in wrapped) {
      if (line == wrapped[1]) {
        text(10, y_pos, "o", col = "#3B82F6", cex = 1.2, adj = 0)
        text(14, y_pos, line, col = "#374151", cex = 0.85, adj = 0)
      } else {
        text(14, y_pos, line, col = "#374151", cex = 0.85, adj = 0)
      }
      y_pos <- y_pos - 2.8
    }
    y_pos <- y_pos - 1.5
  }
  
  # Certifications and Final notes
  abline(h = 18, col = "#E5E7EB", lwd = 1.2)
  text(10, 15, "Certifications Detected:", col = "#111827", cex = 0.9, font = 2, adj = 0)
  certs_str <- ifelse(length(predictions$detected_certs) > 0, 
                      paste(predictions$detected_certs, collapse = ", "),
                      "No industry certifications matched.")
  text(10, 12, certs_str, col = "#4B5563", cex = 0.8, adj = 0)
  
  # Footer Page 2
  text(50, 5, "Page 2 of 2  -  Resume ATS Score Analytics", col = "#9CA3AF", cex = 0.8, adj = 0.5)
  
  # Close PDF device
  dev.off()
  return(filepath)
}
