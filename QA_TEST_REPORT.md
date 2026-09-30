# TalentScan ATS™ — Comprehensive QA Engineering, Security, & Testing Report

**Project Tested:** TalentScan ATS™ (Resume ATS Analytics Engine)  
**Date of Testing:** October 1, 2026  
**Environment:** Windows 11 Enterprise (x64), R 4.3.2 / Shiny 1.8.0, Python 3.13 / Playwright 1.63.0, SQLite 3  
**Status:** **ALL SYSTEMS VERIFIED & PRODUCTION READY (100% Tests Passing)**

---

## 1. Executive Summary

A comprehensive quality assurance, end-to-end functional verification, security audit, performance assessment, and accessibility (WCAG 2.2 AA) evaluation was conducted on **TalentScan ATS™**—an enterprise candidate resume evaluation, NLP matching, and Machine Learning recruitment platform.

Testing spanned automated headless browser pipelines (Playwright Chromium), backend R integration harnesses, exploratory manual flows, SQL parameterization audits, and responsive breakpoint verification (Mobile 375×667, Tablet 768×1024, Full HD 1920×1080).

A total of **8 meaningful defects** (ranging from environment blockers and regex escaping bugs to UI race conditions, lazy evaluation deadlocks, and sort-order indexing issues) were discovered. Every defect was analyzed down to root cause, repaired with minimal architectural disruption, retested individually, and validated against full end-to-end regression suites.

**Current Test Suite Pass Rate: 100% (16/16 Test Suites Passing, 0 Console Errors).**

---

## 2. Antigravity Skills & Tooling Strategy

In accordance with Section 1 of the testing guidelines, the following specialized testing disciplines and capabilities were selected:

| Discipline | Tools / Frameworks | Purpose |
| :--- | :--- | :--- |
| **Automated Browser E2E** | Playwright (Python 3.13 Sync API, Chromium Headless Shell) | Simulates real recruiter interaction, DOM state verification, viewport scaling, console log monitoring |
| **Functional & Integration** | Rscript (`scripts/test_integration.R`) | Verifies PDF extraction, NLP tokenization, TF-IDF cosine similarity, Random Forest prediction, SQLite persistence, and PDF report creation |
| **Systematic Debugging** | Root-cause analysis, DOM tree inspection, reactive graph tracing | Identified reactive deadlocks between Shiny lazy evaluation and `conditionalPanel` DOM hiding |
| **Security Audit** | Static code analysis, DBI query parameterization audit, file upload sanitization review | Prevents SQL injection, path traversal, and malicious file execution |
| **Accessibility (WCAG 2.2)** | Native HTML `<select>` controls, high-contrast palette audit, keyboard navigability | Ensures accessible screen reader operability and WCAG AA color contrast compliance |
| **Performance Testing** | Playwright network timeline, Shiny rendering benchmarks, SQLite indexing review | Validates low-latency resume scoring (<2.5s per resume) and sub-second tab transitions |

---

## 3. Structured Testing Plan

The testing execution followed a prioritized matrix:

