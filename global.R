# ==================================================
# global.R - Global configuration and bootstrapping
# ==================================================

# ---- 1. Set up user-writable library path first ----
user_lib <- Sys.getenv("R_LIBS_USER", unset = file.path(
  path.expand("~"), "R", "win-library",
  paste(R.version$major, sub("\\..*", "", R.version$minor), sep = ".")
))
if (!dir.exists(user_lib)) dir.create(user_lib, recursive = TRUE)
.libPaths(c(user_lib, .libPaths()))

# ---- 2. Install any missing packages silently ----
required_pkgs <- c(
  "shiny", "shinydashboard", "DT", "plotly",
  "ggplot2", "dplyr", "tidyr", "stringr", "readr",
  "tidytext", "tm", "text2vec",
  "caret", "randomForest", "rpart", "e1071",
  "corrplot", "wordcloud", "pdftools", "readtext",
  "quanteda", "lubridate", "igraph", "reshape2",
  "DBI", "RSQLite", "shinycssloaders", "shinyWidgets", "fresh", "shinyjs"
)

is_pkg_installed <- function(pkg) {
  system.file(package = pkg) != ""
}
missing_pkgs <- required_pkgs[!sapply(required_pkgs, is_pkg_installed)]
if (length(missing_pkgs) > 0) {
  message("Installing missing packages: ", paste(missing_pkgs, collapse = ", "))
  install.packages(missing_pkgs,
                   repos       = "https://cloud.r-project.org",
                   lib         = user_lib,
                   dependencies = TRUE,
                   quiet       = TRUE)
}

# ---- 3. Load packages (with informative error on failure) ----
load_pkg <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    warning("Package '", pkg, "' could not be loaded – some features may be unavailable.")
    return(invisible(FALSE))
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
  invisible(TRUE)
}

message("Loading R packages...")
for (pkg in required_pkgs) load_pkg(pkg)

# ---- 4. Set base paths ----
base_dir    <- getwd()
data_dir    <- file.path(base_dir, "data")
resumes_dir <- file.path(data_dir, "resumes")
jds_dir     <- file.path(data_dir, "job_descriptions")
models_dir  <- file.path(base_dir, "models")
outputs_dir <- file.path(base_dir, "outputs")
graphs_dir  <- file.path(outputs_dir, "graphs")
reports_dir <- file.path(outputs_dir, "reports")

# ---- 5. Create directory structure ----
for (d in c(data_dir, resumes_dir, jds_dir, models_dir,
            outputs_dir, graphs_dir, reports_dir)) {
  if (!dir.exists(d)) dir.create(d, recursive = TRUE)
}

# ---- 6. Source project scripts ----
message("Sourcing project scripts...")
source(file.path(base_dir, "scripts/01_extract_resume.R"))
source(file.path(base_dir, "scripts/02_clean_text.R"))
source(file.path(base_dir, "scripts/03_feature_engineering.R"))
source(file.path(base_dir, "scripts/04_eda.R"))
source(file.path(base_dir, "scripts/05_model_training.R"))
source(file.path(base_dir, "scripts/06_prediction.R"))
source(file.path(base_dir, "scripts/07_dashboard_helpers.R"))
source(file.path(base_dir, "scripts/08_database.R"))

# ---- 7. Initialize SQLite Database ----
init_database(file.path(data_dir, "ats_analytics.sqlite"))

# ---- 8. Helper: programmatically create sample PDF resumes ----
create_sample_resume_pdf <- function(filepath, name, role, details) {
  pdf(filepath, width = 8.5, height = 11)
  par(mar = c(2, 2, 2, 2))
  plot.new()
  plot.window(xlim = c(0, 100), ylim = c(0, 100))

  rect(0, 92, 100, 100, col = "#1E3A8A", border = NA)
  text(50, 96, toupper(name), col = "white",   cex = 1.6, font = 2, adj = 0.5)
  text(50, 93, toupper(role), col = "#93C5FD", cex = 1.0, font = 3, adj = 0.5)
  text(50, 90, "Email: contact@example.com  |  Phone: +1 555-0199  |  GitHub: github.com/candidate",
       col = "#4B5563", cex = 0.8, adj = 0.5)

  lines_vec <- unlist(strsplit(details, "\n"))
  y_pos <- 84
  for (line in lines_vec) {
    if (trimws(line) == "") { y_pos <- y_pos - 1.5; next }
    if (grepl("^[A-Z\\s]{4,20}$", trimws(line)) || grepl("^##", line)) {
      clean_hdr <- gsub("^##\\s*", "", line)
      y_pos <- y_pos - 1.5
      text(10, y_pos, clean_hdr, col = "#1E3A8A", cex = 1.1, font = 2, adj = 0)
      rect(10, y_pos - 0.5, 90, y_pos - 0.4, col = "#E5E7EB", border = NA)
      y_pos <- y_pos - 2.5
    } else if (grepl("^[-*]", trimws(line))) {
      clean_bullet <- gsub("^[-*]\\s*", "", trimws(line))
      text(12, y_pos, "\u2022", col = "#1E3A8A", cex = 1.2, adj = 0)
      for (w_line in strwrap(clean_bullet, width = 85)) {
        text(15, y_pos, w_line, col = "#374151", cex = 0.85, adj = 0)
        y_pos <- y_pos - 2.0
      }
    } else {
      for (w_line in strwrap(line, width = 90)) {
        text(10, y_pos, w_line, col = "#374151", cex = 0.85, adj = 0)
        y_pos <- y_pos - 2.0
      }
    }
    if (y_pos < 10) { plot.new(); plot.window(xlim=c(0,100), ylim=c(0,100)); y_pos <- 90 }
  }
  dev.off()
}

