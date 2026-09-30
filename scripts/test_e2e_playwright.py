"""
End-to-End Automated Testing Suite for TalentScan ATS
Uses Playwright to test all UI/UX workflows, inputs, edge cases, console errors, and responsiveness.
"""

import sys
import time
import json
from playwright.sync_api import sync_playwright

sys.stdout.reconfigure(line_buffering=True)
BASE_URL = "http://127.0.0.1:3838"

def run_tests():
    test_results = []
    console_errors = []
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1440, "height": 900})
        page = context.new_page()
        
        # Track console errors
        page.on("console", lambda msg: console_errors.append(f"[{msg.type}] {msg.text}") if msg.type in ["error"] else None)
        page.on("pageerror", lambda err: console_errors.append(f"[pageerror] {str(err)}"))

        print("=== Test 1: Application Loading & Title ===")
        try:
            page.goto(BASE_URL, wait_until="domcontentloaded", timeout=20000)
            page.wait_for_selector(".main-sidebar", timeout=10000)
            title = page.title()
            assert "TalentScan ATS" in title, f"Unexpected title: {title}"
            print(f"  PASS: Page loaded with title: '{title}'")
            test_results.append({"test": "App Loading & Title", "status": "PASS", "details": title})
        except Exception as e:
            print(f"  FAIL: App Loading & Title: {e}")
            test_results.append({"test": "App Loading & Title", "status": "FAIL", "details": str(e)})

        # Helper to click a sidebar menu item by data-value/tabName
        def click_tab(tab_name):
            link = page.locator(f'a[data-value="{tab_name}"]')
            link.click(force=True)
            page.wait_for_timeout(600)
            pane = page.locator(f'#shiny-tab-{tab_name}')
            assert pane.is_visible(), f"Tab pane #shiny-tab-{tab_name} is not visible"

        print("\n=== Test 2: Navigation Across All 8 Tabs ===")
        tabs = [
            ("dashboard", "Dashboard Overview"),
            ("matcher", "Single Resume Screener"),
            ("batch_matcher", "Batch Candidate Screener"),
            ("job_manager", "Manage Job Openings"),
            ("analytics", "Visual Fit Analytics"),
            ("optimizer", "Structure & Keyword Audit"),
            ("performance", "Model Performance & ML"),
            ("about", "System Architecture")
        ]
        
        for tab_id, tab_label in tabs:
            try:
                click_tab(tab_id)
                print(f"  PASS: Tab '{tab_label}' (#shiny-tab-{tab_id}) active and visible")
                test_results.append({"test": f"Tab Nav: {tab_label}", "status": "PASS", "details": ""})
            except Exception as e:
                print(f"  FAIL: Tab '{tab_label}': {e}")
                test_results.append({"test": f"Tab Nav: {tab_label}", "status": "FAIL", "details": str(e)})

        print("\n=== Test 3: Dashboard Overview Components ===")
        try:
            click_tab("dashboard")
            page.wait_for_selector(".kpi-card", timeout=10000)
            kpis = page.locator(".kpi-card").count()
            assert kpis >= 3, f"Expected at least 3 KPI cards, found {kpis}"
            
            # Check DataTable exists
            dt = page.locator("#history_table")
            assert dt.is_visible(), "History table not visible"
            print(f"  PASS: Dashboard overview has {kpis} KPI cards and history table")
            test_results.append({"test": "Dashboard Overview UI", "status": "PASS", "details": f"{kpis} KPI cards"})
        except Exception as e:
            print(f"  FAIL: Dashboard Overview UI: {e}")
            test_results.append({"test": "Dashboard Overview UI", "status": "FAIL", "details": str(e)})

        print("\n=== Test 4: Single Resume Screener - Empty State & Quick Execution ===")
        try:
            click_tab("matcher")
            page.wait_for_timeout(500)
            
            # Click quick sample eval button
            quick_btn = page.locator("#quick_sample_eval_btn")
            assert quick_btn.is_visible(), "Quick sample button not visible"
            quick_btn.click()
            
            # Wait for results scorecard
            page.wait_for_selector(".scorecard-number", timeout=25000)
            score_text = page.locator(".scorecard-number").inner_text().strip()
            chip_text = page.locator("#score_rating_chip_ui").inner_text().strip()
            print(f"  PASS: Match calculation completed. Score: {score_text} | Status: {chip_text}")
            
            # Verify metric mini cards
            metric_cards = page.locator(".metric-mini-card").count()
            assert metric_cards >= 4, f"Expected >= 4 metric cards, found {metric_cards}"
            
            # Verify download report button is present and active
            dl_btn = page.locator("#download_report_btn")
            assert dl_btn.is_visible(), "Download report button not visible"
            
            test_results.append({"test": "Single Screener Execution", "status": "PASS", "details": f"Score {score_text} ({chip_text})"})
        except Exception as e:
            print(f"  FAIL: Single Screener Execution: {e}")
            test_results.append({"test": "Single Screener Execution", "status": "FAIL", "details": str(e)})

        print("\n=== Test 5: Visual Analytics Tab Populated State ===")
        try:
            click_tab("analytics")
            page.wait_for_selector("#skills_radar_plot", timeout=15000)
            assert page.locator("#skills_radar_plot").is_visible(), "Skills radar plot not visible"
            assert page.locator("#experience_scatter_plot").is_visible(), "Scatter plot not visible"
            print("  PASS: Radar map and scatter plot rendered successfully")
            test_results.append({"test": "Visual Analytics Populated", "status": "PASS", "details": ""})
        except Exception as e:
            print(f"  FAIL: Visual Analytics: {e}")
            test_results.append({"test": "Visual Analytics Populated", "status": "FAIL", "details": str(e)})

        print("\n=== Test 6: Structure & Keyword Audit Tab Populated State ===")
        try:
            click_tab("optimizer")
            page.wait_for_selector("#keyword_density_bar_plot", timeout=15000)
            assert page.locator("#keyword_density_bar_plot").is_visible(), "Keyword density bar plot not visible"
            print("  PASS: Keyword density plot rendered successfully")
            test_results.append({"test": "Keyword Audit Populated", "status": "PASS", "details": ""})
        except Exception as e:
            print(f"  FAIL: Keyword Audit: {e}")
            test_results.append({"test": "Keyword Audit Populated", "status": "FAIL", "details": str(e)})

        print("\n=== Test 7: Batch Screener Execution ===")
        try:
            click_tab("batch_matcher")
            page.wait_for_timeout(400)
            
            # Run batch
            page.locator("#run_batch_btn").click()
            
            # Wait for results table
            page.wait_for_selector("#batch_results_table tbody tr", timeout=35000)
            rows = page.locator("#batch_results_table tbody tr").count()
            assert rows >= 3, f"Expected >= 3 batch candidate rows, found {rows}"
            print(f"  PASS: Batch execution completed with {rows} candidate rows")
            test_results.append({"test": "Batch Screener Execution", "status": "PASS", "details": f"{rows} candidates"})
        except Exception as e:
            print(f"  FAIL: Batch Screener Execution: {e}")
            test_results.append({"test": "Batch Screener Execution", "status": "FAIL", "details": str(e)})

        print("\n=== Test 8: Job Openings Manager Form & Directory ===")
        try:
            click_tab("job_manager")
            page.wait_for_selector("#job_openings_table tbody tr", timeout=10000)
            
            # Add a test job
            test_title = f"Staff QA Engineer {int(time.time())}"
            page.fill("#add_jd_title", test_title)
            page.fill("#add_jd_company", "Enterprise QA Labs")
            page.fill("#add_jd_exp", "4")
            page.fill("#add_jd_desc", "Looking for QA Engineer with Python, Playwright, Selenium, and CI/CD testing skills.")
            page.locator("#save_jd_btn").click()
            
            # Wait specifically for newly created job row in table
            page.wait_for_selector(f"#job_openings_table tbody tr:has-text('{test_title}')", timeout=12000)
            print(f"  PASS: Job position '{test_title}' added and verified in directory")
            test_results.append({"test": "Job Opening Creation", "status": "PASS", "details": test_title})
        except Exception as e:
            print(f"  FAIL: Job Openings Manager: {e}")
            test_results.append({"test": "Job Opening Creation", "status": "FAIL", "details": str(e)})

        print("\n=== Test 9: Responsive Viewports (Mobile & Tablet) ===")
        viewports = [
            ("Mobile Portrait", 375, 667),
            ("Tablet Portrait", 768, 1024),
            ("Desktop Full", 1920, 1080)
        ]
        for vp_name, width, height in viewports:
            try:
                page.set_viewport_size({"width": width, "height": height})
                page.wait_for_timeout(500)
                assert page.locator(".main-header").is_visible(), "Header not visible in viewport"
                assert page.locator(".content-wrapper").is_visible(), "Content wrapper not visible in viewport"
                print(f"  PASS: Viewport {vp_name} ({width}x{height}) responsive layout verified")
                test_results.append({"test": f"Viewport {vp_name}", "status": "PASS", "details": f"{width}x{height}"})
            except Exception as e:
                print(f"  FAIL: Viewport {vp_name}: {e}")
                test_results.append({"test": f"Viewport {vp_name}", "status": "FAIL", "details": str(e)})

        # Save screenshot of dashboard
        page.set_viewport_size({"width": 1440, "height": 900})
        click_tab("dashboard")
        page.wait_for_timeout(1000)
        page.screenshot(path="outputs/graphs/dashboard_playwright.png")
        print("  Dashboard screenshot saved to outputs/graphs/dashboard_playwright.png")

        browser.close()

    print("\n=== Console Output & Errors Audited ===")
    error_count = 0
    for err in console_errors:
        print(f"  [ERROR] {err}")
        error_count += 1
    print(f"Total critical console errors: {error_count}")
    
    # Save report
    with open("outputs/reports/playwright_test_summary.json", "w") as f:
        json.dump({"results": test_results, "console_errors": console_errors}, f, indent=2)
    print("Test summary saved to outputs/reports/playwright_test_summary.json")

if __name__ == "__main__":
    run_tests()