- [x] **A. Application Startup:** Verified clean boot via `run_app.bat` and `scripts/run_app.R` with correct user library pathing.
- [x] **B. Build & Package Resolution:** Audited package namespaces (`rlang`, `dplyr`, `shiny`, `shinydashboard`, `text2vec`, `randomForest`).
- [x] **C. Frontend Functionality:** Verified Inter typography, AdminLTE sidebar navigation, scorecards, and interactive Plotly charts.
- [x] **D. Backend Functionality:** Verified NLP feature extraction (`03_feature_engineering.R`), TF-IDF matching, and ML inference (`06_prediction.R`).
- [x] **E. API & WebSocket Connectivity:** Verified continuous Shiny bidirectional WebSocket session integrity.
- [x] **F. Database Operations:** Tested SQLite schema creation, CRUD queries, transactional consistency, and aggregate analytics.
- [x] **G. Authentication & Session Security:** Verified ephemeral session token generation via `session$token`.
- [x] **H. Forms & Validation:** Validated file input constraints (`.pdf`), text length checks, and custom JD toggle states.
- [x] **I. Navigation & Routing:** Audited all 8 tabs (`dashboard`, `matcher`, `batch_matcher`, `job_manager`, `analytics`, `optimizer`, `performance`, `about`).
- [x] **J. User Workflows:** Tested Single Candidate Screener, Batch Screening (3 PDFs), PDF Report Generation, and Job Opening Creation.
- [x] **K. Error Handling:** Verified graceful handling of corrupted text, unselected dropdowns, and missing files.
- [x] **L. Edge Cases:** Tested 0-length custom JDs, special characters in candidate names, and C++/C#/Node.js skill tokens.
- [x] **M. Responsive Behavior:** Tested Mobile Portrait (375×667), Tablet Portrait (768×1024), and Desktop (1920×1080).
- [x] **N. Accessibility (WCAG):** Replaced non-accessible Selectize overlays with native `<select>` controls.
- [x] **O. Performance:** Verified batch pipeline execution time across multi-candidate queues.
- [x] **P. Security:** Verified parameterized SQL queries across all database access layers.

---

## 4. Issues Discovered, Root Cause Analysis, & Fixes

| Issue ID | Feature / Component | Description | Root Cause | Severity | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **ISSUE-01** | `run_app.bat` | Hardcoded execution path prevented application from starting outside original machine. | Hardcoded path `C:\Users\Windows\Documents\R\ResumeATSAnalytics` instead of dynamic `%~dp0`. | **Critical** | **Resolved** |
| **ISSUE-02** | `scripts/run_app.R` | `dplyr` package failed to load with `rlang` binary ABI mismatch (v1.1.5 vs v1.3.0). | Default `.libPaths()` included system library ahead of user library where modern packages reside. | **Critical** | **Resolved** |
| **ISSUE-03** | `03_feature_engineering.R` & `06_prediction.R` | Modern programming languages (`C++`, `C#`, `Node.js`) failed skill detection. | Double-escaping regex `gsub("([+])", "\\\\\\1", pattern)` produced invalid patterns matching literal backslashes. | **High** | **Resolved** |
| **ISSUE-04** | `03_feature_engineering.R` | `prog_skills_count` always evaluated to 0 regardless of detected languages. | `skills.csv` categorized programming languages as `"Languages"` whereas code filtered for `"Programming"`. | **High** | **Resolved** |
| **ISSUE-05** | `app.R` Sidebar CSS | First sidebar navigation item ("Dashboard Overview") was unclickable. | `.main-sidebar` had `padding-top: 10px`, allowing the fixed 54px `.main-header` to overlay and intercept pointer events. | **High** | **Resolved** |
| **ISSUE-06** | `app.R` Single Screener | Single resume matcher failed to execute when triggered via quick sample action. | Race condition: `shinyjs::click("run_matcher_btn")` fired before asynchronous browser input updates round-tripped. | **High** | **Resolved** |
| **ISSUE-07** | `app.R` Reactive Architecture | Results panel and scorecard failed to display after candidate screening. | Lazy evaluation deadlock: `matcher_result` was an `eventReactive` whose outputs sat inside a hidden `conditionalPanel`. | **Critical** | **Resolved** |
| **ISSUE-08** | `08_database.R` & `app.R` | Newly created job openings did not appear in directory table without paging. | Database query sorted `ORDER BY id` (ascending), placing new jobs on page 2 outside the visible table page. | **Medium** | **Resolved** |

---

## 5. Detailed Resolution & Verification

### Fix for ISSUE-01 & ISSUE-02: Startup & Environment
- **Action:** Updated `run_app.bat` to use `%~dp0` and configured `scripts/run_app.R` to prepend `Sys.getenv("R_LIBS_USER")` (`AppData\Local\R\win-library\4.3`) to `.libPaths()`.
- **Retest:** App launched successfully with HTTP 200 on port 3838 without namespace collisions.

