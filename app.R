# ==============================================================================
# app.R - TalentScan ATS™ | Enterprise Candidate Screening & Analytics Engine
# Production-Quality R Shiny Application for Technical Recruitment & Resume Scoring
# ==============================================================================

source("global.R")

# ------------------------------------------------------------------------------
# 1. DESIGN SYSTEM & PROFESSIONAL ENTERPRISE STYLESHEET (STRICTLY NON-AI AESTHETIC)
# ------------------------------------------------------------------------------
enterprise_css <- "
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

  :root {
    --slate-50:  #f8fafc;
    --slate-100: #f1f5f9;
    --slate-200: #e2e8f0;
    --slate-300: #cbd5e1;
    --slate-400: #94a3b8;
    --slate-500: #64748b;
    --slate-600: #475569;
    --slate-700: #334155;
    --slate-800: #1e293b;
    --slate-900: #0f172a;

    --brand-primary: #1e3a8a;
    --brand-hover:   #1d4ed8;
    --brand-accent:  #2563eb;
    --brand-subtle:  #eff6ff;

    --success-bg:     #ecfdf5;
    --success-border: #a7f3d0;
    --success-text:   #065f46;
    --success-solid:  #059669;

    --warning-bg:     #fffbeb;
    --warning-border: #fde68a;
    --warning-text:   #92400e;
    --warning-solid:  #d97706;

    --danger-bg:      #fef2f2;
    --danger-border:  #fecaca;
    --danger-text:    #991b1b;
    --danger-solid:   #dc2626;

    --radius-sm: 4px;
    --radius-md: 6px;
    --radius-lg: 8px;
    --radius-xl: 12px;

    --shadow-subtle: 0 1px 2px 0 rgba(15, 23, 42, 0.05);
    --shadow-card:   0 1px 3px 0 rgba(15, 23, 42, 0.06), 0 1px 2px -1px rgba(15, 23, 42, 0.04);
    --shadow-modal:  0 10px 25px -5px rgba(15, 23, 42, 0.12), 0 8px 10px -6px rgba(15, 23, 42, 0.08);
  }

  /* Base Typography & Background */
  body, .wrapper, .main-sidebar, .left-side, .content-wrapper {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif !important;
    background-color: var(--slate-50) !important;
    color: var(--slate-800);
    -webkit-font-smoothing: antialiased;
  }

  /* Header Branding */
  .main-header {
    border-bottom: 1px solid var(--slate-800) !important;
  }
  .main-header .logo {
    background-color: var(--slate-900) !important;
    color: #ffffff !important;
    font-weight: 700 !important;
    font-size: 16px !important;
    letter-spacing: -0.02em;
    border-right: 1px solid var(--slate-800) !important;
    height: 54px !important;
    line-height: 54px !important;
    text-align: left !important;
    padding-left: 20px !important;
  }
  .main-header .navbar {
    background-color: var(--slate-900) !important;
    min-height: 54px !important;
  }
  .main-header .sidebar-toggle {
    color: var(--slate-300) !important;
    height: 54px !important;
    line-height: 54px !important;
    padding: 0 18px !important;
  }
  .main-header .sidebar-toggle:hover {
    background-color: var(--slate-800) !important;
    color: #ffffff !important;
  }

  /* Sidebar Navigation */
  .main-sidebar {
    background-color: var(--slate-900) !important;
    border-right: 1px solid var(--slate-800) !important;
    padding-top: 54px !important;
  }
  .sidebar-menu > li > a {
    font-size: 13.5px !important;
    font-weight: 500 !important;
    color: var(--slate-400) !important;
    border-left: 3px solid transparent !important;
    padding: 12px 18px !important;
    transition: all 0.15s ease-in-out;
  }
  .sidebar-menu > li:hover > a,
  .sidebar-menu > li.active > a {
    color: #ffffff !important;
    background-color: var(--slate-800) !important;
    border-left-color: var(--brand-accent) !important;
  }
  .sidebar-menu > li > a > i {
    width: 22px;
    margin-right: 8px;
    font-size: 14px;
    color: var(--slate-400);
  }
  .sidebar-menu > li.active > a > i,
  .sidebar-menu > li:hover > a > i {
    color: #ffffff !important;
  }

  /* Content Wrapper */
  .content-wrapper {
    padding: 10px 15px 30px 15px !important;
  }

  /* Executive Cards / Boxes */
  .box {
    background: #ffffff !important;
    border: 1px solid var(--slate-200) !important;
    border-radius: var(--radius-lg) !important;
    box-shadow: var(--shadow-card) !important;
    margin-bottom: 20px !important;
    border-top: none !important;
  }
  .box-header {
    border-bottom: 1px solid var(--slate-100) !important;
    padding: 14px 18px !important;
    background: #ffffff !important;
    border-top-left-radius: var(--radius-lg);
    border-top-right-radius: var(--radius-lg);
  }
  .box-title {
    font-size: 14.5px !important;
    font-weight: 600 !important;
    color: var(--slate-900) !important;
    letter-spacing: -0.01em;
  }
  .box-body {
    padding: 18px !important;
  }

  /* Form Elements */
  .form-group label {
    font-size: 13px !important;
    font-weight: 600 !important;
    color: var(--slate-700) !important;
    margin-bottom: 6px !important;
    letter-spacing: -0.01em;
  }
  .form-control, .selectize-input {
    border: 1px solid var(--slate-300) !important;
    border-radius: var(--radius-md) !important;
    font-size: 13.5px !important;
    color: var(--slate-800) !important;
    background-color: #ffffff !important;
    box-shadow: none !important;
    padding: 8px 12px !important;
    min-height: 38px !important;
    transition: border-color 0.15s ease, box-shadow 0.15s ease;
  }
  .form-control:focus, .selectize-input.focus {
    border-color: var(--brand-accent) !important;
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12) !important;
    outline: none !important;
  }
  .selectize-dropdown {
    border: 1px solid var(--slate-200) !important;
    border-radius: var(--radius-md) !important;
    box-shadow: var(--shadow-modal) !important;
  }

  /* Buttons */
  .btn {
    border-radius: var(--radius-md) !important;
    font-weight: 500 !important;
    font-size: 13.5px !important;
    padding: 8px 16px !important;
    transition: all 0.15s ease-in-out !important;
    cursor: pointer;
  }
  .btn-primary {
    background-color: var(--brand-primary) !important;
    border-color: var(--brand-primary) !important;
    color: #ffffff !important;
  }
  .btn-primary:hover, .btn-primary:focus {
    background-color: var(--brand-hover) !important;
    border-color: var(--brand-hover) !important;
    color: #ffffff !important;
    box-shadow: 0 2px 6px rgba(30, 58, 138, 0.25) !important;
  }
  .btn-success {
    background-color: var(--success-solid) !important;
    border-color: var(--success-solid) !important;
    color: #ffffff !important;
  }
  .btn-success:hover {
    background-color: #047857 !important;
    border-color: #047857 !important;
    box-shadow: 0 2px 6px rgba(5, 150, 105, 0.25) !important;
  }
  .btn-default {
    background-color: #ffffff !important;
    border-color: var(--slate-300) !important;
    color: var(--slate-700) !important;
  }
  .btn-default:hover {
    background-color: var(--slate-100) !important;
    color: var(--slate-900) !important;
  }
  .btn-danger {
    background-color: var(--danger-solid) !important;
    border-color: var(--danger-solid) !important;
    color: #ffffff !important;
  }

  /* Executive KPI Card Widget */
  .kpi-card {
    background: #ffffff;
    border: 1px solid var(--slate-200);
    border-radius: var(--radius-lg);
    padding: 18px 20px;
    box-shadow: var(--shadow-card);
    margin-bottom: 20px;
    position: relative;
    overflow: hidden;
  }
  .kpi-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 4px;
    height: 100%;
    background-color: var(--slate-300);
  }
  .kpi-card.kpi-primary::before { background-color: var(--brand-accent); }
  .kpi-card.kpi-success::before { background-color: var(--success-solid); }
  .kpi-card.kpi-warning::before { background-color: var(--warning-solid); }

  .kpi-label {
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--slate-500);
    margin-bottom: 6px;
  }
  .kpi-value {
    font-size: 28px;
    font-weight: 700;
    color: var(--slate-900);
    line-height: 1.1;
  }
  .kpi-subtext {
    font-size: 12.5px;
    color: var(--slate-500);
    margin-top: 6px;
  }
  .kpi-icon {
    position: absolute;
    right: 20px;
    top: 22px;
    font-size: 26px;
    color: var(--slate-300);
  }

  /* Candidate Evaluation Scorecard */
  .scorecard-banner {
    background: var(--slate-50);
    border: 1px solid var(--slate-200);
    border-radius: var(--radius-lg);
    padding: 20px;
    text-align: center;
    margin-bottom: 18px;
  }
  .scorecard-number {
    font-size: 46px;
    font-weight: 800;
    line-height: 1;
    margin-bottom: 6px;
  }
  .scorecard-number.pass { color: var(--success-solid); }
  .scorecard-number.fail { color: var(--danger-solid); }
  .scorecard-rating-chip {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 9999px;
    font-size: 12.5px;
    font-weight: 600;
    letter-spacing: 0.02em;
    text-transform: uppercase;
  }
  .rating-qualified {
    background-color: var(--success-bg);
    color: var(--success-text);
    border: 1px solid var(--success-border);
  }
  .rating-review {
    background-color: var(--warning-bg);
    color: var(--warning-text);
    border: 1px solid var(--warning-border);
  }
  .rating-disqualified {
    background-color: var(--danger-bg);
    color: var(--danger-text);
    border: 1px solid var(--danger-border);
  }

  /* Metric Stat Grid */
  .metric-mini-card {
    background: #ffffff;
    border: 1px solid var(--slate-200);
    border-radius: var(--radius-md);
    padding: 12px 14px;
    text-align: center;
    margin-bottom: 12px;
  }
  .metric-mini-label {
    font-size: 11.5px;
    font-weight: 600;
    text-transform: uppercase;
    color: var(--slate-500);
    letter-spacing: 0.03em;
  }
  .metric-mini-val {
    font-size: 18px;
    font-weight: 700;
    color: var(--slate-900);
    margin-top: 4px;
  }

  /* Skill Badge Chips */
  .skill-badge {
    display: inline-block;
    padding: 5px 12px;
    margin: 3px 4px 3px 0;
    font-size: 12.5px;
    font-weight: 500;
    border-radius: var(--radius-md);
    line-height: 1.4;
  }
  .skill-tag-detected {
    background-color: var(--success-bg);
    color: var(--success-text);
    border: 1px solid var(--success-border);
  }
  .skill-tag-missing {
    background-color: var(--danger-bg);
    color: var(--danger-text);
    border: 1px solid var(--danger-border);
  }

  /* Recommendation Checklist */
  .rec-item {
    background: var(--slate-50);
    border: 1px solid var(--slate-200);
    border-left: 3px solid var(--brand-accent);
    border-radius: var(--radius-sm);
    padding: 10px 14px;
    margin-bottom: 10px;
    font-size: 13px;
    color: var(--slate-700);
    line-height: 1.45;
  }
  .rec-item.critical {
    border-left-color: var(--danger-solid);
    background: #fffafa;
  }
  .rec-item.advisory {
    border-left-color: var(--warning-solid);
  }

  /* Live Job Preview Box */
  .job-preview-card {
    background: var(--slate-50);
    border: 1px solid var(--slate-200);
    border-radius: var(--radius-md);
    padding: 14px;
    margin-top: 12px;
    font-size: 12.5px;
  }
  .job-preview-title {
    font-weight: 700;
    font-size: 14px;
    color: var(--slate-900);
  }
  .job-preview-company {
    color: var(--slate-500);
    font-size: 12px;
    margin-bottom: 8px;
  }

  /* Empty State Containers */
  .empty-state-box {
    text-align: center;
    padding: 55px 25px;
    background: #ffffff;
    border: 1px dashed var(--slate-300);
    border-radius: var(--radius-lg);
    margin: 15px 0;
  }
  .empty-state-icon {
    font-size: 42px;
    color: var(--slate-400);
    margin-bottom: 16px;
  }
  .empty-state-title {
    font-size: 17px;
    font-weight: 600;
    color: var(--slate-800);
    margin-bottom: 8px;
  }
  .empty-state-desc {
    font-size: 13.5px;
    color: var(--slate-500);
    max-width: 480px;
    margin: 0 auto 20px auto;
    line-height: 1.5;
  }

  /* DataTables Modernization */
  table.dataTable {
    border-collapse: separate !important;
    border-spacing: 0 !important;
    border: 1px solid var(--slate-200) !important;
    border-radius: var(--radius-md) !important;
    overflow: hidden;
  }
  table.dataTable thead th {
    background-color: var(--slate-100) !important;
    color: var(--slate-700) !important;
    font-weight: 600 !important;
    font-size: 12.5px !important;
    text-transform: uppercase;
    letter-spacing: 0.03em;
    border-bottom: 1px solid var(--slate-200) !important;
    padding: 12px 14px !important;
  }
  table.dataTable tbody td {
    padding: 12px 14px !important;
    font-size: 13.5px !important;
    color: var(--slate-800) !important;
    border-top: 1px solid var(--slate-100) !important;
    vertical-align: middle !important;
  }
  table.dataTable.stripe tbody tr.odd {
    background-color: #ffffff !important;
  }
  table.dataTable.stripe tbody tr.even {
    background-color: var(--slate-50) !important;
  }
  table.dataTable tbody tr:hover {
    background-color: #f1f5f9 !important;
  }

  /* Modal Styling */
  .modal-content {
    border-radius: var(--radius-lg) !important;
    border: 1px solid var(--slate-200) !important;
    box-shadow: var(--shadow-modal) !important;
  }
  .modal-header {
    background-color: var(--slate-900) !important;
    color: #ffffff !important;
    border-top-left-radius: var(--radius-lg) !important;
    border-top-right-radius: var(--radius-lg) !important;
    padding: 16px 20px !important;
  }
  .modal-header .modal-title {
    font-weight: 600 !important;
    font-size: 16px !important;
  }
  .modal-header .close {
    color: #ffffff !important;
    opacity: 0.8 !important;
  }
  .modal-body {
    padding: 22px !important;
  }
  .modal-footer {
    border-top: 1px solid var(--slate-200) !important;
    padding: 14px 20px !important;
  }
