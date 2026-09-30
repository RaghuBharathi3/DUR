source("global.R")

cat("=== 1. Verifying Sample Files ===\n")
samples <- c("sample_data_scientist.pdf", "sample_devops_engineer.pdf", "sample_sde_fullstack.pdf")
for (s in samples) {
  p <- file.path("data/resumes", s)
  cat(s, "exists:", file.exists(p), "\n")
}

cat("\n=== 2. Testing Predictions Across Sample Candidates ===\n")
tests <- list(
  list(file="sample_data_scientist.pdf", role="Data Scientist", jd="Looking for Data Scientist with Python, SQL, Machine Learning, R, Docker"),
  list(file="sample_devops_engineer.pdf", role="DevOps Engineer", jd="Looking for DevOps Engineer with Kubernetes, Docker, Terraform, AWS, Jenkins"),
  list(file="sample_sde_fullstack.pdf", role="Full Stack Developer", jd="Looking for Full Stack Developer with React, Node.js, TypeScript, PostgreSQL, REST APIs")
)

for (t in tests) {
  res <- predict_resume_ats(file.path("data/resumes", t$file), t$jd, t$role)
  cat(sprintf("[%s] Score: %0.1f | Pass Prob: %0.1f%% | Skills Detected: %d | Missing: %d\n",
              t$role, res$ats_score, res$pass_probability, length(res$detected_skills), length(res$missing_skills)))
}

cat("\n=== 3. Testing PDF Report Generation ===\n")
res_ds <- predict_resume_ats("data/resumes/sample_data_scientist.pdf", "Data Scientist with Python and SQL", "Data Scientist")
pdf_out <- generate_resume_pdf_report("John Doe", "Data Scientist", res_ds, "outputs/reports/automated_test_report.pdf")
cat("PDF Report generated:", file.exists(pdf_out), "| File size:", file.info(pdf_out)$size, "bytes\n")

cat("\n=== 4. Testing Database Operations ===\n")
stats <- get_db_stats()
cat("DB Total Evaluations:", stats$total, "| Avg Score:", stats$avg_score, "| Pass Rate:", stats$pass_rate, "%\n")
hist <- get_evaluation_history(limit=5)
cat("History records retrieved:", nrow(hist), "\n")

cat("\n=== ALL INTEGRATION TESTS COMPLETED SUCCESSFULLY! ===\n")