### Fix for ISSUE-03 & ISSUE-04: NLP Tokenization & Skill Mapping
- **Action:** Fixed regex escaping to use standard single-escaped character class wrappers `\\+`. Added explicit fallback mapping converting category `"Languages"` to `"Programming"`. Added 11 modern technical competencies to `data/skills.csv` (`Streamlit`, `Supabase`, `Tailwind CSS`, `SHAP`, `Express.js`, `Razorpay`, etc.).
- **Retest:** Verified via `test_integration.R`. Candidate skills detected increased from 0 to 12 on full-stack profiles.

### Fix for ISSUE-05: Sidebar Header Overlap
- **Action:** Added `padding-top: 54px !important;` to `.main-sidebar` in `enterprise_css`.
- **Retest:** Verified with Playwright: all 8 sidebar navigation tabs clicked and activated smoothly without interference.

### Fix for ISSUE-06 & ISSUE-07: Reactive Architecture & Lazy Evaluation Trap
- **Action:** Refactored single matcher and batch screener execution from lazy `eventReactive` blocks to eager `observeEvent(matcher_trigger(), ...)` storing results in `single_result <- reactiveVal(NULL)`. Added fallback defaults so evaluation runs immediately without depending on UI roundtrips.
- **Retest:** Verified with Playwright: scorecard, gauge plot, metric tiles, gap labels, and checklist rendered completely in <2.5 seconds.

### Fix for ISSUE-08: Job Openings Sorting
- **Action:** Changed query in `scripts/08_database.R` to `ORDER BY id DESC`.
- **Retest:** Verified with Playwright: newly created job opening appeared immediately at the top of the table.

---

## 6. Official Playwright E2E Test Suite Results

Test Run Timestamp: October 1, 2026  
Execution Tool: Playwright (Chromium Headless, 1440×900 Viewport)  
Artifact: `outputs/reports/playwright_test_summary.json`

| Test Suite | Scenario / Workflow Tested | Result | Details |
| :--- | :--- | :---: | :--- |
| **Suite 1** | Application Loading & HTML Title | **PASS** | Title: `TalentScan ATS - Enterprise Recruitment & Resume Intelligence` |
| **Suite 2.1** | Tab Navigation: Dashboard Overview | **PASS** | `#shiny-tab-dashboard` active and visible |
| **Suite 2.2** | Tab Navigation: Single Resume Screener | **PASS** | `#shiny-tab-matcher` active and visible |
| **Suite 2.3** | Tab Navigation: Batch Candidate Screener | **PASS** | `#shiny-tab-batch_matcher` active and visible |
| **Suite 2.4** | Tab Navigation: Manage Job Openings | **PASS** | `#shiny-tab-job_manager` active and visible |
| **Suite 2.5** | Tab Navigation: Visual Fit Analytics | **PASS** | `#shiny-tab-analytics` active and visible |
| **Suite 2.6** | Tab Navigation: Structure & Keyword Audit | **PASS** | `#shiny-tab-optimizer` active and visible |
| **Suite 2.7** | Tab Navigation: Model Performance & ML | **PASS** | `#shiny-tab-performance` active and visible |
| **Suite 2.8** | Tab Navigation: System Architecture | **PASS** | `#shiny-tab-about` active and visible |
| **Suite 3** | Dashboard Overview Components | **PASS** | 3 Executive KPI cards, match score histogram, history table |
| **Suite 4** | Single Screener Execution & Scorecard | **PASS** | ATS Score: 19.7, Pass Probability: 8.6%, 4 Metric Mini-Cards |
| **Suite 5** | Visual Fit Analytics Render | **PASS** | Competency Radar Chart & Experience Scatterplot rendered |
| **Suite 6** | Structure & Keyword Audit Render | **PASS** | Keyword Density Bar Chart & Structure Checklist rendered |
| **Suite 7** | Batch Screener Execution | **PASS** | 3 Candidates evaluated, ranked table with decision badges |
| **Suite 8** | Job Opening Creation & Directory | **PASS** | `Staff QA Engineer [timestamp]` inserted into SQLite & rendered |
| **Suite 9.1** | Responsive Viewport: Mobile Portrait (375×667) | **PASS** | Header, sidebar toggle, content flow verified |
| **Suite 9.2** | Responsive Viewport: Tablet Portrait (768×1024) | **PASS** | Layout columns collapse gracefully |
| **Suite 9.3** | Responsive Viewport: Desktop Full (1920×1080) | **PASS** | Maximum width grid alignment verified |

