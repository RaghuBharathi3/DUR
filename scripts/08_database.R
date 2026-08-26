library(DBI)
library(RSQLite)
library(dplyr)

#' Initialize the SQLite database
#' Creates tables: evaluations, sessions, batch_jobs
#' @return DBI connection object
#' @export
init_database <- function(db_path = "data/ats_analytics.sqlite") {
  if (!dir.exists(dirname(db_path))) dir.create(dirname(db_path), recursive = TRUE)
  con <- dbConnect(RSQLite::SQLite(), db_path)

  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS evaluations (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id      TEXT NOT NULL,
      candidate_name  TEXT NOT NULL,
      target_role     TEXT NOT NULL,
      resume_filename TEXT,
      ats_score       REAL NOT NULL,
      pass_probability REAL NOT NULL,
      pass_fail       TEXT NOT NULL,
      experience_years INTEGER,
      education_level TEXT,
      tech_skills_count INTEGER,
      soft_skills_count INTEGER,
      certs_count     INTEGER,
      word_count      INTEGER,
      readability_score REAL,
      keyword_match_percent REAL,
      cosine_similarity REAL,
      detected_skills TEXT,
      missing_skills  TEXT,
      top_suggestions TEXT,
      report_path     TEXT,
      evaluated_at    TEXT NOT NULL DEFAULT (datetime('now','localtime'))
    )
  ")

  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS batch_jobs (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      job_name      TEXT NOT NULL,
      total_resumes INTEGER,
      completed     INTEGER DEFAULT 0,
      avg_ats_score REAL,
      pass_count    INTEGER,
      fail_count    INTEGER,
      target_role   TEXT,
      started_at    TEXT DEFAULT (datetime('now','localtime')),
      completed_at  TEXT
    )
  ")

  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS job_descriptions (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      title       TEXT NOT NULL,
      company     TEXT,
      description TEXT NOT NULL,
      min_experience INTEGER DEFAULT 0,
      created_at  TEXT DEFAULT (datetime('now','localtime'))
    )
  ")

  # Seed built-in JDs if empty
  existing <- dbGetQuery(con, "SELECT COUNT(*) as n FROM job_descriptions")$n
  if (existing == 0) {
    seed_job_descriptions(con)
  }

  dbDisconnect(con)
  message("Database initialized at: ", db_path)
  return(invisible(db_path))
}

#' Get a fresh database connection
db_connect <- function(db_path = "data/ats_analytics.sqlite") {
  dbConnect(RSQLite::SQLite(), db_path)
}

#' Save an evaluation result to the database
#' @export
save_evaluation <- function(session_id, candidate_name, target_role,
                            resume_filename = NA, predictions,
                            suggestions = character(0), report_path = NA,
                            db_path = "data/ats_analytics.sqlite") {
  feats <- predictions$features
  pass_fail <- ifelse(predictions$ats_score >= 70, "Pass", "Fail")

  row <- data.frame(
    session_id            = session_id,
    candidate_name        = candidate_name,
    target_role           = target_role,
    resume_filename       = ifelse(is.null(resume_filename) || is.na(resume_filename), "", resume_filename),
    ats_score             = round(predictions$ats_score, 1),
    pass_probability      = round(predictions$pass_probability, 1),
    pass_fail             = pass_fail,
    experience_years      = as.integer(feats$experience_years),
    education_level       = as.character(feats$education_level),
    tech_skills_count     = as.integer(feats$tech_skills_count),
    soft_skills_count     = as.integer(feats$soft_skills_count),
    certs_count           = as.integer(feats$certs_count),
    word_count            = as.integer(feats$word_count),
    readability_score     = round(feats$readability_score, 2),
    keyword_match_percent = round(feats$keyword_match_percent, 1),
    cosine_similarity     = round(feats$cosine_similarity, 4),
    detected_skills       = paste(head(predictions$detected_skills, 20), collapse = ", "),
    missing_skills        = paste(head(predictions$missing_skills, 10), collapse = ", "),
    top_suggestions       = paste(head(suggestions, 3), collapse = " | "),
    report_path           = ifelse(is.null(report_path) || is.na(report_path), "", report_path),
    evaluated_at          = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    stringsAsFactors      = FALSE
  )

  con <- db_connect(db_path)
  on.exit(dbDisconnect(con))
  dbAppendTable(con, "evaluations", row)
  id <- dbGetQuery(con, "SELECT last_insert_rowid() as id")$id
  return(id)
}

