# run_app.R - Launch the Resume ATS Analytics Shiny Dashboard
# Ensures user library is on the search path before loading shiny

user_lib <- file.path(Sys.getenv("USERPROFILE"), "R", "win-library", "4.3")
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

shiny::runApp("app.R", host = "127.0.0.1", port = 3838, launch.browser = TRUE)
