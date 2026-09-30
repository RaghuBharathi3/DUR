# run_app.R - Launch the Resume ATS Analytics Shiny Dashboard
# Ensures user library is on the search path before loading shiny

user_lib <- Sys.getenv("R_LIBS_USER", unset = file.path(
  path.expand("~"), "AppData", "Local", "R", "win-library",
  paste(R.version$major, sub("\\..*", "", R.version$minor), sep = ".")
))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

shiny::runApp("app.R", host = "127.0.0.1", port = 3838, launch.browser = TRUE)