#' Retrieve evaluation history
#' @export
get_evaluation_history <- function(limit = 100, db_path = "data/ats_analytics.sqlite") {
  if (!file.exists(db_path)) return(data.frame())
  con <- db_connect(db_path)
  on.exit(dbDisconnect(con))
  df <- dbGetQuery(con, sprintf(
    "SELECT id, candidate_name, target_role, ats_score, pass_probability, pass_fail,
            experience_years, education_level, tech_skills_count, keyword_match_percent,
            resume_filename, evaluated_at
     FROM evaluations ORDER BY id DESC LIMIT %d", limit))
  return(df)
}

#' Get aggregate statistics for the dashboard
#' @export
get_db_stats <- function(db_path = "data/ats_analytics.sqlite") {
  if (!file.exists(db_path)) {
    return(list(total=0, avg_score=0, pass_rate=0, roles=data.frame(), trend=data.frame()))
  }
  con <- db_connect(db_path)
  on.exit(dbDisconnect(con))

  stats <- dbGetQuery(con, "
    SELECT COUNT(*) as total,
           ROUND(AVG(ats_score), 1) as avg_score,
           ROUND(100.0 * SUM(CASE WHEN pass_fail='Pass' THEN 1 ELSE 0 END) / MAX(COUNT(*),1), 1) as pass_rate
    FROM evaluations")

  role_dist <- dbGetQuery(con, "
    SELECT target_role, COUNT(*) as n, ROUND(AVG(ats_score),1) as avg_score
    FROM evaluations GROUP BY target_role ORDER BY n DESC")

  trend <- dbGetQuery(con, "
    SELECT strftime('%Y-%m-%d', evaluated_at) as date,
           ROUND(AVG(ats_score),1) as avg_score,
           COUNT(*) as n
    FROM evaluations GROUP BY date ORDER BY date DESC LIMIT 30")

  return(list(
    total     = stats$total,
    avg_score = stats$avg_score,
    pass_rate = stats$pass_rate,
    roles     = role_dist,
    trend     = trend
  ))
}

#' Get all job descriptions from DB
#' @export
get_job_descriptions <- function(db_path = "data/ats_analytics.sqlite") {
  if (!file.exists(db_path)) return(data.frame())
  con <- db_connect(db_path)
  on.exit(dbDisconnect(con))
  dbGetQuery(con, "SELECT id, title, company, description, min_experience, created_at FROM job_descriptions ORDER BY id")
}

#' Add a job description to DB
#' @export
add_job_description <- function(title, description, company = "", min_experience = 0,
                                db_path = "data/ats_analytics.sqlite") {
  con <- db_connect(db_path)
  on.exit(dbDisconnect(con))
  dbExecute(con,
    "INSERT INTO job_descriptions (title, company, description, min_experience) VALUES (?,?,?,?)",
    params = list(title, company, description, min_experience))
}

#' Save a batch job record
#' @export
save_batch_job <- function(job_name, total_resumes, avg_ats, pass_count, fail_count, target_role,
                           db_path = "data/ats_analytics.sqlite") {
  con <- db_connect(db_path)
  on.exit(dbDisconnect(con))
  dbExecute(con,
    "INSERT INTO batch_jobs (job_name, total_resumes, completed, avg_ats_score, pass_count, fail_count, target_role, completed_at)
     VALUES (?,?,?,?,?,?,?, datetime('now','localtime'))",
    params = list(job_name, total_resumes, total_resumes, avg_ats, pass_count, fail_count, target_role))
}

#' Get batch job history
#' @export
get_batch_history <- function(db_path = "data/ats_analytics.sqlite") {
  if (!file.exists(db_path)) return(data.frame())
  con <- db_connect(db_path)
  on.exit(dbDisconnect(con))
  dbGetQuery(con, "SELECT * FROM batch_jobs ORDER BY id DESC LIMIT 50")
}

#' Delete an evaluation by ID
#' @export
delete_evaluation <- function(eval_id, db_path = "data/ats_analytics.sqlite") {
  con <- db_connect(db_path)
  on.exit(dbDisconnect(con))
  dbExecute(con, "DELETE FROM evaluations WHERE id = ?", params = list(eval_id))
}

#' Seed built-in job descriptions
seed_job_descriptions <- function(con) {
  jds <- list(
    list("Data Scientist", "TechCorp Inc.",
         "We are looking for a Data Scientist with 4+ years of experience. Must be expert in Python, R, SQL, machine learning, deep learning, NLP, and cloud computing (AWS/GCP). Responsibilities include developing predictive models, analyzing data, designing data pipelines, and implementing AI algorithms using TensorFlow or PyTorch. Bachelor or Master degree in Computer Science required.", 4),
    list("Web Designer", "Creative Studio",
         "Seeking a creative Web Designer with 2+ years of experience. Must be proficient in HTML, CSS, JavaScript, React, and Figma. Responsibilities include creating responsive web layouts, designing user interfaces, and collaborating with cross-functional teams. Portfolio required.", 2),
    list("Java Developer", "Enterprise Solutions Ltd.",
         "Looking for a Java Developer with 5+ years of experience in Java, Spring Boot, microservices, PostgreSQL, and REST APIs. Responsibilities include building scalable backend applications, optimizing database performance, and writing unit tests with JUnit.", 5),
    list("DevOps Engineer", "CloudOps Co.",
         "We are hiring a DevOps Engineer with 3+ years of experience in Docker, Kubernetes, Jenkins, Terraform, AWS, and Linux. Duties include building CI/CD pipelines, automating cloud infrastructure, and monitoring server health using Prometheus and Grafana.", 3),
    list("HR Manager", "PeopleFirst Corp.",
         "Seeking an HR Manager with 5+ years of experience in recruitment, talent acquisition, onboarding, and employee relations. Must have excellent communication, leadership, and project management skills. SHRM certification preferred.", 5),
    list("Legal Counsel", "LexGroup Associates",
         "Looking for a Legal Counsel with 6+ years of experience. Must be expert in corporate law, contract negotiation, drafting contract agreements, and dispute resolution. Bar certification required.", 6),
    list("Full Stack Developer", "StartupXYZ",
         "Seeking a Full Stack Developer with 3+ years experience in React, Node.js, TypeScript, PostgreSQL, REST APIs, Git, Docker. Must be comfortable with CI/CD, cloud deployment (AWS/GCP/Azure), and agile methodologies.", 3),
    list("Data Analyst", "Analytics Hub",
         "Looking for a Data Analyst with 2+ years experience in SQL, Excel, Tableau or Power BI, Python or R. Responsibilities include dashboard creation, KPI reporting, data wrangling, and stakeholder presentations.", 2)
  )

  for (jd in jds) {
    dbExecute(con,
      "INSERT INTO job_descriptions (title, company, description, min_experience) VALUES (?,?,?,?)",
      params = jd)
  }
  message("Seeded ", length(jds), " built-in job descriptions.")
}