# ---- 8. Bootstrap sample resumes and job descriptions ----
bootstrap_sample_files <- function() {
  ds_resume_path <- file.path(resumes_dir, "sample_data_scientist.pdf")
  if (!file.exists(ds_resume_path)) {
    ds_details <- "## PROFESSIONAL SUMMARY
Senior Data Scientist with 6 years of experience in statistical analysis, predictive modeling, and system design.
Proven record of delivering machine learning projects that drive business decisions.
Expert in Python, R, and SQL.
AWS Certified Machine Learning Specialist.

## SKILLS
* Machine Learning: Random Forest, Gradient Boosting, SVM, K-Means, Neural Networks.
* Languages & Tools: Python, R, SQL, Git, Docker, Kubernetes.
* Data Engineering: Pandas, NumPy, Spark, Airflow, Tableau, PowerBI.
* Soft Skills: Leadership, Communication, Project Management, Collaboration.

## EXPERIENCE
* Lead Data Scientist - TechCorp (2022 - Present)
- Spearheaded development of a customer recommendation system using PyTorch and Scikit-Learn.
- Designed automated data pipelines in Airflow, reducing processing times by 35%.
- Led a team of 3 junior data scientists to coordinate predictive analytics models.
* Data Analyst - Analytics Group (2020 - 2022)
- Solved complex database query issues, increasing reporting speeds by 50%.
- Formulated key customer retention strategies using logistic regression.

## PROJECTS
* AI Resume Matcher
- Developed an ATS score calculator using text2vec, Cosine Similarity, and Random Forest in R.
- Configured a Shiny dashboard with plotly charts and automated reports.

## EDUCATION
* Master of Science in Data Science - State University (Graduated 2020)
* Bachelor of Technology in Computer Science - Tech Institute (Graduated 2018)"
    create_sample_resume_pdf(ds_resume_path, "John Doe", "Senior Data Scientist", ds_details)
  }

  devops_resume_path <- file.path(resumes_dir, "sample_devops_engineer.pdf")
  if (!file.exists(devops_resume_path)) {
    devops_details <- "## PROFESSIONAL SUMMARY
DevOps Architect with 5 years of experience in cloud infrastructure automation and deployment management.
Specialized in Docker, Kubernetes, Jenkins, Terraform, and Ansible.
AWS Certified Solutions Architect - Professional.

## SKILLS
* Cloud: AWS, GCP, CloudFormation, Lambda, S3, EC2.
* DevOps: Kubernetes, Docker, Jenkins, Terraform, Ansible, Git, CI/CD.
* Monitoring: Grafana, Prometheus, ELK Stack, Splunk.
* Scripting: Bash, Python, PowerShell.

## EXPERIENCE
* Senior DevOps Engineer - CloudSystems (2023 - Present)
- Built automated infrastructure using Terraform, reducing server setup times from 2 days to 10 minutes.
- Implemented Kubernetes cluster autoscaling on AWS EKS, saving 20% on cloud bills.
- Streamlined code release workflows with GitHub Actions CI/CD.
* System Administrator - NetWorks (2021 - 2023)
- Managed Linux servers, firewall rules, and SSL/TLS certificate renewals.

## PROJECTS
* Cloud Migration Pipeline
- Managed the migration of 40 microservices from on-premise servers to AWS ECS with zero downtime.

## EDUCATION
* Bachelor of Science in Information Technology - Poly University (Graduated 2021)"
    create_sample_resume_pdf(devops_resume_path, "Jane Smith", "Senior DevOps Engineer", devops_details)
  }

  ds_jd_path <- file.path(jds_dir, "data_scientist_jd.txt")
  if (!file.exists(ds_jd_path)) {
    writeLines(
      "Position: Senior Data Scientist
Location: Remote / New York
Company: AI Innovations

Job Description:
We are looking for an experienced Data Scientist with 5+ years of experience to join our growing AI team.
You will build predictive models, design data pipelines, and develop machine learning algorithms.

Required Technical Skills:
- Programming: Python, R, SQL
- Machine Learning: Random Forest, SVM, Deep Learning
- Frameworks: PyTorch, TensorFlow, Scikit-Learn
- Tools: Git, Docker, Kubernetes, Airflow, Spark
- Visualization: Tableau or PowerBI

Education:
- Bachelor or Master degree in Computer Science, Data Science, Statistics, or a related field.

Certifications:
- AWS Certified Machine Learning Specialty or Google Cloud Professional Data Engineer is a major plus.",
      ds_jd_path
    )
  }

  devops_jd_path <- file.path(jds_dir, "devops_engineer_jd.txt")
  if (!file.exists(devops_jd_path)) {
    writeLines(
      "Position: Senior DevOps Engineer
Location: San Francisco, CA
Company: CloudScale Solutions

Job Description:
We are seeking a DevOps Engineer with 4+ years of experience to automate cloud deployments and manage our container infrastructure.

Required Skills:
- Containerization: Docker, Kubernetes (EKS/GKE)
- Cloud Platforms: AWS, Azure, or Google Cloud
- Automation: Terraform, Ansible, Jenkins, Git
- Scripting: Bash, Python
- Monitoring: Prometheus, Grafana, ELK Stack

Certifications:
- AWS Solutions Architect or DevOps Engineer Professional is highly preferred.",
      devops_jd_path
    )
  }
}

bootstrap_sample_files()

# ---- 9. Load or train the ML model ----
model_file <- file.path(models_dir, "randomForest_model.rds")
if (!file.exists(model_file)) {
  message("Model not found. Running training pipeline...")
  train_ats_models()
}

message("Loading trained model package...")
trained_model_pkg <- readRDS(model_file)
message("System Bootstrap Complete!")
