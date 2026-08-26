# ==================================================
# app.R - Resume ATS Score Analytics & Database Dashboard
# ==================================================

source("global.R")

# Custom Premium CSS for modern UI design
custom_css <- "
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
  
  :root {
    --slate-50: #f8fafc;
    --slate-100: #f1f5f9;
    --slate-200: #e2e8f0;
    --slate-300: #cbd5e1;
    --slate-700: #334155;
    --slate-800: #1e293b;
    --slate-900: #0f172a;
    --indigo-500: #6366f1;
    --indigo-600: #4f46e5;
    --indigo-700: #4338ca;
    --emerald-500: #10b981;
    --emerald-600: #059669;
    --rose-500: #f43f5e;
    --rose-600: #e11d48;
    --amber-500: #f59e0b;
    --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
    --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
    --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
    --radius-md: 8px;
    --radius-lg: 12px;
    --transition-smooth: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }
  
  body, .wrapper, .main-sidebar, .left-side {
    font-family: 'Inter', sans-serif !important;
    background-color: var(--slate-50) !important;
  }
  
  /* Scrollbar Customization */
  ::-webkit-scrollbar {
    width: 8px;
    height: 8px;
  }
  ::-webkit-scrollbar-track {
    background: var(--slate-100);
  }
  ::-webkit-scrollbar-thumb {
    background: var(--slate-300);
    border-radius: 4px;
  }
  ::-webkit-scrollbar-thumb:hover {
    background: var(--slate-700);
  }

  /* Header styling */
  .main-header .logo {
    font-family: 'Inter', sans-serif !important;
    font-weight: 700 !important;
    background-color: var(--slate-900) !important;
    color: #FFFFFF !important;
    border-bottom: 1px solid var(--slate-800);
  }
  
  .main-header .navbar {
    background-color: var(--slate-900) !important;
    box-shadow: var(--shadow-sm);
  }
  
  /* Sidebar styling */
  .main-sidebar {
    background-color: var(--slate-900) !important;
    border-right: 1px solid var(--slate-800);
  }
  
  .sidebar-menu li a {
    font-weight: 500;
    font-size: 14px;
    color: var(--slate-300) !important;
    border-left: 3px solid transparent;
    padding: 12px 15px 12px 20px !important;
    transition: var(--transition-smooth);
  }
  
  .sidebar-menu li.active a, .sidebar-menu li a:hover {
    color: #FFFFFF !important;
    background-color: var(--slate-800) !important;
    border-left-color: var(--indigo-500) !important;
  }
  
  /* Box Cards styling */
  .box {
    border-radius: var(--radius-lg) !important;
    border: 1px solid var(--slate-200) !important;
    border-top: 4px solid var(--indigo-600) !important;
    box-shadow: var(--shadow-sm) !important;
    background: #FFFFFF !important;
    transition: var(--transition-smooth);
    margin-bottom: 24px;
  }
  
  .box:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md) !important;
  }
  
  .box.box-solid {
    border-top: 1px solid var(--slate-200) !important;
  }
  
  /* Custom Box Status Colors */
  .box.box-primary { border-top-color: var(--indigo-600) !important; }
  .box.box-success { border-top-color: var(--emerald-500) !important; }
  .box.box-danger { border-top-color: var(--rose-500) !important; }
  .box.box-warning { border-top-color: var(--amber-500) !important; }
  .box.box-info { border-top-color: var(--indigo-500) !important; }

  .box-header {
    border-bottom: 1px solid var(--slate-100) !important;
    font-weight: 600;
    color: var(--slate-800);
    padding: 15px 20px !important;
  }
  
  .box-title {
    font-size: 16px !important;
    font-weight: 600 !important;
  }

  .box-body {
    padding: 20px !important;
  }
  
  /* Info box cards */
  .info-box {
    border-radius: var(--radius-lg) !important;
    box-shadow: var(--shadow-sm) !important;
    border: 1px solid var(--slate-200);
    background: #FFFFFF !important;
    transition: var(--transition-smooth);
  }
  
  .info-box:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md) !important;
  }
  
  .info-box-icon {
    border-top-left-radius: var(--radius-lg);
    border-bottom-left-radius: var(--radius-lg);
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  /* Custom Buttons */
  .btn-primary {
    background-color: var(--indigo-600) !important;
    border-color: var(--indigo-600) !important;
    border-radius: var(--radius-md) !important;
    font-weight: 600 !important;
    padding: 10px 20px !important;
    transition: var(--transition-smooth);
    box-shadow: var(--shadow-sm);
  }
  
  .btn-primary:hover, .btn-primary:focus {
    background-color: var(--indigo-700) !important;
    border-color: var(--indigo-700) !important;
    box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3) !important;
  }
  
  .btn-success {
    background-color: var(--emerald-500) !important;
    border-color: var(--emerald-500) !important;
    border-radius: var(--radius-md) !important;
    font-weight: 600 !important;
    padding: 10px 20px !important;
    transition: var(--transition-smooth);
  }
  
  .btn-success:hover {
    background-color: var(--emerald-600) !important;
    border-color: var(--emerald-600) !important;
    box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3) !important;
  }

  /* Form control improvements */
  .form-control, .selectize-input {
    border-radius: var(--radius-md) !important;
    border: 1px solid var(--slate-200) !important;
    padding: 8px 12px !important;
    box-shadow: none !important;
    transition: var(--transition-smooth);
  }

  .form-control:focus, .selectize-input.focus {
    border-color: var(--indigo-500) !important;
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15) !important;
  }
  
  /* Score badge */
  .score-badge {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100px;
    height: 100px;
    border-radius: 50%;
    font-size: 32px;
    font-weight: 700;
    color: white;
    margin: 20px auto;
    box-shadow: var(--shadow-lg);
  }
  
  .score-pass {
    background: linear-gradient(135deg, var(--emerald-500), var(--emerald-600));
  }
  
  .score-fail {
    background: linear-gradient(135deg, var(--rose-500), var(--rose-600));
  }
  
  .skill-badge {
    display: inline-block;
    padding: 6px 14px;
    margin: 4px;
    font-size: 13px;
    font-weight: 500;
    border-radius: 9999px;
    transition: var(--transition-smooth);
  }
  
  .skill-tag-missing {
    background-color: #FFE4E6;
    color: #BE123C;
    border: 1px solid #FDA4AF;
  }
  
  .skill-tag-missing:hover {
    background-color: #FECDD3;
  }
  
  .skill-tag-detected {
    background-color: #D1FAE5;
    color: #047857;
    border: 1px solid #6EE7B7;
  }
  
  .skill-tag-detected:hover {
    background-color: #A7F3D0;
  }

  /* Page tab transitions */
  .tab-pane {
    opacity: 0;
    transition: opacity 0.35s ease-in-out;
  }
  .tab-pane.active {
    opacity: 1;
  }
