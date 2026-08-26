# Conversation History: Running Resume ATS Score Analytics


To run the R Shiny application, you have two primary options:

### Option 1: Double-click the Batch File (Recommended & Easiest)
We have a pre-configured batch file [`run_app.bat`](file:///c:/Users/Windows/Documents/R/ResumeATSAnalytics/run_app.bat) that verifies/installs the required R packages and launches the Shiny application.

1. Open your Windows File Explorer and navigate to:
   `C:\Users\Windows\Documents\R\ResumeATSAnalytics`
2. Double-click the file named **`run_app.bat`**.
3. A command prompt window will open, check for packages, train the machine learning models (on first run), and launch the app.
4. Once running, open your web browser and go to:
   **`http://127.0.0.1:3838`**

---

### Option 2: Run directly from RStudio / R Console
If you prefer running it inside RStudio:

1. Open **RStudio**.
2. Set your working directory to the project folder:
   ```R
   setwd("C:/Users/Windows/Documents/R/ResumeATSAnalytics")
   ```
3. Run the application:
   ```R
   shiny::runApp()
   ```

*Note: On your first launch, the application will automatically perform a self-healing bootstrap to create the folders, download raw datasets, train the Machine Learning models, and compile the Random Forest predictor (`models/randomForest_model.rds`).*

---

Publish this conversation into GitHub repo at:
https://github.com/RaghuBharathi3/DUR

# Instructions
- Initialize Git if not already.
- Add this conversation as a new file (e.g., convo.md).
- Stage and commit with clear message: "Publish conversation".
- Push to remote origin at the given repo URL.
- Ensure repo remains the same (no overwrite of unrelated files).
- Confirm push success and provide final repo URL.
