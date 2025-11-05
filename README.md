
Code to support my slides for "Anayzing Structured Data with AI".  This code largely mirrors Etsy's [Understanding Etsy’s Vast Inventory with LLMs](https://www.etsy.com/codeascraft/understanding-etsyas-vast-inventory-with-llms) post.

Code in `src` scrapes Eric Longenhagen's 2025 Top 100 prospects, passes those reports to Claude for analysis, then analyzes the Claude results.

To run:

1. `pull-scout-data.r` scrapes Longenhagen's reports.
2. `main.py` passes the scraped reports to Claude for analysis, using the `prompt-system.md` prompt.
3. `analyze-scout-outputs.R` does some exploratory analysis of the Claude scraping.