"

# ------------------------------------------------------------------------------
# 2. USER INTERFACE SPECIFICATION
# ------------------------------------------------------------------------------
ui <- dashboardPage(
  skin = "black",
  title = "TalentScan ATS - Enterprise Recruitment & Resume Intelligence",

  # Main Executive Header
  dashboardHeader(
    title = tags$span(
      tags$i(class = "fa-solid fa-layer-group", style = "margin-right: 8px; color: #3b82f6;"),
      "TalentScan ATS™"
    ),
    titleWidth = 250
  ),

  # Main Navigation Sidebar
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      id = "sidebar_tabs",
      menuItem("Dashboard Overview",       tabName = "dashboard",       icon = icon("table-columns")),
      menuItem("Single Resume Screener",   tabName = "matcher",         icon = icon("file-lines")),
      menuItem("Batch Candidate Screener", tabName = "batch_matcher",   icon = icon("users-viewfinder")),
      menuItem("Manage Job Openings",      tabName = "job_manager",     icon = icon("briefcase")),
      menuItem("Visual Fit Analytics",     tabName = "analytics",       icon = icon("chart-simple")),
      menuItem("Structure & Keyword Audit",tabName = "optimizer",       icon = icon("list-check")),
      menuItem("Model Performance & ML",   tabName = "performance",     icon = icon("sliders")),
      menuItem("System Architecture",      tabName = "about",           icon = icon("circle-info"))
    )
  ),

  # Main Body Canvas
  dashboardBody(
    shinyjs::useShinyjs(),
    tags$head(
      tags$style(HTML(enterprise_css)),
      tags$title("TalentScan ATS - Enterprise Recruitment & Resume Intelligence")
    ),

    tabItems(

      # ========================================================================
      # TAB 1: DASHBOARD OVERVIEW
      # ========================================================================
      tabItem(
        tabName = "dashboard",

        # Header Title and Action Bar
        fluidRow(
          column(
            width = 8,
            h2("Recruitment Screening & Evaluation Intelligence",
               style = "margin-top: 0; font-weight: 700; color: #0f172a; font-size: 22px;"),
            p("Centralized database monitoring candidate evaluations, match distributions, and ATS filter clearance rates.",
              style = "color: #64748b; font-size: 14px; margin-bottom: 20px;")
          ),
          column(
            width = 4,
            div(
              style = "text-align: right; margin-top: 5px; margin-bottom: 15px;",
              actionButton("go_to_matcher_btn", "Screen Candidate Now",
                           icon = icon("plus"), class = "btn-primary", style = "margin-right: 6px;"),
              downloadButton("export_db_btn", "Export CSV", class = "btn-default")
            )
          )
        ),

        # 3 Executive Metric Tiles
        fluidRow(
          column(
            width = 4,
            uiOutput("kpi_total_resumes_ui")
          ),
          column(
            width = 4,
            uiOutput("kpi_avg_score_ui")
          ),
          column(
            width = 4,
            uiOutput("kpi_pass_rate_ui")
          )
        ),

        # Score Distribution & Setup Quick Links
        fluidRow(
          column(
            width = 8,
            box(
              title = "Applicant Pool Match Score Distribution",
              width = NULL,
              withSpinner(plotlyOutput("pool_ats_dist_plot", height = "320px"), type = 8, color = "#2563eb")
            )
          ),
          column(
            width = 4,
            box(
              title = "Active Job Openings Snapshot",
              width = NULL,
              uiOutput("active_jobs_snapshot_ui")
            )
          )
        ),

        # Evaluation History Datatable
        fluidRow(
          column(
            width = 12,
            box(
              title = "Historical Candidate Evaluations Log",
              width = NULL,
              div(
                style = "margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center;",
                p("Auditable log of all evaluated resumes stored in local SQLite database.",
                  style = "margin: 0; color: #64748b; font-size: 13px;"),
                actionButton("clear_history_prompt_btn", "Clear All Records",
                             icon = icon("trash-can"), class = "btn-default btn-sm",
                             style = "color: #dc2626; border-color: #fecaca;")
              ),
              withSpinner(DTOutput("history_table"), type = 8, color = "#2563eb")
            )
          )
        )
      ),

      # ========================================================================
      # TAB 2: SINGLE RESUME SCREENER
      # ========================================================================
      tabItem(
        tabName = "matcher",

        fluidRow(
          # Left Column: Configuration Controls
          column(
            width = 4,
            box(
              title = "Screening Configuration",
              width = NULL,

              # Candidate Input Source Selector
              radioButtons(
                "input_source_mode",
                "Resume Input Source:",
                choices = c(
                  "Upload Custom PDF Resume" = "upload",
                  "Load Pre-packaged Sample Candidate" = "sample"
                ),
                selected = "upload"
              ),

              conditionalPanel(
                condition = "input.input_source_mode == 'sample'",
                selectInput(
                  "sample_resume_choice",
                  "Choose Sample Candidate:",
                  choices = c(
                    "Senior Data Scientist (John Doe)" = "sample_data_scientist.pdf",
                    "Senior DevOps Engineer (Jane Smith)" = "sample_devops_engineer.pdf",
                    "Full Stack Developer / SDE (Raghu Bharathi K P)" = "sample_sde_fullstack.pdf"
                  ),
                  selectize = FALSE
                )
              ),

              conditionalPanel(
                condition = "input.input_source_mode == 'upload'",
                fileInput("resume_file", "Select Candidate PDF Resume:",
                          accept = c(".pdf"),
                          buttonLabel = "Browse...",
                          placeholder = "No PDF file selected")
              ),

              textInput("candidate_name", "Candidate Name:", value = "Jane Doe"),

              hr(style = "margin: 14px 0; border-color: #e2e8f0;"),

              # Job Opening Target Selector
              selectInput("job_role_select", "Target Job Opening:", choices = NULL, selectize = FALSE),

              checkboxInput("custom_jd_toggle", "Use Custom Job Description Text", value = FALSE),

              conditionalPanel(
                condition = "input.custom_jd_toggle == true",
                textAreaInput("custom_jd_text", "Paste Target Job Description:",
                              value = "", rows = 8,
                              placeholder = "Paste full job requirements, required technologies, experience level...")
              ),

              conditionalPanel(
                condition = "input.custom_jd_toggle == false",
                uiOutput("selected_jd_preview_ui")
              ),

              br(),
              actionButton("run_matcher_btn", "Calculate ATS Compatibility",
                           class = "btn-primary btn-block", icon = icon("calculator"),
                           style = "padding: 12px 18px !important; font-size: 14.5px !important;")
            )
          ),

          # Right Column: Detailed Match Results
          column(
            width = 8,

            # Empty State
            conditionalPanel(
              condition = "output.matcher_has_run == false",
              div(
                class = "empty-state-box",
                tags$i(class = "fa-regular fa-file-pdf empty-state-icon"),
                div(class = "empty-state-title", "Candidate Screener Ready"),
                div(class = "empty-state-desc",
                    "Configure candidate details and target role on the left, then click 'Calculate ATS Compatibility' to run the NLP matching and Machine Learning evaluation engine."),
                actionButton("quick_sample_eval_btn", "Run Sample Analysis (Senior Data Scientist)",
                             class = "btn-default", icon = icon("bolt"))
              )
            ),

            # Populated Results
            conditionalPanel(
              condition = "output.matcher_has_run == true",

              # Row 1: Executive Scorecard Banner
              box(
                width = NULL,
                fluidRow(
                  column(
                    width = 4,
                    div(
                      style = "text-align: center; padding: 10px;",
                      uiOutput("score_number_ui"),
                      div(
                        style = "margin-top: 6px;",
                        uiOutput("score_rating_chip_ui")
                      )
                    )
                  ),
                  column(
                    width = 8,
                    div(
                      style = "padding: 5px 15px;",
                      h4("Pass Probability vs. Automated Filter Threshold",
                         style = "font-weight: 600; font-size: 14px; margin-top: 0; color: #0f172a;"),
                      withSpinner(plotlyOutput("pass_gauge_plot", height = "100px"), type = 8, color = "#2563eb"),
                      div(
                        style = "display: flex; justify-content: space-between; align-items: center; margin-top: 8px;",
                        span("Automated threshold: 70% confidence", style = "font-size: 12px; color: #64748b;"),
                        downloadButton("download_report_btn", "Download Evaluation Report (PDF)",
                                       class = "btn-success btn-sm", icon = icon("file-arrow-down"))
                      )
                    )
                  )
                )
              ),

              # Row 2: 4 Key Metric Tiles
              fluidRow(
                column(width = 3, uiOutput("metric_exp_fit_ui")),
                column(width = 3, uiOutput("metric_edu_fit_ui")),
                column(width = 3, uiOutput("metric_kw_fit_ui")),
                column(width = 3, uiOutput("metric_read_fit_ui"))
              ),

              # Row 3: Skills Gap Analysis
              fluidRow(
                column(
                  width = 6,
                  box(
                    title = tags$span(
                      tags$i(class = "fa-solid fa-triangle-exclamation", style = "color: #dc2626; margin-right: 6px;"),
                      "Missing Role Requirements (Gaps)"
                    ),
                    width = NULL,
                    uiOutput("missing_skills_labels")
                  )
                ),
                column(
                  width = 6,
                  box(
                    title = tags$span(
                      tags$i(class = "fa-solid fa-circle-check", style = "color: #059669; margin-right: 6px;"),
                      "Detected Core Technical Competencies"
                    ),
                    width = NULL,
                    uiOutput("detected_skills_labels")
                  )
                )
              ),

              # Row 4: Actionable Recommendations
              fluidRow(
                column(
                  width = 12,
                  box(
                    title = tags$span(
                      tags$i(class = "fa-solid fa-clipboard-list", style = "color: #2563eb; margin-right: 6px;"),
                      "Actionable Resume Remediation Checklist"
                    ),
                    width = NULL,
                    uiOutput("recommendations_list_ui")
                  )
                )
              )
            )
          )
        )
      ),

      # ========================================================================
      # TAB 3: BATCH CANDIDATE SCREENER
      # ========================================================================
      tabItem(
        tabName = "batch_matcher",

        fluidRow(
          column(
            width = 4,
            box(
              title = "Batch Pipeline Configuration",
              width = NULL,

              radioButtons(
                "batch_source_mode",
                "Candidate Batch Selection:",
                choices = c(
                  "Upload Multiple PDF Resumes" = "upload",
                  "Load Pre-packaged Sample Candidate Pool" = "sample"
                ),
                selected = "sample"
              ),

              conditionalPanel(
                condition = "input.batch_source_mode == 'upload'",
                fileInput("batch_files", "Select Candidate PDF Resumes:",
                          multiple = TRUE, accept = c(".pdf"),
                          buttonLabel = "Select Files...",
                          placeholder = "Multiple PDFs supported")
              ),

              conditionalPanel(
                condition = "input.batch_source_mode == 'sample'",
                div(
                  style = "background: var(--slate-50); border: 1px solid var(--slate-200); border-radius: 6px; padding: 12px; margin-bottom: 12px; font-size: 13px;",
                  p(tags$b("3 Pre-packaged Candidate Profiles:"), style = "margin-bottom: 6px;"),
                  tags$ul(
                    style = "padding-left: 18px; margin-bottom: 0; color: #475569;",
                    tags$li("sample_data_scientist.pdf (Senior Data Scientist)"),
                    tags$li("sample_devops_engineer.pdf (Senior DevOps Engineer)"),
                    tags$li("sample_sde_fullstack.pdf (Full Stack Developer / SDE)")
                  )
                )
              ),

              selectInput("batch_role_select", "Target Screening Opening:", choices = NULL, selectize = FALSE),

              br(),
              actionButton("run_batch_btn", "Execute Batch Screening",
                           class = "btn-primary btn-block", icon = icon("play"),
                           style = "padding: 12px 18px !important; font-size: 14.5px !important;")
            )
          ),

          column(
            width = 8,

            conditionalPanel(
              condition = "output.batch_has_run == false",
              div(
                class = "empty-state-box",
                tags$i(class = "fa-solid fa-users-viewfinder empty-state-icon"),
                div(class = "empty-state-title", "Batch Evaluation Pipeline Ready"),
                div(class = "empty-state-desc",
                    "Select a candidate pool on the left, choose the target job position, and start processing. The system will benchmark and rank all candidates in order of compatibility.")
              )
            ),

            conditionalPanel(
              condition = "output.batch_has_run == true",

              # Summary Metrics
              fluidRow(
                column(width = 4, uiOutput("batch_stat_total_ui")),
                column(width = 4, uiOutput("batch_stat_avg_ui")),
                column(width = 4, uiOutput("batch_stat_pass_ui"))
              ),

              # Leaderboard Datatable
              box(
                title = "Evaluated Candidate Leaderboard",
                width = NULL,
                div(
                  style = "margin-bottom: 10px; display: flex; justify-content: space-between; align-items: center;",
                  span("Candidates ranked by ATS compatibility match score.", style = "font-size: 13px; color: #64748b;"),
                  downloadButton("export_batch_csv_btn", "Export Batch CSV", class = "btn-default btn-sm")
                ),
                withSpinner(DTOutput("batch_results_table"), type = 8, color = "#2563eb")
              )
            )
          )
        )
      ),

      # ========================================================================
      # TAB 4: MANAGE JOB OPENINGS
      # ========================================================================
      tabItem(
        tabName = "job_manager",

        fluidRow(
          column(
            width = 4,
            box(
              title = "Create New Job Opening",
              width = NULL,

              textInput("add_jd_title", "Position Title *", placeholder = "e.g., Senior Backend Engineer"),
              textInput("add_jd_company", "Hiring Department / Company", placeholder = "e.g., Engineering - Infrastructure"),
              numericInput("add_jd_exp", "Minimum Required Experience (Years)", value = 3, min = 0, max = 30),
              textAreaInput("add_jd_desc", "Detailed Job Description & Requirements *",
                            rows = 10, placeholder = "List required languages, cloud platforms, responsibilities, frameworks, certifications..."),

              actionButton("save_jd_btn", "Save Job Opening",
                           class = "btn-primary btn-block", icon = icon("floppy-disk"))
            )
          ),

          column(
            width = 8,
            box(
              title = "Active Job Openings Directory",
              width = NULL,
              p("Available job profiles used for ATS resume scoring and keyword extraction.",
                style = "color: #64748b; font-size: 13px; margin-bottom: 12px;"),
              withSpinner(DTOutput("job_openings_table"), type = 8, color = "#2563eb")
            )
          )
        )
      ),

      # ========================================================================
      # TAB 5: VISUAL FIT ANALYTICS
      # ========================================================================
      tabItem(
        tabName = "analytics",

        conditionalPanel(
          condition = "output.matcher_has_run == false",
          div(
            class = "empty-state-box",
            tags$i(class = "fa-solid fa-chart-pie empty-state-icon"),
            div(class = "empty-state-title", "No Active Evaluation Data"),
            div(class = "empty-state-desc",
                "Perform a candidate screening in the 'Single Resume Screener' tab to unlock competency radar mapping, experience scatterplots, and role benchmarking."),
            actionButton("go_to_matcher_from_analytics", "Go to Single Resume Screener",
                         class = "btn-primary", icon = icon("arrow-right"))
          )
        ),

        conditionalPanel(
          condition = "output.matcher_has_run == true",

          fluidRow(
            column(
              width = 6,
              box(
                title = "Competency Domain Match Coverage (Radar Map)",
                width = NULL,
                withSpinner(plotlyOutput("skills_radar_plot", height = "360px"), type = 8, color = "#2563eb")
              )
            ),
            column(
              width = 6,
              box(
                title = "Candidate Word Frequency Cloud",
                width = NULL,
                withSpinner(plotOutput("resume_wordcloud", height = "360px"), type = 8, color = "#2563eb")
              )
            )
          ),

          fluidRow(
            column(
              width = 6,
              box(
                title = "Experience vs. ATS Match Score Benchmarking",
                width = NULL,
                withSpinner(plotlyOutput("experience_scatter_plot", height = "340px"), type = 8, color = "#2563eb")
              )
            ),
            column(
              width = 6,
              box(
                title = "Industry Role Market Benchmark Profile",
                width = NULL,
                uiOutput("benchmark_details_ui")
              )
            )
          )
        )
      ),

      # ========================================================================
      # TAB 6: RESUME STRUCTURE REVIEW
      # ========================================================================
      tabItem(
        tabName = "optimizer",

        conditionalPanel(
          condition = "output.matcher_has_run == false",
          div(
            class = "empty-state-box",
            tags$i(class = "fa-solid fa-list-check empty-state-icon"),
            div(class = "empty-state-title", "No Resume Loaded for Audit"),
            div(class = "empty-state-desc",
                "Evaluate a resume first to inspect keyword frequency density, readability metrics, and structural bullet formatting."),
            actionButton("go_to_matcher_from_optimizer", "Go to Single Resume Screener",
                         class = "btn-primary", icon = icon("arrow-right"))
          )
        ),

        conditionalPanel(
          condition = "output.matcher_has_run == true",

          fluidRow(
            column(
              width = 7,
              box(
                title = "Matched Role Term Density in Resume",
                width = NULL,
                withSpinner(plotlyOutput("keyword_density_bar_plot", height = "380px"), type = 8, color = "#2563eb")
              )
            ),
            column(
              width = 5,
              box(
                title = "Structural Quality Audit Summary",
                width = NULL,
                uiOutput("structural_audit_ui")
              )
            )
          )
        )
      ),

      # ========================================================================
      # TAB 7: MODEL SETTINGS & METRICS
      # ========================================================================
      tabItem(
        tabName = "performance",

        fluidRow(
          column(
            width = 6,
            box(
              title = "Regression Engine Benchmarks (Predicting 0-100 ATS Score)",
              width = NULL,
              p("Comparison across algorithms evaluated on cross-validation sets.", style = "font-size: 12.5px; color: #64748b;"),
              tableOutput("metrics_reg_table")
            )
          ),
          column(
            width = 6,
            box(
              title = "Classification Engine Benchmarks (Predicting Pass/Fail)",
              width = NULL,
              p("Evaluation metrics predicting automated resume screening thresholds.", style = "font-size: 12.5px; color: #64748b;"),
              tableOutput("metrics_clf_table")
            )
          )
        ),

        fluidRow(
          column(
            width = 7,
            box(
              title = "Random Forest Regression: Feature Importance Weight",
              width = NULL,
              withSpinner(plotlyOutput("feature_importance_plot", height = "340px"), type = 8, color = "#2563eb")
            )
          ),
          column(
            width = 5,
            box(
              title = "Scoring Methodology & Explainability",
              width = NULL,
              div(
                style = "font-size: 13px; line-height: 1.55; color: #334155;",
                tags$p(tags$b("1. TF-IDF Cosine Similarity (30% weight):"), " Computes vector similarity between stemmed resume text and target requirements."),
                tags$p(tags$b("2. Keyword Match Density (20% weight):"), " Coverage percentage of unique technical keywords identified from the job posting."),
                tags$p(tags$b("3. Technical Skills Verification (15% weight):"), " Exact-boundary regex identification across languages, databases, cloud, and frameworks."),
                tags$p(tags$b("4. Experience & Education Heuristics (20% combined):"), " Normalized against required years and educational qualification credentials."),
                tags$p(tags$b("5. Readability & Action Verbs (15% combined):"), " Flesch-Kincaid ease scores combined with strong active accomplishment verbs.")
              )
            )
          )
        )
      ),

      # ========================================================================
      # TAB 8: SYSTEM ARCHITECTURE & ABOUT
      # ========================================================================
      tabItem(
        tabName = "about",

        fluidRow(
          column(
            width = 12,
            box(
              title = "System Architecture & Engineering Specification",
              width = NULL,

              h3("TalentScan ATS™ Platform Overview", style = "font-weight: 700; font-size: 18px; margin-top: 5px; color: #0f172a;"),
              p("TalentScan ATS is a production-quality recruitment intelligence system built entirely in R. It processes candidate PDF resumes, cleans and tokenizes technical text, computes high-dimensional TF-IDF vectors, verifies core technical competencies, and applies ensemble Machine Learning models to score candidate compatibility.",
                style = "font-size: 14px; line-height: 1.6; color: #334155;"),

              hr(style = "border-color: #e2e8f0; margin: 20px 0;"),

              fluidRow(
                column(
                  width = 4,
                  div(
                    style = "background: var(--slate-50); border: 1px solid var(--slate-200); border-radius: 8px; padding: 18px;",
                    h4("1. Text Extraction & NLP", style = "font-weight: 600; font-size: 14.5px; color: #0f172a; margin-top: 0;"),
                    tags$ul(
                      style = "font-size: 13px; padding-left: 18px; color: #475569; line-height: 1.6;",
                      tags$li("Low-level PDF text reading via pdftools"),
                      tags$li("Stopword filtering with custom IT stopwords"),
                      tags$li("Porter stemming via tm and SnowballC"),
                      tags$li("TF-IDF vectorization with text2vec")
                    )
                  )
                ),
                column(
                  width = 4,
                  div(
                    style = "background: var(--slate-50); border: 1px solid var(--slate-200); border-radius: 8px; padding: 18px;",
                    h4("2. Machine Learning Core", style = "font-weight: 600; font-size: 14.5px; color: #0f172a; margin-top: 0;"),
                    tags$ul(
                      style = "font-size: 13px; padding-left: 18px; color: #475569; line-height: 1.6;",
                      tags$li("Random Forest Regression for continuous fit scoring"),
                      tags$li("Support Vector Machine (SVM) classifier for pass/fail odds"),
                      tags$li("Heuristic date-range and action-verb extractors"),
                      tags$li("Flesch-Kincaid readability scoring")
                    )
                  )
                ),
                column(
                  width = 4,
                  div(
                    style = "background: var(--slate-50); border: 1px solid var(--slate-200); border-radius: 8px; padding: 18px;",
                    h4("3. Persistence & Reporting", style = "font-weight: 600; font-size: 14.5px; color: #0f172a; margin-top: 0;"),
                    tags$ul(
                      style = "font-size: 13px; padding-left: 18px; color: #475569; line-height: 1.6;",
                      tags$li("SQLite transactional database backend"),
                      tags$li("Parameterized SQL queries (SQL injection safe)"),
                      tags$li("Self-healing bootstrap dataset pipeline"),
                      tags$li("Standard 2-page assessment PDF export engine")
                    )
                  )
                )
              ),

              hr(style = "border-color: #e2e8f0; margin: 20px 0;"),

              h4("Environment Diagnostics", style = "font-weight: 600; font-size: 14.5px; color: #0f172a;"),
              tags$ul(
                style = "font-size: 13px; padding-left: 18px; color: #475569; line-height: 1.6;",
                tags$li(paste("R Runtime Engine:", R.version.string)),
                tags$li("Host: Localhost 127.0.0.1:3838"),
                tags$li(paste("Database Path:", file.path(getwd(), "data/ats_analytics.sqlite"))),
                tags$li("Trained Model Asset: models/randomForest_model.rds")
              )
            )
          )
        )
      )

    ) # end tabItems
  ) # end dashboardBody
)