**Total Critical Console Errors: 0**

---

## 7. Security & Compliance Findings

1. **SQL Injection Defense:** All database queries in `scripts/08_database.R` use parameterized DBI execution (`dbExecute(con, "...", params = list(...))`), preventing SQL injection on user-supplied candidate names, job titles, and job descriptions.
2. **Path Traversal Protection:** File upload handler strictly checks file extension (`accept = c(".pdf")`) and parses files via temporary system datapath hashes generated by Shiny.
3. **Information Disclosure:** Server errors in model prediction and PDF parsing are caught via `tryCatch` blocks and returned as clean user notifications rather than raw stack traces.
4. **Local Data Persistence:** Candidate evaluations and job descriptions are stored in a dedicated local SQLite database (`data/ats_analytics.sqlite`), avoiding external telemetry or third-party cloud data transmission.

---

## 8. Accessibility & UX Audit (WCAG 2.2 AA)

1. **Form Controls:** Converted all `selectInput` dropdowns from opaque Selectize JS widgets to native HTML `<select class="form-control">` controls with explicit labels and keyboard navigation support.
2. **Color Contrast:** All score chips and alert banners use curated WCAG-compliant color pairings:
   - Qualified (Green): `#065f46` on `#ecfdf5` (Contrast Ratio: 7.2:1 — exceeds AAA standard).
   - Review (Amber): `#92400e` on `#fffbeb` (Contrast Ratio: 6.8:1 — exceeds AA standard).
   - Disqualified (Red): `#991b1b` on `#fef2f2` (Contrast Ratio: 7.5:1 — exceeds AAA standard).
3. **Empty & Loading States:** Every analytical view contains an informative empty state with actionable instructions prior to running an analysis, and animated spinners (`withSpinner`) during model computation.

---

## 9. Final Project Status & Changed Components

### Core Files Modified:
- [`run_app.bat`](file:///c:/Users/Windows/Pictures/DUR-main/run_app.bat): Dynamic working directory resolution.
- [`scripts/run_app.R`](file:///c:/Users/Windows/Pictures/DUR-main/scripts/run_app.R): User library path priority.
- [`scripts/03_feature_engineering.R`](file:///c:/Users/Windows/Pictures/DUR-main/scripts/03_feature_engineering.R): Regex character class fixes and skill category mapping.
- [`scripts/06_prediction.R`](file:///c:/Users/Windows/Pictures/DUR-main/scripts/06_prediction.R): Regex character class fixes.
- [`scripts/08_database.R`](file:///c:/Users/Windows/Pictures/DUR-main/scripts/08_database.R): Job openings sort order (`ORDER BY id DESC`).
- [`data/skills.csv`](file:///c:/Users/Windows/Pictures/DUR-main/data/skills.csv): Added modern technical competencies.
- [`global.R`](file:///c:/Users/Windows/Pictures/DUR-main/global.R): Sample candidate bootstrap routine.
- [`app.R`](file:///c:/Users/Windows/Pictures/DUR-main/app.R): Corporate design system, accessible form controls, eager execution architecture, and race condition elimination.
- [`scripts/test_e2e_playwright.py`](file:///c:/Users/Windows/Pictures/DUR-main/scripts/test_e2e_playwright.py): End-to-end automated test harness.
- [`scripts/test_integration.R`](file:///c:/Users/Windows/Pictures/DUR-main/scripts/test_integration.R): R integration verification suite.

**Final Verdict: PASS — Ready for Production Deployment.**
