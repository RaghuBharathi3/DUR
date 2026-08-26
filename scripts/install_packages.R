# Ensure a user-writable library exists
user_lib <- Sys.getenv("R_LIBS_USER", unset = file.path(path.expand("~"), "R", "win-library",
                        paste(R.version$major, sub("\\..*", "", R.version$minor), sep = ".")))
if (!dir.exists(user_lib)) dir.create(user_lib, recursive = TRUE)
.libPaths(c(user_lib, .libPaths()))
cat("Installing to:", user_lib, "\n")

pkgs <- c(
  "shiny", "shinydashboard", "shinydashboardPlus", "shinyWidgets",
  "DT", "plotly", "ggplot2", "dplyr", "tidyr", "stringr",
  "readr", "pdftools", "officer", "textrank", "tidytext",
  "wordcloud2", "RColorBrewer", "caret", "randomForest",
  "e1071", "igraph", "ggraph", "lubridate", "readtext",
  "quanteda", "tm"
)

missing <- pkgs[!pkgs %in% installed.packages()[, "Package"]]

if (length(missing) > 0) {
  cat("Installing missing packages:", paste(missing, collapse = ", "), "\n")
  install.packages(missing, repos = "https://cloud.r-project.org", lib = user_lib, dependencies = TRUE, type = "binary")
} else {
  cat("All packages already installed.\n")
}

cat("Done!\n")