"

# User Interface
ui <- dashboardPage(
  dashboardHeader(title = "Recruitment Screening Portal"),
  
  dashboardSidebar(
    sidebarMenu(
      id = "sidebar_tabs",
      menuItem("Dashboard Overview", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Single Resume Screener", tabName = "matcher", icon = icon("file-pdf")),
      menuItem("Batch Resume Screener", tabName = "batch_matcher", icon = icon("copy")),
      menuItem("Manage Job Openings", tabName = "job_manager", icon = icon("briefcase")),
      menuItem("Visual Analytics", tabName = "analytics", icon = icon("chart-pie")),
      menuItem("Resume Structure Review", tabName = "optimizer", icon = icon("clipboard-check")),
      menuItem("Model Settings & Metrics", tabName = "performance", icon = icon("gears")),
      menuItem("About Project", tabName = "about", icon = icon("circle-info"))
    )
  ),
  
  dashboardBody(
    shinyjs::useShinyjs(),
    tags$head(
      tags$style(HTML(custom_css)),
      tags$title("Resume ATS Score Analytics - Dashboard")
    ),
    
    tabItems(
      # --- TAB 1: DASHBOARD OVERVIEW ---
      tabItem(
        tabName = "dashboard",
        fluidRow(
          h2("Candidate Recruitment ATS Intelligence Pool", style = "margin-left: 15px; font-weight: 700; color: #1E2937;"),
          p("Real-time database showing evaluated candidate summaries, aggregate fit stats, and matching metrics.", style = "margin-left: 15px; color: #64748B; font-size: 15px; margin-bottom: 20px;")
        ),
        
        fluidRow(
          valueBoxOutput("stat_total_resumes", width = 4),
          valueBoxOutput("stat_avg_score", width = 4),
          valueBoxOutput("stat_pass_rate", width = 4)
        ),
        
        fluidRow(
          column(
            width = 8,
            box(
              title = "ATS Pool Score Distribution",
              width = NULL,
              status = "primary",
              withSpinner(plotlyOutput("pool_ats_dist_plot", height = "350px"), type = 8, color = "#4f46e5")
            )
          ),
          column(
            width = 4,
            box(
              title = "System Setup Guide",
              width = NULL,
              status = "warning",
              p("Follow these steps to assess candidates:"),
              tags$ol(
                tags$li("Open the ", tags$b("Single Resume Screener"), " or ", tags$b("Batch Resume Screener"), " tab."),
                tags$li("Select or add a Job opening in the ", tags$b("Manage Job Openings"), " tab."),
                tags$li("Upload candidate PDF resumes."),
                tags$li("Click 'Calculate Match' to evaluate compatibility using the Random Forest regression engine."),
                tags$li("Download the PDF reports or view analytics.")
              ),
              hr(),
              h5(tags$b("Pre-loaded Test Files:")),
              p("Resumes: ", tags$code("sample_data_scientist.pdf"), ", ", tags$code("sample_devops_engineer.pdf")),
              p("JDs: ", tags$code("data_scientist_jd.txt"), ", ", tags$code("devops_engineer_jd.txt"))
            )
          )
        ),
        
        fluidRow(
          column(
            width = 12,
            box(
              title = "Historical Candidate Evaluations Database",
              width = NULL,
              status = "info",
              solidHeader = TRUE,
              withSpinner(DTOutput("history_table"), type = 8, color = "#4f46e5")
            )
          )
        )
      ),
      
      # --- TAB 2: SINGLE ATS MATCHER ---
      tabItem(
        tabName = "matcher",
        fluidRow(
          column(
            width = 4,
            box(
              title = "Input Configuration",
              width = NULL,
              status = "primary",
              solidHeader = TRUE,
              
              fileInput("resume_file", "Upload Resume PDF", accept = c(".pdf")),
              selectInput("job_role_select", "Select Job Opening:", choices = NULL),
              checkboxInput("custom_jd_toggle", "Use Custom Job Description", value = FALSE),
              
              conditionalPanel(
                condition = "input.custom_jd_toggle == true",
                textAreaInput("custom_jd_text", "Paste Custom Job Description:", 
                              value = "", rows = 8, placeholder = "Enter requirements...")
              ),
              
              textInput("candidate_name", "Candidate Name:", value = "Jane Doe"),
              actionButton("run_matcher_btn", "Calculate ATS Match", 
                           class = "btn-primary btn-lg btn-block", icon = icon("rotate"))
            )
          ),
          
          column(
            width = 8,
            conditionalPanel(
              condition = "input.run_matcher_btn == 0",
              box(
                width = NULL,
                status = "warning",
                style = "text-align: center; padding: 50px 20px;",
                icon("file-arrow-up", class = "fa-4x", style = "color: #D1D5DB; margin-bottom: 20px;"),
                h3("Ready for Analysis"),
                p("Please upload a PDF resume, configure your target job details on the left, and click 'Calculate ATS Match' to start.")
              )
            ),
            
            conditionalPanel(
              condition = "input.run_matcher_btn > 0",
              fluidRow(
                column(
                  width = 6,
                  box(
                    title = "ATS Match Score",
                    width = NULL,
                    status = "success",
                    style = "text-align: center;",
                    uiOutput("score_badge_ui"),
                    h4(tags$b(textOutput("pass_status_text"))),
                    p("Candidate compatibility based on machine learning scoring models.")
                  )
                ),
                column(
                  width = 6,
                  box(
                    title = "ATS Pass Probability",
                    width = NULL,
                    status = "info",
                    withSpinner(plotlyOutput("pass_gauge_plot", height = "150px"), type = 8, color = "#4f46e5"),
                    br(),
                    downloadButton("download_report_btn", "Download Evaluation PDF Report", 
                                   class = "btn-success btn-block")
                  )
                )
              ),
              
              fluidRow(
                column(
                  width = 6,
                  box(
                    title = "Critical Missing Skills in Resume",
                    width = NULL,
                    status = "danger",
                    uiOutput("missing_skills_labels")
                  )
                ),
                column(
                  width = 6,
                  box(
                    title = "Detected Core Skills",
                    width = NULL,
                    status = "success",
                    uiOutput("detected_skills_labels")
                  )
                )
              ),
              
              fluidRow(
                column(
                  width = 6,
                  box(
                    title = "Resume Text Analysis Features",
                    width = NULL,
                    status = "info",
                    withSpinner(tableOutput("resume_features_table"), type = 8, color = "#4f46e5")
                  )
                ),
                column(
                  width = 6,
                  box(
                    title = "Actionable ATS Recommendations",
                    width = NULL,
                    status = "warning",
                    uiOutput("recommendations_list_ui")
                  )
                )
              )
            )
          )
        )
      ),
      
      # --- TAB 3: BATCH ATS MATCHER ---
      tabItem(
        tabName = "batch_matcher",
        fluidRow(
          column(
            width = 4,
            box(
              title = "Batch Configuration",
              width = NULL,
              status = "primary",
              solidHeader = TRUE,
              
              fileInput("batch_files", "Upload Resumes (Multiple PDFs)", multiple = TRUE, accept = c(".pdf")),
              selectInput("batch_role_select", "Select Job Opening:", choices = NULL),
              actionButton("run_batch_btn", "Start Batch Analysis", 
                           class = "btn-primary btn-lg btn-block", icon = icon("play"))
            )
          ),
          
          column(
            width = 8,
            conditionalPanel(
              condition = "input.run_batch_btn == 0",
              box(
                width = NULL,
                status = "warning",
                style = "text-align: center; padding: 50px 20px;",
                icon("folder-open", class = "fa-4x", style = "color: #D1D5DB; margin-bottom: 20px;"),
                h3("Batch Matcher Ready"),
                p("Upload multiple candidate resumes, select a target job position, and start processing.")
              )
            ),
            
            conditionalPanel(
              condition = "input.run_batch_btn > 0",
              box(
                title = "Batch Run Metrics",
                width = NULL,
                status = "success",
                fluidRow(
                  infoBoxOutput("batch_stat_total", width = 4),
                  infoBoxOutput("batch_stat_avg", width = 4),
                  infoBoxOutput("batch_stat_passed", width = 4)
                )
              ),
              box(
                title = "Batch Evaluation Results",
                width = NULL,
                status = "info",
                solidHeader = TRUE,
                withSpinner(DTOutput("batch_results_table"), type = 8, color = "#4f46e5")
              )
            )
          )
        )
      ),
      
      # --- TAB 4: MANAGE JOB OPENINGS ---
      tabItem(
        tabName = "job_manager",
        fluidRow(
          column(
            width = 4,
            box(
              title = "Add Job Opening",
              width = NULL,
              status = "primary",
              solidHeader = TRUE,
              
              textInput("add_jd_title", "Job Title:", value = ""),
              textInput("add_jd_company", "Company Name:", value = ""),
              numericInput("add_jd_exp", "Min Experience (Years):", value = 0, min = 0),
              textAreaInput("add_jd_desc", "Job Description Text:", value = "", rows = 12),
              actionButton("save_jd_btn", "Save Job Opening", class = "btn-primary btn-block")
            )
          ),
          column(
            width = 8,
            box(
              title = "Current Job Openings Directory",
              width = NULL,
              status = "info",
              solidHeader = TRUE,
              withSpinner(DTOutput("job_openings_table"), type = 8, color = "#4f46e5")
            )
          )
        )
      ),
      
      # --- TAB 5: VISUAL ANALYTICS ---
      tabItem(
        tabName = "analytics",
        conditionalPanel(
          condition = "input.run_matcher_btn == 0",
          box(
            width = 12,
            status = "warning",
            style = "text-align: center; padding: 40px 10px;",
            h3("No Data to Visualize"),
            p("Please complete an ATS single match assessment to enable visual charts.")
          )
        ),
        
        conditionalPanel(
          condition = "input.run_matcher_btn > 0",
          fluidRow(
            column(
              width = 6,
              box(
                title = "Resume Word Cloud",
                width = NULL,
                status = "primary",
                withSpinner(plotOutput("resume_wordcloud", height = "350px"), type = 8, color = "#4f46e5")
              )
            ),
            column(
              width = 6,
              box(
                title = "Skills Category Match Coverage",
                width = NULL,
                status = "primary",
                withSpinner(plotlyOutput("skills_radar_plot", height = "350px"), type = 8, color = "#4f46e5")
              )
            )
          ),
          
          fluidRow(
            column(
              width = 6,
              box(
                title = "Experience Benchmark Comparison",
                width = NULL,
                status = "info",
                withSpinner(plotlyOutput("experience_scatter_plot", height = "350px"), type = 8, color = "#4f46e5")
              )
            ),
            column(
              width = 6,
              box(
                title = "Job Role Benchmark Details",
                width = NULL,
                status = "info",
                uiOutput("benchmark_details_ui")
              )
            )
          )
        )
      ),
      
      # --- TAB 6: RESUME OPTIMIZER ---
      tabItem(
        tabName = "optimizer",
        conditionalPanel(
          condition = "input.run_matcher_btn == 0",
          box(
            width = 12,
            status = "warning",
            style = "text-align: center; padding: 40px 10px;",
            h3("No Resume Loaded"),
            p("Run the Single Resume Screener first to check keyword density optimization.")
          )
        ),
        
        conditionalPanel(
          condition = "input.run_matcher_btn > 0",
          fluidRow(
            column(
              width = 7,
              box(
                title = "Keyword Matching Density Profile",
                width = NULL,
                status = "primary",
                withSpinner(plotlyOutput("keyword_density_bar_plot", height = "400px"), type = 8, color = "#4f46e5")
              )
            ),
            column(
              width = 5,
              box(
                title = "Actionable Improvement Suggestions",
                width = NULL,
                status = "warning",
                uiOutput("optimizer_suggestions_ui")
              )
            )
          )
        )
      ),
      
      # --- TAB 7: MODEL PERFORMANCE ---
      tabItem(
        tabName = "performance",
        fluidRow(
          column(
            width = 6,
            box(
              title = "Regression Models Evaluation (Predicting ATS Score)",
              width = NULL,
              status = "primary",
              tableOutput("metrics_reg_table")
            )
          ),
          column(
            width = 6,
            box(
              title = "Classification Models Evaluation (Predicting Pass/Fail status)",
              width = NULL,
              status = "primary",
              tableOutput("metrics_clf_table")
            )
          )
        ),
        fluidRow(
          column(
            width = 7,
            box(
              title = "Random Forest - Feature Importance",
              width = NULL,
              status = "info",
              withSpinner(plotlyOutput("feature_importance_plot", height = "350px"), type = 8, color = "#4f46e5")
            )
          ),
          column(
            width = 5,
            box(
              title = "Model Parameters",
              width = NULL,
              status = "info",
              p(tags$b("Linear Regression:"), " Establishes baseline coefficients."),
              p(tags$b("Decision Tree (rpart):"), " Splits candidate pools into visual branches."),
              p(tags$b("Random Forest:"), " Ensemble model of 100 decision trees (Top model)."),
              p(tags$b("Support Vector Machine (SVM):"), " Maximizes the margin separating passing and failing resumes.")
            )
          )
        )
      ),
      
      # --- TAB 8: ABOUT PROJECT ---
      tabItem(
        tabName = "about",
        fluidRow(
          column(
            width = 12,
            box(
              title = "About Project: Resume ATS Score Analytics",
              width = NULL,
              status = "primary",
              solidHeader = TRUE,
              h3("Overview", style = "font-weight:600;"),
              p("This project is built using R Shiny to create an end-to-end recruitment intelligence system. It utilizes advanced Natural Language Processing (NLP) and Machine Learning techniques to grade professional resumes against complex job descriptions and predict the probability of clearing ATS filters."),
              
              h4("Data Pipeline Architecture", style = "font-weight:600; margin-top:20px;"),
              p("1. PDF Reading: Extracts text from PDFs using pdftools."),
              p("2. Text Cleaning: Normalizes case, removes email, URLs, punctuation, and filters custom stopwords."),
              p("3. Tokenization & Stemming: Applies Porter stemming algorithm for root-word matching."),
              p("4. Similarity Calculation: TF-IDF weights and Cosine Similarity values."),
              p("5. Feature Engineering: Extracts 20+ numerical and categorical indicators."),
              p("6. ML Modeling: Trains Regression & Classification frameworks (Random Forest, SVM, Naive Bayes)."),
              p("7. Report Generation: Automatically builds custom evaluation PDF reports."),
              
              h4("Project Team Details", style = "font-weight:600; margin-top:20px;"),
              tags$ul(
                tags$li("Developer Role: Lead R Shiny Developer & Data Scientist"),
                tags$li("R Version: >= 4.3.2"),
                tags$li("Database: SQLite Backend (RSQLite)")
              )
            )
          )
        )
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  
  # Trigger database refresh reactive val
  db_trigger <- reactiveVal(0)
  
  # --- Dynamic dropdown lists of job openings ---
  job_choices <- reactive({
    db_trigger()
    jds <- get_job_descriptions()
    if (nrow(jds) == 0) return(character(0))
    choices <- jds$title
    names(choices) <- paste0(jds$title, " (", jds$company, ")")
    choices
  })
  
  observe({
    choices <- job_choices()
    updateSelectInput(session, "job_role_select", choices = choices)
    updateSelectInput(session, "batch_role_select", choices = choices)
  })
  
  # --- TAB 1: DASHBOARD OVERVIEW RENDERINGS ---
  
  # Fetch DB metrics
  db_stats_data <- reactive({
    db_trigger()
    get_db_stats()
  })
  
  output$stat_total_resumes <- renderValueBox({
    stats <- db_stats_data()
    valueBox(stats$total, "Total Evaluated Candidates", icon = icon("users"), color = "blue")
  })
  
  output$stat_avg_score <- renderValueBox({
    stats <- db_stats_data()
    valueBox(stats$avg_score, "Average ATS Match Score", icon = icon("ranking-star"), color = "purple")
  })
  
  output$stat_pass_rate <- renderValueBox({
    stats <- db_stats_data()
    valueBox(paste0(stats$pass_rate, "%"), "Candidate Pass Rate (>=70)", icon = icon("square-check"), color = "green")
  })
  
  output$pool_ats_dist_plot <- renderPlotly({
    stats <- db_stats_data()
    db_trigger()
    
    # Query all scores
    con <- db_connect()
    scores <- dbGetQuery(con, "SELECT ats_score FROM evaluations")$ats_score
    dbDisconnect(con)
    
    if (length(scores) == 0) {
      scores <- trained_model_pkg$sample_data$ats_score
    }
    
    fig <- plot_ly(x = ~scores, type = "histogram", 
                   marker = list(color = "#3B82F6", line = list(color = "white", width = 1))) %>%
      layout(
        xaxis = list(title = "ATS Match Score Range", range = c(0, 100)),
        yaxis = list(title = "Frequency"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      )
    fig
  })
  
  output$history_table <- renderDT({
    db_trigger()
    df <- get_evaluation_history()
    if (nrow(df) == 0) {
      # Fallback dummy table if empty
      df <- data.frame(
        ID = 1,
        Candidate = "Jane Doe",
        Role = "Data Scientist",
        Score = 75,
        Probability = 82,
        Status = "Pass",
        Date = "No evaluations recorded"
      )
      return(datatable(df, options = list(pageLength = 5)))
    }
    
    # Render with interactive action button
    df$Action <- sprintf('<button class="btn btn-danger btn-xs delete-btn" onclick="Shiny.setInputValue(\'delete_eval_id\', %d, {priority: \'event\'})"><i class="fa fa-trash"></i> Delete</button>', df$id)
    
    datatable(
      df %>% select(id, candidate_name, target_role, ats_score, pass_probability, pass_fail, evaluated_at, Action),
      escape = FALSE,
      options = list(pageLength = 5, scrollX = TRUE),
      rownames = FALSE,
      colnames = c("ID", "Candidate Name", "Position", "ATS Score", "Pass Prob %", "Screening Status", "Evaluated At", "Actions")
    )
  })
  
  # Handle Delete Action in Datatable
  observeEvent(input$delete_eval_id, {
    delete_evaluation(input$delete_eval_id)
    db_trigger(db_trigger() + 1)
    showNotification("Candidate evaluation record removed from database.", type = "warning")
  })
  
  # --- TAB 2: MATCHER SERVER LOGIC ---
  
  # Run prediction reactively
  predictions_data <- eventReactive(input$run_matcher_btn, {
    req(input$resume_file)
    
    jd_text <- ""
    if (input$custom_jd_toggle) {
      req(input$custom_jd_text)
      jd_text <- input$custom_jd_text
    } else {
      # Load selected JD from DB
      req(input$job_role_select)
      jds <- get_job_descriptions()
      jd_row <- jds %>% filter(title == input$job_role_select) %>% safe_slice(1)
      if (!is.null(jd_row) && nrow(jd_row) > 0) {
        jd_text <- jd_row$description[1]
      } else {
        jd_text <- "Looking for candidate with programming, database, and system analysis skills."
      }
    }
    
    # Show loading progress
    withProgress(message = 'Extracting resume details...', value = 0.1, {
      setProgress(value = 0.4, detail = "Calculating similarity weights...")
      setProgress(value = 0.7, detail = "Running Machine Learning models...")
      
      # Run prediction
      res <- predict_resume_ats(
        resume_path = input$resume_file$datapath,
        jd_text = jd_text,
        target_title = input$job_role_select
      )
      
      setProgress(value = 1.0, detail = "Analysis Complete!")
      
      # Save to SQLite Database automatically
      suggestions <- generate_improvement_suggestions(res)
      
      # Save report path placeholder
      report_filename <- paste("reports/Report_", gsub(" ", "_", input$candidate_name), "_", format(Sys.time(), "%Y%m%d%H%M%S"), ".pdf", sep="")
      
      save_evaluation(
        session_id = session$token,
        candidate_name = input$candidate_name,
        target_role = input$job_role_select,
        resume_filename = input$resume_file$name,
        predictions = res,
        suggestions = suggestions,
        report_path = report_filename
      )
      
      # Trigger db update
      db_trigger(db_trigger() + 1)
      
      res
    })
  })
  
  output$score_badge_ui <- renderUI({
    res <- predictions_data()
    score <- res$ats_score
    status_class <- ifelse(score >= 70, "score-pass", "score-fail")
    div(class = paste("score-badge", status_class), score)
  })
  
  output$pass_status_text <- renderText({
    res <- predictions_data()
    ifelse(res$ats_score >= 70, "PASSED ATS SCREENING", "NEEDS RESUME OPTIMIZATION")
  })
  
  output$pass_gauge_plot <- renderPlotly({
    res <- predictions_data()
    prob <- res$pass_probability
    
    plot_ly(
      type = "indicator",
      mode = "gauge+number",
      value = prob,
      number = list(suffix = "%", font = list(size = 20)),
      gauge = list(
        axis = list(range = list(NULL, 100)),
        bar = list(color = ifelse(prob >= 70, "#10B981", "#EF4444")),
        bgcolor = "white",
        borderwidth = 1,
        bordercolor = "gray"
      ),
      height = 120
    ) %>% layout(margin = list(l=20, r=20, t=10, b=10))
  })
  
  output$missing_skills_labels <- renderUI({
    res <- predictions_data()
    if (length(res$missing_skills) == 0) {
      return(p("No missing high-priority skills found! Excellent matches.", style="color:#059669;"))
    }
    tags$div(
      lapply(res$missing_skills, function(sk) {
        span(class = "skill-badge skill-tag-missing", sk)
      })
    )
  })
  
  output$detected_skills_labels <- renderUI({
    res <- predictions_data()
    if (length(res$detected_skills) == 0) {
      return(p("No core technical skills detected. Please enrich resume text.", style="color:#DC2626;"))
    }
    tags$div(
      lapply(res$detected_skills, function(sk) {
        span(class = "skill-badge skill-tag-detected", sk)
      })
    )
  })
  
  output$resume_features_table <- renderTable({
    res <- predictions_data()
    feats <- res$features
    
    data.frame(
      Feature = c("Work Experience", "Education Level", "Keyword Match %", "Cosine Similarity", "Action Verbs Count", "Certifications Count"),
      Value = c(
        paste(feats$experience_years, "Years"),
        as.character(feats$education_level),
        paste(round(feats$keyword_match_percent, 1), "%"),
        round(feats$cosine_similarity, 4),
        feats$action_verbs_count,
        feats$certs_count
      )
    )
  })
  
  output$recommendations_list_ui <- renderUI({
    res <- predictions_data()
    sugs <- generate_improvement_suggestions(res)
    tags$ul(
      lapply(sugs, function(sug) {
        tags$li(sug, style="margin-bottom:8px; font-size:13px;")
      })
    )
  })
  
  # PDF report downloader
  output$download_report_btn <- downloadHandler(
    filename = function() {
      paste("ATS_Assessment_Report_", gsub(" ", "_", input$candidate_name), ".pdf", sep = "")
    },
    content = function(file) {
      res <- predictions_data()
      generate_resume_pdf_report(
        candidate_name = input$candidate_name,
        target_role = input$job_role_select,
        predictions = res,
        filepath = file
      )
    }
  )
  
  # --- TAB 3: BATCH ATS MATCHER SERVER LOGIC ---
  
  batch_results_reactive <- eventReactive(input$run_batch_btn, {
    req(input$batch_files)
    req(input$batch_role_select)
    
    files <- input$batch_files
    n_files <- nrow(files)
    
    # Load selected JD
    jds <- get_job_descriptions()
    jd_row <- jds %>% filter(title == input$batch_role_select) %>% safe_slice(1)
    jd_text <- ifelse(!is.null(jd_row) && nrow(jd_row) > 0, jd_row$description[1], "Standard Job Description")
    
    results <- list()
    
    withProgress(message = 'Processing batch resumes...', value = 0, {
      for (i in 1:n_files) {
        setProgress(value = i/n_files, detail = paste("Analyzing", files$name[i]))
        
        # Candidate name from filename
        c_name <- tools::file_path_sans_ext(files$name[i])
        c_name <- gsub("[_-]", " ", c_name)
        c_name <- tools::toTitleCase(c_name)
        
        res <- tryCatch({
          predict_resume_ats(
            resume_path = files$datapath[i],
            jd_text = jd_text,
            target_title = input$batch_role_select
          )
        }, error = function(e) {
          # Return mock/failed structure on error
          list(ats_score = 0, pass_probability = 0, missing_skills = c("Error parsing PDF"), features = data.frame(experience_years=0))
        })
        
        # Save evaluation to db
        sugs <- if (res$ats_score > 0) generate_improvement_suggestions(res) else "Parsing failed"
        save_evaluation(
          session_id = session$token,
          candidate_name = c_name,
          target_role = input$batch_role_select,
          resume_filename = files$name[i],
          predictions = res,
          suggestions = sugs,
          report_path = NA
        )
        
        results[[i]] <- data.frame(
          Filename = files$name[i],
          Candidate = c_name,
          Score = res$ats_score,
          PassProb = res$pass_probability,
          Status = ifelse(res$ats_score >= 70, "Pass", "Fail"),
          stringsAsFactors = FALSE
        )
      }
    })
    
    # Save batch summary to db
    df_res <- bind_rows(results)
    avg_ats <- mean(df_res$Score)
    pass_cnt <- sum(df_res$Status == "Pass")
    fail_cnt <- sum(df_res$Status == "Fail")
    
    save_batch_job(
      job_name = paste("Batch Assessment -", format(Sys.time(), "%Y-%m-%d %H:%M")),
      total_resumes = n_files,
      avg_ats = avg_ats,
      pass_count = pass_cnt,
      fail_count = fail_cnt,
      target_role = input$batch_role_select
    )
    
    db_trigger(db_trigger() + 1)
    df_res
  })
  
  output$batch_stat_total <- renderInfoBox({
    df <- batch_results_reactive()
    infoBox("Total Resumes", nrow(df), icon = icon("users"), color = "blue", fill = TRUE)
  })
  
  output$batch_stat_avg <- renderInfoBox({
    df <- batch_results_reactive()
    infoBox("Avg Batch Score", round(mean(df$Score), 1), icon = icon("ranking-star"), color = "purple", fill = TRUE)
  })
  
  output$batch_stat_passed <- renderInfoBox({
    df <- batch_results_reactive()
    passed <- sum(df$Status == "Pass")
    infoBox("Passed Count", passed, icon = icon("square-check"), color = "green", fill = TRUE)
  })
  
  output$batch_results_table <- renderDT({
    df <- batch_results_reactive()
    datatable(df, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })
  
  # --- TAB 4: JOB OPENINGS MANAGER SERVER ---
  
  output$job_openings_table <- renderDT({
    db_trigger()
    df <- get_job_descriptions()
    if (nrow(df) == 0) return(datatable(data.frame(Message="No jobs configured.")))
    
    datatable(
      df %>% select(title, company, min_experience, created_at),
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE,
      colnames = c("Job Position", "Company", "Min Experience (Yrs)", "Date Created")
    )
  })
  
  observeEvent(input$save_jd_btn, {
    req(input$add_jd_title)
    req(input$add_jd_desc)
    
    add_job_description(
      title = input$add_jd_title,
      description = input$add_jd_desc,
      company = input$add_jd_company,
      min_experience = input$add_jd_exp
    )
    
    # Clear fields
    updateTextInput(session, "add_jd_title", value = "")
    updateTextInput(session, "add_jd_company", value = "")
    updateNumericInput(session, "add_jd_exp", value = 0)
    updateTextAreaInput(session, "add_jd_desc", value = "")
    
    showNotification("Job position added successfully!", type = "message")
    db_trigger(db_trigger() + 1)
  })
  
  # --- TAB 5: VISUAL ANALYTICS SERVER LOGIC ---
  
  output$resume_wordcloud <- renderPlot({
    req(input$resume_file)
    res <- predictions_data()
    stopwords_df <- read_csv("data/stopwords.csv", show_col_types = FALSE)
    custom_stopwords <- stopwords_df$word
    
    # Plot wordcloud
    clean_res <- clean_text_raw(extract_text_from_pdf(input$resume_file$datapath))
    words <- tokenize_text(clean_res)
    words <- words[!words %in% custom_stopwords]
    
    word_freqs <- table(words)
    wordcloud(names(word_freqs), as.numeric(word_freqs), max.words = 40, colors = brewer.pal(8, "Dark2"))
  })
  
  output$skills_radar_plot <- renderPlotly({
    res <- predictions_data()
    feats <- res$features
    
    categories <- c("Programming", "Cloud", "Databases", "Machine Learning", "Data Analytics")
    values <- c(
      feats$prog_skills_count,
      feats$cloud_skills_count,
      feats$db_skills_count,
      feats$ai_skills_count,
      feats$analytics_skills_count
    )
    
    # Scale scores out of 10 for a cleaner plot
    values_scaled <- pmin(10, values * 2)
    
    fig <- plot_ly(
      type = 'scatterpolar',
      r = values_scaled,
      theta = categories,
      fill = 'toself',
      fillcolor = 'rgba(59, 130, 246, 0.4)',
      line = list(color = '#3B82F6')
    ) %>% layout(
      polar = list(radialaxis = list(visible = TRUE, range = c(0, 10))),
      showlegend = FALSE,
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor = "rgba(0,0,0,0)"
    )
    fig
  })
  
  output$experience_scatter_plot <- renderPlotly({
    res <- predictions_data()
    c_exp <- res$features$experience_years
    c_score <- res$ats_score
    
    # Benchmark roles dataset
    bench_data <- trained_model_pkg$sample_data
    
    fig <- plot_ly(data = bench_data, x = ~experience_years, y = ~ats_score, type = "scatter", mode = "markers",
                   marker = list(size = 8, color = "#94A3B8", opacity = 0.7), name = "Evaluated Candidates") %>%
      add_trace(x = c_exp, y = c_score, type = "scatter", mode = "markers",
                marker = list(size = 14, color = "#10B981", line = list(color = "white", width = 2)), name = "Your Resume") %>%
      layout(
        xaxis = list(title = "Experience (Years)"),
        yaxis = list(title = "ATS Match Score"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      )
    fig
  })
  
  output$benchmark_details_ui <- renderUI({
    req(input$job_role_select)
    bench <- get_role_benchmarks(input$job_role_select)
    
    div(
      h4(tags$b(input$job_role_select)),
      p(tags$b("Salary Benchmark: "), bench$salary),
      p(tags$b("Market Demand: "), bench$demand),
      p(tags$b("Role Description: "), bench$description),
      hr(),
      h5(tags$b("Key Skills demanded in this opening:")),
      tags$ul(lapply(bench$skills, tags$li))
    )
  })
  
  # --- TAB 6: RESUME OPTIMIZER SERVER ---
  
  output$keyword_density_bar_plot <- renderPlotly({
    res <- predictions_data()
    kws <- res$matched_keywords
    
    if (length(kws) == 0) return(NULL)
    
    # Count keyword frequencies inside the resume
    clean_res <- clean_text_raw(extract_text_from_pdf(input$resume_file$datapath))
    words <- tokenize_text(clean_res)
    freqs <- sapply(kws, function(w) sum(words == tolower(w)))
    
    df_kw <- data.frame(Keyword = kws, Frequency = as.numeric(freqs)) %>%
      arrange(desc(Frequency)) %>% head(12)
    
    fig <- plot_ly(df_kw, x = ~Frequency, y = ~reorder(Keyword, Frequency), type = "bar",
                   marker = list(color = "#10B981")) %>%
      layout(
        yaxis = list(title = "Matched Term"),
        xaxis = list(title = "Keyword Frequency in Resume"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      )
    fig
  })
  
  output$optimizer_suggestions_ui <- renderUI({
    res <- predictions_data()
    sugs <- generate_improvement_suggestions(res)
    
    tags$div(
      h4(tags$b("Resume Quality Audit Checklist:")),
      hr(),
      tags$ul(
        lapply(sugs, function(sug) {
          tags$li(sug, style = "margin-bottom: 12px; line-height: 1.5; font-size:13.5px;")
        })
      )
    )
  })
  
  # --- TAB 7: MODEL PERFORMANCE SERVER ---
  
  output$metrics_reg_table <- renderTable({
    trained_model_pkg$reg_metrics
  })
  
  output$metrics_clf_table <- renderTable({
    trained_model_pkg$clf_metrics
  })
  
  output$feature_importance_plot <- renderPlotly({
    imp <- as.data.frame(trained_model_pkg$feature_importance)
    # Check column names
    col_names <- colnames(imp)
    val_col <- if ("%IncMSE" %in% col_names) "%IncMSE" else col_names[1]
    imp$Feature <- rownames(imp)
    imp$Importance <- imp[[val_col]]
    
    imp <- imp %>% arrange(desc(Importance)) %>% head(10)
    
    fig <- plot_ly(imp, x = ~Importance, y = ~reorder(Feature, Importance), type = "bar",
                   marker = list(color = "#8B5CF6")) %>%
      layout(
        yaxis = list(title = "Predictive Indicator"),
        xaxis = list(title = "Feature Importance Weight"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      )
    fig
  })
  
}

shinyApp(ui, server)
