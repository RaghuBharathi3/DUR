# Requirements

To run the "Resume ATS Score Analytics" project, you need R (version 4.0.0 or higher) and the following packages installed.

## R Packages

The following R packages are required:

*   **tidyverse** (includes ggplot2, dplyr, stringr, readr, purrr, tibble, tidyr)
*   **shiny** (dashboard framework)
*   **shinydashboard** (dashboard template layout)
*   **DT** (interactive data tables)
*   **plotly** (interactive charts)
*   **pdftools** (PDF text extraction)
*   **readtext** (reading text documents)
*   **tm** (text mining infrastructure)
*   **tidytext** (tidy text mining)
*   **text2vec** (vectorization and cosine similarity calculation)
*   **caret** (machine learning training and evaluation infrastructure)
*   **randomForest** (Random Forest machine learning model)
*   **rpart** (Decision Tree modeling)
*   **e1071** (SVM and Naive Bayes modeling)
*   **corrplot** (correlation matrix visualization)
*   **wordcloud** (static word cloud generation)
*   **quanteda** (alternative quantitative text analysis)
*   **lubridate** (date-time manipulation)
*   **igraph** (network visualization of skill correlation)
*   **reshape2** (data reshaping)
*   **htmltools** (HTML helper functions)

## System Dependencies

For text extraction:
*   Windows: No special dependencies.
*   Linux (Debian/Ubuntu): `libpoppler-cpp-dev` (required by `pdftools`)
*   macOS: `poppler` (via Homebrew: `brew install poppler`)

## Installation

You can install all required packages by running the following command in your R Console:

```R
install.packages(c(
  "tidyverse", "ggplot2", "dplyr", "stringr", "tidytext", "tm", 
  "text2vec", "caret", "randomForest", "rpart", "e1071", "corrplot", 
  "wordcloud", "shiny", "shinydashboard", "DT", "pdftools", "readtext", 
  "quanteda", "lubridate", "plotly", "igraph", "reshape2"
))
```
