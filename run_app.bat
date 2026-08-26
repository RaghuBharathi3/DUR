@echo off
cd /d "C:\Users\Windows\Documents\R\ResumeATSAnalytics"
echo ==========================================
echo  Resume ATS Analytics - Launching App...
echo ==========================================
echo.
echo Installing/checking required packages...
"C:\Program Files\R\R-4.3.2\bin\Rscript.exe" scripts\install_packages.R
echo.
echo Starting Shiny dashboard...
echo Open your browser at: http://127.0.0.1:3838
echo (Press Ctrl+C to stop the server)
echo.
"C:\Program Files\R\R-4.3.2\bin\Rscript.exe" scripts\run_app.R
pause