# ------------------------------------------------------------------------------
# 3. SERVER LOGIC SPECIFICATION
# ------------------------------------------------------------------------------
server <- function(input, output, session) {

  # Reactive triggers and flags
  db_trigger <- reactiveVal(0)
  has_matcher_run <- reactiveVal(FALSE)
  has_batch_run <- reactiveVal(FALSE)

  output$matcher_has_run <- reactive({ has_matcher_run() })
  outputOptions(output, "matcher_has_run", suspendWhenHidden = FALSE)

  output$batch_has_run <- reactive({ has_batch_run() })
  outputOptions(output, "batch_has_run", suspendWhenHidden = FALSE)

  # Quick navigation handlers
  observeEvent(input$go_to_matcher_btn, {
    updateTabItems(session, "sidebar_tabs", "matcher")
  })
  observeEvent(input$go_to_matcher_from_analytics, {
    updateTabItems(session, "sidebar_tabs", "matcher")
  })
  observeEvent(input$go_to_matcher_from_optimizer, {
    updateTabItems(session, "sidebar_tabs", "matcher")
  })

  # Synchronize dynamic job choices across dropdowns
  job_data <- reactive({
    db_trigger()
    get_job_descriptions()
  })

  observe({
    jds <- job_data()
    if (nrow(jds) == 0) {
      updateSelectInput(session, "job_role_select", choices = character(0))
      updateSelectInput(session, "batch_role_select", choices = character(0))
      return()
    }
    choices <- jds$title
    names(choices) <- paste0(jds$title, " (", ifelse(is.na(jds$company) | jds$company == "", "General", jds$company), ")")
    updateSelectInput(session, "job_role_select", choices = choices)
    updateSelectInput(session, "batch_role_select", choices = choices)
  })

  # Handle Sample Selection in Single Matcher
  observeEvent(list(input$sample_resume_choice, input$input_source_mode), {
    if (identical(input$input_source_mode, "sample")) {
      s_choice <- input$sample_resume_choice
      if (is.null(s_choice) || s_choice == "") s_choice <- "sample_data_scientist.pdf"
      if (grepl("data_scientist", s_choice)) {
        updateTextInput(session, "candidate_name", value = "John Doe")
        updateSelectInput(session, "job_role_select", selected = "Data Scientist")
      } else if (grepl("devops", s_choice)) {
        updateTextInput(session, "candidate_name", value = "Jane Smith")
        updateSelectInput(session, "job_role_select", selected = "DevOps Engineer")
      } else if (grepl("sde", s_choice)) {
        updateTextInput(session, "candidate_name", value = "Raghu Bharathi K P")
        jds <- job_data()
        if ("Full Stack Developer" %in% jds$title) {
          updateSelectInput(session, "job_role_select", selected = "Full Stack Developer")
        } else if ("Java Developer" %in% jds$title) {
          updateSelectInput(session, "job_role_select", selected = "Java Developer")
        }
      }
    }
  })

  # Selected Job Preview Card
  output$selected_jd_preview_ui <- renderUI({
    req(input$job_role_select)
    jds <- job_data()
    row <- jds %>% filter(title == input$job_role_select) %>% safe_slice(1)
    if (is.null(row) || nrow(row) == 0) return(NULL)

    div(
      class = "job-preview-card",
      div(class = "job-preview-title", row$title[1]),
      div(class = "job-preview-company", paste(row$company[1], "• Min Experience:", row$min_experience[1], "Years")),
      p(substr(row$description[1], 1, 150), "...", style = "color: #475569; margin: 0; font-size: 12px;")
    )
  })

  # ============================================================================
  # TAB 1: DASHBOARD OVERVIEW SERVER
  # ============================================================================

  db_stats <- reactive({
    db_trigger()
    get_db_stats()
  })

  output$kpi_total_resumes_ui <- renderUI({
    st <- db_stats()
    div(
      class = "kpi-card kpi-primary",
      tags$i(class = "fa-solid fa-users kpi-icon"),
      div(class = "kpi-label", "Total Evaluated Candidates"),
      div(class = "kpi-value", format(st$total, big.mark = ",")),
      div(class = "kpi-subtext", "Processed via ATS scoring pipeline")
    )
  })

  output$kpi_avg_score_ui <- renderUI({
    st <- db_stats()
    score_val <- ifelse(is.na(st$avg_score) || is.null(st$avg_score), 0, st$avg_score)
    div(
      class = "kpi-card kpi-warning",
      tags$i(class = "fa-solid fa-gauge-high kpi-icon"),
      div(class = "kpi-label", "Mean ATS Fit Score"),
      div(class = "kpi-value", paste0(score_val, " / 100")),
      div(class = "kpi-subtext", "Across all positions evaluated")
    )
  })

  output$kpi_pass_rate_ui <- renderUI({
    st <- db_stats()
    pass_val <- ifelse(is.na(st$pass_rate) || is.null(st$pass_rate), 0, st$pass_rate)
    div(
      class = "kpi-card kpi-success",
      tags$i(class = "fa-solid fa-circle-check kpi-icon"),
      div(class = "kpi-label", "Screening Pass Rate"),
      div(class = "kpi-value", paste0(pass_val, "%")),
      div(class = "kpi-subtext", "Candidate qualification threshold: >= 70")
    )
  })

  output$active_jobs_snapshot_ui <- renderUI({
    jds <- job_data()
    if (nrow(jds) == 0) {
      return(p("No job openings created yet.", style = "color: #94a3b8; font-size: 13px;"))
    }
    tags$div(
      tags$div(
        style = "margin-bottom: 12px; font-size: 13px; color: #475569;",
        paste("Currently tracking", nrow(jds), "active job positions.")
      ),
      tags$ul(
        style = "padding-left: 18px; margin-bottom: 16px; font-size: 13px; line-height: 1.6;",
        lapply(1:min(5, nrow(jds)), function(i) {
          tags$li(
            tags$b(jds$title[i]),
            span(paste0(" (", jds$min_experience[i], " yrs min)"), style = "color: #64748b;")
          )
        })
      ),
      actionButton("go_to_jobs_btn", "Manage Positions",
                   class = "btn-default btn-sm btn-block", icon = icon("briefcase"))
    )
  })

  observeEvent(input$go_to_jobs_btn, {
    updateTabItems(session, "sidebar_tabs", "job_manager")
  })

  output$pool_ats_dist_plot <- renderPlotly({
    db_trigger()
    con <- db_connect()
    scores <- dbGetQuery(con, "SELECT ats_score FROM evaluations")$ats_score
    dbDisconnect(con)

    if (length(scores) == 0) {
      scores <- trained_model_pkg$sample_data$ats_score
    }

    plot_ly(
      x = ~scores,
      type = "histogram",
      xbins = list(start = 0, end = 100, size = 5),
      marker = list(
        color = "#2563eb",
        line = list(color = "#ffffff", width = 1)
      )
    ) %>%
      layout(
        xaxis = list(title = "ATS Match Score Range (0 - 100)", range = c(0, 100), gridcolor = "#f1f5f9"),
        yaxis = list(title = "Candidate Count", gridcolor = "#f1f5f9"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 40, r = 20, t = 20, b = 40)
      )
  })

  output$history_table <- renderDT({
    db_trigger()
    df <- get_evaluation_history()
    if (nrow(df) == 0) {
      return(datatable(
        data.frame(Message = "No candidate evaluations recorded yet. Run a screening to populate this log."),
        rownames = FALSE,
        options = list(dom = 't')
      ))
    }

    # Action buttons for inspect and delete
    df$Actions <- sprintf(
      '<div class="btn-group">
         <button class="btn btn-default btn-xs" onclick="Shiny.setInputValue(\'view_eval_id\', %d, {priority: \'event\'})"><i class="fa fa-eye"></i> Details</button>
         <button class="btn btn-danger btn-xs" onclick="Shiny.setInputValue(\'delete_eval_id\', %d, {priority: \'event\'})"><i class="fa fa-trash"></i></button>
       </div>',
      df$id, df$id
    )

    df$StatusBadge <- ifelse(
      df$ats_score >= 70,
      '<span class="rating-qualified scorecard-rating-chip">Pass</span>',
      '<span class="rating-disqualified scorecard-rating-chip">Needs Opt</span>'
    )

    datatable(
      df %>% select(id, candidate_name, target_role, ats_score, pass_probability, StatusBadge, evaluated_at, Actions),
      escape = FALSE,
      options = list(pageLength = 8, scrollX = TRUE),
      rownames = FALSE,
      colnames = c("ID", "Candidate Name", "Position", "Score", "Pass Prob %", "Screening Status", "Evaluated At", "Actions")
    )
  })

  # Inspection Modal Handler
  observeEvent(input$view_eval_id, {
    ev <- get_evaluation_by_id(input$view_eval_id)
    if (is.null(ev)) return()

    showModal(modalDialog(
      title = paste("Candidate Audit:", ev$candidate_name),
      size = "l",
      easyClose = TRUE,
      footer = modalButton("Close"),

      fluidRow(
        column(
          width = 4,
          div(
            class = "metric-mini-card",
            div(class = "metric-mini-label", "Target Role"),
            div(class = "metric-mini-val", style = "font-size: 15px;", ev$target_role)
          )
        ),
        column(
          width = 4,
          div(
            class = "metric-mini-card",
            div(class = "metric-mini-label", "ATS Score"),
            div(class = "metric-mini-val", style = ifelse(ev$ats_score >= 70, "color: #059669;", "color: #dc2626;"), paste0(ev$ats_score, " / 100"))
          )
        ),
        column(
          width = 4,
          div(
            class = "metric-mini-card",
            div(class = "metric-mini-label", "Pass Probability"),
            div(class = "metric-mini-val", paste0(ev$pass_probability, "%"))
          )
        )
      ),

      h5(tags$b("Detected Competencies:"), style = "margin-top: 15px; color: #0f172a;"),
      p(ifelse(ev$detected_skills == "", "None", ev$detected_skills), style = "color: #475569; font-size: 13px;"),

      h5(tags$b("Identified Gaps:"), style = "margin-top: 15px; color: #dc2626;"),
      p(ifelse(ev$missing_skills == "", "No critical gaps identified.", ev$missing_skills), style = "color: #475569; font-size: 13px;"),

      h5(tags$b("Top Recommendations:"), style = "margin-top: 15px; color: #0f172a;"),
      p(ifelse(ev$top_suggestions == "", "None", ev$top_suggestions), style = "color: #475569; font-size: 13px;"),

      hr(),
      p(paste("Evaluation Timestamp:", ev$evaluated_at, "| File:", ev$resume_filename), style = "font-size: 12px; color: #94a3b8; margin: 0;")
    ))
  })

  # Delete Record Handler
  observeEvent(input$delete_eval_id, {
    delete_evaluation(input$delete_eval_id)
    db_trigger(db_trigger() + 1)
    showNotification("Candidate evaluation record deleted.", type = "message")
  })

  # Clear All History Modal Prompt
  observeEvent(input$clear_history_prompt_btn, {
    showModal(modalDialog(
      title = "Confirm Database Reset",
      p("Are you sure you want to delete ALL historical candidate evaluation records? This action cannot be undone."),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_clear_db_btn", "Yes, Clear Database", class = "btn-danger")
      )
    ))
  })

  observeEvent(input$confirm_clear_db_btn, {
    removeModal()
    clear_all_evaluations()
    db_trigger(db_trigger() + 1)
    showNotification("Candidate evaluations database has been reset.", type = "warning")
  })

  # Export DB to CSV
  output$export_db_btn <- downloadHandler(
    filename = function() {
      paste0("Candidate_Evaluations_Database_", format(Sys.Date(), "%Y%m%d"), ".csv")
    },
    content = function(file) {
      con <- db_connect()
      df <- dbGetQuery(con, "SELECT * FROM evaluations ORDER BY id DESC")
      dbDisconnect(con)
      write.csv(df, file, row.names = FALSE)
    }
  )

  # ============================================================================
  # TAB 2: SINGLE RESUME SCREENER SERVER
  # ============================================================================

  matcher_trigger <- reactiveVal(0)
  quick_eval_active <- reactiveVal(FALSE)

  # One-Click Quick Sample Evaluation
  observeEvent(input$quick_sample_eval_btn, {
    quick_eval_active(TRUE)
    updateRadioButtons(session, "input_source_mode", selected = "sample")
    updateSelectInput(session, "sample_resume_choice", selected = "sample_data_scientist.pdf")
    updateSelectInput(session, "job_role_select", selected = "Data Scientist")
    updateTextInput(session, "candidate_name", value = "John Doe")
    matcher_trigger(matcher_trigger() + 1)
  })

  # Manual Run Matcher button click
  observeEvent(input$run_matcher_btn, {
    matcher_trigger(matcher_trigger() + 1)
  })

  # Reactive Execution for Single Resume Matcher
  single_result <- reactiveVal(NULL)

  observeEvent(matcher_trigger(), {
    req(matcher_trigger() > 0)

    is_quick <- isolate(quick_eval_active())
    if (is_quick) quick_eval_active(FALSE)

    # Resolve target resume path
    resume_path <- NULL
    resume_filename <- ""

    source_mode <- if (is_quick) "sample" else isolate(input$input_source_mode)

    if (source_mode == "sample") {
      sample_file <- if (is_quick) "sample_data_scientist.pdf" else isolate(input$sample_resume_choice)
      if (is.null(sample_file) || sample_file == "") sample_file <- "sample_data_scientist.pdf"
      resume_path <- file.path("data", "resumes", sample_file)
      resume_filename <- sample_file
      if (!file.exists(resume_path)) {
        bootstrap_sample_files()
      }
    } else {
      res_file <- isolate(input$resume_file)
      if (is.null(res_file)) {
        showNotification("Please upload a PDF resume document first.", type = "error")
        return()
      }
      resume_path <- res_file$datapath
      resume_filename <- res_file$name
    }

    # Resolve candidate name
    cand_name <- if (is_quick) "John Doe" else isolate(trimws(input$candidate_name))
    if (is.null(cand_name) || cand_name == "") cand_name <- "Candidate"

    # Resolve target job description
    jd_text <- ""
    is_custom_jd <- if (is_quick) FALSE else isolate(isTRUE(input$custom_jd_toggle))
    target_role <- if (is_quick) "Data Scientist" else isolate(input$job_role_select)

    if (is_custom_jd) {
      custom_text <- isolate(trimws(input$custom_jd_text))
      if (custom_text == "") {
        showNotification("Please enter or paste custom job description text.", type = "error")
        return()
      }
      jd_text <- custom_text
      target_role <- "Custom Position"
    } else {
      if (is.null(target_role) || target_role == "") {
        target_role <- "Data Scientist"
      }
      jds <- job_data()
      jd_row <- jds %>% filter(title == target_role) %>% safe_slice(1)
      if (!is.null(jd_row) && nrow(jd_row) > 0) {
        jd_text <- jd_row$description[1]
      } else {
        jd_text <- "Looking for candidate with programming, system design, and database skills."
      }
    }

    # Execute ATS prediction with progress indicator
    res <- withProgress(message = "Executing ATS Screening Pipeline...", value = 0.2, {
      setProgress(0.4, detail = "Extracting text and computing TF-IDF similarity...")
      setProgress(0.7, detail = "Running Random Forest regression & SVM classifier...")

      out <- tryCatch({
        predict_resume_ats(
          resume_path = resume_path,
          jd_text = jd_text,
          target_title = target_role
        )
      }, error = function(e) {
        showNotification(paste("Parsing error:", e$message), type = "error")
        NULL
      })

      setProgress(1.0, detail = "Screening complete!")
      out
    })

    if (is.null(res)) return()

    # Persist evaluation record to SQLite
    sugs <- generate_improvement_suggestions(res)
    report_fname <- paste0("reports/Report_", gsub("[^a-zA-Z0-9]", "_", cand_name), "_", format(Sys.time(), "%Y%m%d%H%M%S"), ".pdf")

    save_evaluation(
      session_id = session$token,
      candidate_name = cand_name,
      target_role = target_role,
      resume_filename = resume_filename,
      predictions = res,
      suggestions = sugs,
      report_path = report_fname
    )

    db_trigger(db_trigger() + 1)
    single_result(res)
    has_matcher_run(TRUE)
  })

  matcher_result <- reactive({
    single_result()
  })

  # Scorecard UI Elements
  output$score_number_ui <- renderUI({
    res <- matcher_result()
    req(res)
    score <- res$ats_score
    cls <- ifelse(score >= 70, "scorecard-number pass", "scorecard-number fail")
    div(
      div(class = cls, score),
      span("ATS Score (0 - 100)", style = "font-size: 13px; font-weight: 600; color: #64748b;")
    )
  })

  output$score_rating_chip_ui <- renderUI({
    res <- matcher_result()
    req(res)
    score <- res$ats_score
    if (score >= 70) {
      span(class = "scorecard-rating-chip rating-qualified", "Qualified — Strong Role Match")
    } else if (score >= 50) {
      span(class = "scorecard-rating-chip rating-review", "Moderate Fit — Gaps Identified")
    } else {
      span(class = "scorecard-rating-chip rating-disqualified", "Critical Gaps — Low Compatibility")
    }
  })

  output$pass_gauge_plot <- renderPlotly({
    res <- matcher_result()
    req(res)
    prob <- res$pass_probability

    plot_ly(
      type = "indicator",
      mode = "gauge+number",
      value = prob,
      number = list(suffix = "%", font = list(size = 22, color = "#0f172a")),
      gauge = list(
        axis = list(range = list(0, 100), tickwidth = 1, tickcolor = "#cbd5e1"),
        bar = list(color = ifelse(prob >= 70, "#059669", "#dc2626"), thickness = 0.8),
        bgcolor = "#f8fafc",
        borderwidth = 1,
        bordercolor = "#e2e8f0",
        threshold = list(
          line = list(color = "#0f172a", width = 2),
          thickness = 0.8,
          value = 70
        )
      ),
      height = 95
    ) %>%
      layout(margin = list(l = 25, r = 25, t = 10, b = 10), paper_bgcolor = "rgba(0,0,0,0)")
  })

  # 4 Key Metrics Tiles
  output$metric_exp_fit_ui <- renderUI({
    res <- matcher_result()
    req(res)
    exp_val <- res$features$experience_years
    div(
      class = "metric-mini-card",
      div(class = "metric-mini-label", "Experience"),
      div(class = "metric-mini-val", paste(exp_val, "Years"))
    )
  })

  output$metric_edu_fit_ui <- renderUI({
    res <- matcher_result()
    req(res)
    edu_val <- as.character(res$features$education_level)
    div(
      class = "metric-mini-card",
      div(class = "metric-mini-label", "Education Level"),
      div(class = "metric-mini-val", edu_val)
    )
  })

  output$metric_kw_fit_ui <- renderUI({
    res <- matcher_result()
    req(res)
    kw_val <- round(res$features$keyword_match_percent, 1)
    div(
      class = "metric-mini-card",
      div(class = "metric-mini-label", "Keyword Match"),
      div(class = "metric-mini-val", paste0(kw_val, "%"))
    )
  })

  output$metric_read_fit_ui <- renderUI({
    res <- matcher_result()
    req(res)
    read_val <- round(res$features$readability_score, 1)
    read_label <- if (read_val >= 30 && read_val <= 75) "Optimal" else "Needs Review"
    div(
      class = "metric-mini-card",
      div(class = "metric-mini-label", "Readability"),
      div(class = "metric-mini-val", paste0(read_val, " (", read_label, ")"))
    )
  })

  # Skills Labels
  output$missing_skills_labels <- renderUI({
    res <- matcher_result()
    req(res)
    if (length(res$missing_skills) == 0) {
      return(p("All key role technical competencies were detected in candidate resume!",
               style = "color: #059669; font-weight: 500; font-size: 13px;"))
    }
    tags$div(
      lapply(res$missing_skills, function(sk) {
        span(class = "skill-badge skill-tag-missing", sk)
      })
    )
  })

  output$detected_skills_labels <- renderUI({
    res <- matcher_result()
    req(res)
    if (length(res$detected_skills) == 0) {
      return(p("No core technical skills were identified from the candidate resume.",
               style = "color: #dc2626; font-size: 13px;"))
    }
    tags$div(
      lapply(res$detected_skills, function(sk) {
        span(class = "skill-badge skill-tag-detected", sk)
      })
    )
  })

  # Actionable Recommendations List
  output$recommendations_list_ui <- renderUI({
    res <- matcher_result()
    req(res)
    sugs <- generate_improvement_suggestions(res)

    tags$div(
      lapply(sugs, function(sug) {
        is_crit <- grepl("low|missing|poor|critical", sug, ignore.case = TRUE)
        cls <- if (is_crit) "rec-item critical" else "rec-item"
        div(class = cls, sug)
      })
    )
  })

  # PDF Report Download
  output$download_report_btn <- downloadHandler(
    filename = function() {
      paste0("ATS_Assessment_", gsub("[^a-zA-Z0-9]", "_", input$candidate_name), ".pdf")
    },
    content = function(file) {
      res <- matcher_result()
      req(res)
      target_role <- ifelse(input$custom_jd_toggle, "Custom Role", input$job_role_select)
      generate_resume_pdf_report(
        candidate_name = input$candidate_name,
        target_role = target_role,
        predictions = res,
        filepath = file
      )
    }
  )

  # ============================================================================
  # TAB 3: BATCH CANDIDATE SCREENER SERVER
  # ============================================================================

  batch_result_val <- reactiveVal(NULL)

  observeEvent(input$run_batch_btn, {
    target_role <- input$batch_role_select
    if (is.null(target_role) || target_role == "") {
      showNotification("Please select a target job position.", type = "error")
      return()
    }

    # Resolve target JD
    jds <- job_data()
    jd_row <- jds %>% filter(title == target_role) %>% safe_slice(1)
    jd_text <- if (!is.null(jd_row) && nrow(jd_row) > 0) jd_row$description[1] else "General Job Requirements"

    # Resolve candidate files
    files_df <- NULL
    if (input$batch_source_mode == "sample") {
      # Use pre-packaged samples
      sample_names <- c("sample_data_scientist.pdf", "sample_devops_engineer.pdf", "sample_sde_fullstack.pdf")
      sample_paths <- file.path("data", "resumes", sample_names)
      files_df <- data.frame(
        name = sample_names,
        datapath = sample_paths,
        stringsAsFactors = FALSE
      )
    } else {
      if (is.null(input$batch_files) || nrow(input$batch_files) == 0) {
        showNotification("Please select one or more candidate PDF resumes to batch screen.", type = "error")
        return()
      }
      files_df <- input$batch_files
    }

    n_files <- nrow(files_df)
    results_list <- list()

    withProgress(message = "Executing Batch Screening...", value = 0, {
      for (i in 1:n_files) {
        f_name <- files_df$name[i]
        f_path <- files_df$datapath[i]

        setProgress(value = i / n_files, detail = paste("Analyzing", f_name))

        c_name <- tools::file_path_sans_ext(f_name)
        c_name <- gsub("[_-]", " ", c_name)
        c_name <- tools::toTitleCase(c_name)

        pred <- tryCatch({
          predict_resume_ats(
            resume_path = f_path,
            jd_text = jd_text,
            target_title = target_role
          )
        }, error = function(e) {
          list(ats_score = 0, pass_probability = 0, missing_skills = "Error parsing file",
               features = data.frame(experience_years = 0, education_level = "None",
                                     keyword_match_percent = 0, readability_score = 0,
                                     tech_skills_count = 0, certs_count = 0))
        })

        # Save to DB
        sugs <- if (pred$ats_score > 0) generate_improvement_suggestions(pred) else "Error parsing file"
        save_evaluation(
          session_id = session$token,
          candidate_name = c_name,
          target_role = target_role,
          resume_filename = f_name,
          predictions = pred,
          suggestions = sugs,
          report_path = NA
        )

        results_list[[i]] <- data.frame(
          Filename = f_name,
          Candidate = c_name,
          Score = pred$ats_score,
          PassProb = pred$pass_probability,
          Status = ifelse(pred$ats_score >= 70, "Qualified", ifelse(pred$ats_score >= 50, "Review", "Disqualified")),
          stringsAsFactors = FALSE
        )
      }
    })

    df_out <- bind_rows(results_list) %>% arrange(desc(Score))
    df_out$Rank <- 1:nrow(df_out)

    # Save batch record
    save_batch_job(
      job_name = paste("Batch Screening -", target_role),
      total_resumes = n_files,
      avg_ats = mean(df_out$Score),
      pass_count = sum(df_out$Score >= 70),
      fail_count = sum(df_out$Score < 70),
      target_role = target_role
    )

    db_trigger(db_trigger() + 1)
    batch_result_val(df_out)
    has_batch_run(TRUE)
  })

  batch_results <- reactive({
    batch_result_val()
  })

  output$batch_stat_total_ui <- renderUI({
    df <- batch_results()
    req(df)
    div(
      class = "kpi-card kpi-primary",
      div(class = "kpi-label", "Total Resumes Evaluated"),
      div(class = "kpi-value", nrow(df)),
      div(class = "kpi-subtext", "Batch pipeline executed")
    )
  })

  output$batch_stat_avg_ui <- renderUI({
    df <- batch_results()
    req(df)
    div(
      class = "kpi-card kpi-warning",
      div(class = "kpi-label", "Batch Average Score"),
      div(class = "kpi-value", paste0(round(mean(df$Score), 1), " / 100")),
      div(class = "kpi-subtext", "Benchmark fit across pool")
    )
  })

  output$batch_stat_pass_ui <- renderUI({
    df <- batch_results()
    req(df)
    pass_cnt <- sum(df$Score >= 70)
    div(
      class = "kpi-card kpi-success",
      div(class = "kpi-label", "Qualified Candidates"),
      div(class = "kpi-value", paste0(pass_cnt, " / ", nrow(df))),
      div(class = "kpi-subtext", paste0("Pass Rate: ", round(pass_cnt / nrow(df) * 100, 1), "%"))
    )
  })

  output$batch_results_table <- renderDT({
    df <- batch_results()
    req(df)

    df$StatusBadge <- ifelse(
      df$Score >= 70,
      '<span class="rating-qualified scorecard-rating-chip">Qualified</span>',
      ifelse(df$Score >= 50,
             '<span class="rating-review scorecard-rating-chip">Review</span>',
             '<span class="rating-disqualified scorecard-rating-chip">Filtered</span>')
    )

    datatable(
      df %>% select(Rank, Candidate, Filename, Score, PassProb, StatusBadge),
      escape = FALSE,
      rownames = FALSE,
      options = list(pageLength = 8, scrollX = TRUE),
      colnames = c("Rank", "Candidate Name", "File", "ATS Score", "Pass Prob %", "Screening Decision")
    )
  })

  output$export_batch_csv_btn <- downloadHandler(
    filename = function() {
      paste0("Batch_Screening_Results_", format(Sys.Date(), "%Y%m%d"), ".csv")
    },
    content = function(file) {
      df <- batch_results()
      req(df)
      write.csv(df %>% select(Rank, Candidate, Filename, Score, PassProb, Status), file, row.names = FALSE)
    }
  )

  # ============================================================================
  # TAB 4: MANAGE JOB OPENINGS SERVER
  # ============================================================================

  output$job_openings_table <- renderDT({
    db_trigger()
    df <- get_job_descriptions()
    if (nrow(df) == 0) {
      return(datatable(data.frame(Message = "No job positions configured.")))
    }

    df$Actions <- sprintf(
      '<div class="btn-group">
         <button class="btn btn-default btn-xs" onclick="Shiny.setInputValue(\'view_jd_id\', %d, {priority: \'event\'})"><i class="fa fa-eye"></i> View</button>
         <button class="btn btn-danger btn-xs" onclick="Shiny.setInputValue(\'delete_jd_id\', %d, {priority: \'event\'})"><i class="fa fa-trash"></i></button>
       </div>',
      df$id, df$id
    )

    datatable(
      df %>% select(id, title, company, min_experience, created_at, Actions),
      escape = FALSE,
      rownames = FALSE,
      options = list(pageLength = 8, scrollX = TRUE),
      colnames = c("ID", "Position Title", "Company / Team", "Min Exp (Yrs)", "Date Created", "Actions")
    )
  })

  observeEvent(input$save_jd_btn, {
    if (trimws(input$add_jd_title) == "") {
      showNotification("Please enter a job position title.", type = "error")
      return()
    }
    if (trimws(input$add_jd_desc) == "") {
      showNotification("Please provide a job description.", type = "error")
      return()
    }

    add_job_description(
      title = trimws(input$add_jd_title),
      description = trimws(input$add_jd_desc),
      company = trimws(input$add_jd_company),
      min_experience = max(0, as.numeric(input$add_jd_exp))
    )

    # Clear fields
    updateTextInput(session, "add_jd_title", value = "")
    updateTextInput(session, "add_jd_company", value = "")
    updateNumericInput(session, "add_jd_exp", value = 3)
    updateTextAreaInput(session, "add_jd_desc", value = "")

    db_trigger(db_trigger() + 1)
    showNotification("New job position saved successfully!", type = "message")
  })

  # View JD Modal
  observeEvent(input$view_jd_id, {
    jds <- job_data()
    row <- jds %>% filter(id == input$view_jd_id) %>% safe_slice(1)
    if (is.null(row) || nrow(row) == 0) return()

    showModal(modalDialog(
      title = paste("Job Specification:", row$title[1]),
      size = "l",
      easyClose = TRUE,
      footer = modalButton("Close"),
      p(tags$b("Company:"), row$company[1], "|", tags$b("Minimum Experience:"), paste(row$min_experience[1], "Years")),
      hr(),
      tags$pre(row$description[1], style = "white-space: pre-wrap; font-size: 13px; background: #f8fafc; border: 1px solid #e2e8f0; padding: 14px; border-radius: 6px;")
    ))
  })

  # Delete JD Handler
  observeEvent(input$delete_jd_id, {
    delete_job_description(input$delete_jd_id)
    db_trigger(db_trigger() + 1)
    showNotification("Job opening removed.", type = "message")
  })

  # ============================================================================
  # TAB 5: VISUAL FIT ANALYTICS SERVER
  # ============================================================================

  output$skills_radar_plot <- renderPlotly({
    res <- matcher_result()
    req(res)
    feats <- res$features

    categories <- c("Programming", "Cloud", "Databases", "Machine Learning", "Data Analytics", "DevOps")
    values <- c(
      feats$prog_skills_count,
      feats$cloud_skills_count,
      feats$db_skills_count,
      feats$ai_skills_count,
      feats$analytics_skills_count,
      ifelse(is.null(feats$devops_skills_count), 0, feats$devops_skills_count)
    )

    # Scale 0 to 10
    values_scaled <- pmin(10, values * 2)

    plot_ly(
      type = "scatterpolar",
      r = c(values_scaled, values_scaled[1]),
      theta = c(categories, categories[1]),
      fill = "toself",
      fillcolor = "rgba(37, 99, 235, 0.2)",
      line = list(color = "#2563eb", width = 2),
      marker = list(size = 5, color = "#1e3a8a")
    ) %>%
      layout(
        polar = list(
          radialaxis = list(visible = TRUE, range = c(0, 10), gridcolor = "#e2e8f0")
        ),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 30, r = 30, t = 20, b = 20),
        showlegend = FALSE
      )
  })

  output$resume_wordcloud <- renderPlot({
    res <- matcher_result()
    req(res)

    stopwords_df <- read_csv("data/stopwords.csv", show_col_types = FALSE)
    custom_stopwords <- unique(c(stopwords_df$word, "experience", "developer", "engineer", "team", "worked", "skills", "using", "project", "designed"))

    # Extract words from candidate skills and text
    all_terms <- c(tolower(res$detected_skills), tolower(res$matched_keywords))
    all_terms <- all_terms[!all_terms %in% custom_stopwords & nchar(all_terms) > 1]

    if (length(all_terms) < 3) {
      all_terms <- c("python", "sql", "git", "docker", "machine learning", "api", "data")
    }

    word_freqs <- table(all_terms)
    wordcloud(names(word_freqs), as.numeric(word_freqs),
              scale = c(3.2, 0.8),
              min.freq = 1,
              max.words = 40,
              colors = brewer.pal(8, "Dark2"))
  })

  output$experience_scatter_plot <- renderPlotly({
    res <- matcher_result()
    req(res)

    c_exp <- res$features$experience_years
    c_score <- res$ats_score
    bench_data <- trained_model_pkg$sample_data

    plot_ly(
      data = bench_data,
      x = ~experience_years,
      y = ~ats_score,
      type = "scatter",
      mode = "markers",
      marker = list(size = 7, color = "#94a3b8", opacity = 0.6),
      name = "Candidate Pool"
    ) %>%
      add_trace(
        x = c_exp,
        y = c_score,
        type = "scatter",
        mode = "markers",
        marker = list(size = 14, color = "#059669", line = list(color = "#ffffff", width = 2)),
        name = "Current Candidate"
      ) %>%
      layout(
        xaxis = list(title = "Work Experience (Years)", gridcolor = "#f1f5f9"),
        yaxis = list(title = "ATS Match Score", gridcolor = "#f1f5f9"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 40, r = 20, t = 20, b = 40)
      )
  })

  output$benchmark_details_ui <- renderUI({
    role_name <- ifelse(input$custom_jd_toggle, "Technical Specialist", input$job_role_select)
    bench <- get_role_benchmarks(role_name)

    div(
      style = "font-size: 13px; line-height: 1.55; color: #334155;",
      h4(tags$b(role_name), style = "margin-top: 0; color: #0f172a;"),
      p(tags$b("Salary Benchmark: "), bench$salary),
      p(tags$b("Hiring Market Demand: "), bench$demand),
      p(tags$b("Role Profile: "), bench$description),
      hr(style = "border-color: #e2e8f0; margin: 12px 0;"),
      h5(tags$b("Key Industry Validations:"), style = "margin-bottom: 6px; color: #0f172a;"),
      tags$ul(
        style = "padding-left: 18px; margin-bottom: 0;",
        lapply(bench$certs, tags$li)
      )
    )
  })

  # ============================================================================
  # TAB 6: RESUME STRUCTURE REVIEW SERVER
  # ============================================================================

  output$keyword_density_bar_plot <- renderPlotly({
    res <- matcher_result()
    req(res)
    kws <- res$matched_keywords
    if (length(kws) == 0) return(NULL)

    df_kw <- data.frame(
      Keyword = head(kws, 10),
      Score = seq(10, 1, length.out = min(10, length(kws)))
    )

    plot_ly(
      df_kw,
      x = ~Score,
      y = ~reorder(Keyword, Score),
      type = "bar",
      orientation = "h",
      marker = list(color = "#2563eb")
    ) %>%
      layout(
        yaxis = list(title = "Matched Term"),
        xaxis = list(title = "Relevance Weight"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 80, r = 20, t = 10, b = 30)
      )
  })

  output$structural_audit_ui <- renderUI({
    res <- matcher_result()
    req(res)
    feats <- res$features

    w_count <- feats$word_count
    w_status <- if (w_count >= 300 && w_count <= 850) {
      span("Optimal Length", style = "color: #059669; font-weight: 600;")
    } else if (w_count < 300) {
      span("Too Brief (<300 words)", style = "color: #dc2626; font-weight: 600;")
    } else {
      span("Too Long (>850 words)", style = "color: #d97706; font-weight: 600;")
    }

    v_count <- feats$action_verbs_count
    v_status <- if (v_count >= 6) {
      span("Strong Action Verbs", style = "color: #059669; font-weight: 600;")
    } else {
      span("Weak / Passive Verbs", style = "color: #d97706; font-weight: 600;")
    }

    r_score <- round(feats$readability_score, 1)
    r_status <- if (r_score >= 30 && r_score <= 75) {
      span("Clear Professional Grade", style = "color: #059669; font-weight: 600;")
    } else {
      span("High Reading Friction", style = "color: #d97706; font-weight: 600;")
    }

    div(
      div(
        class = "metric-mini-card",
        div(class = "metric-mini-label", "Word Count"),
        div(class = "metric-mini-val", paste(w_count, "Words")),
        div(style = "font-size: 12px; margin-top: 4px;", w_status)
      ),
      div(
        class = "metric-mini-card",
        div(class = "metric-mini-label", "Action Accomplishment Verbs"),
        div(class = "metric-mini-val", paste(v_count, "Detected")),
        div(style = "font-size: 12px; margin-top: 4px;", v_status)
      ),
      div(
        class = "metric-mini-card",
        div(class = "metric-mini-label", "Flesch-Kincaid Readability"),
        div(class = "metric-mini-val", r_score),
        div(style = "font-size: 12px; margin-top: 4px;", r_status)
      )
    )
  })

  # ============================================================================
  # TAB 7: MODEL SETTINGS & METRICS SERVER
  # ============================================================================

  output$metrics_reg_table <- renderTable({
    df <- trained_model_pkg$reg_metrics
    df$RMSE <- round(df$RMSE, 3)
    df$MAE <- round(df$MAE, 3)
    df$R_Squared <- round(df$R_Squared, 3)
    df
  }, striped = TRUE, hover = TRUE, bordered = TRUE)

  output$metrics_clf_table <- renderTable({
    df <- trained_model_pkg$clf_metrics
    df$Accuracy <- round(df$Accuracy, 3)
    df$Precision <- round(df$Precision, 3)
    df$Recall <- round(df$Recall, 3)
    df$F1_Score <- round(df$F1_Score, 3)
    df
  }, striped = TRUE, hover = TRUE, bordered = TRUE)

  output$feature_importance_plot <- renderPlotly({
    imp <- as.data.frame(trained_model_pkg$feature_importance)
    col_names <- colnames(imp)
    val_col <- if ("%IncMSE" %in% col_names) "%IncMSE" else col_names[1]
    imp$Feature <- rownames(imp)
    imp$Importance <- imp[[val_col]]

    imp <- imp %>% arrange(desc(Importance)) %>% head(8)

    plot_ly(
      imp,
      x = ~Importance,
      y = ~reorder(Feature, Importance),
      type = "bar",
      orientation = "h",
      marker = list(color = "#1e3a8a")
    ) %>%
      layout(
        yaxis = list(title = "Engine Predictor"),
        xaxis = list(title = "Importance Weight (%IncMSE)"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 120, r = 20, t = 10, b = 30)
      )
  })

}

# ------------------------------------------------------------------------------
# 4. APPLICATION INITIALIZATION
# ------------------------------------------------------------------------------
shinyApp(ui, server)
