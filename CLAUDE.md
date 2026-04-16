# CLAUDE.md

@~/.claude/hospital-privacy.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a clinical research analysis project investigating whether the baseline creatinine-to-cystatin C ratio predicts adverse events in cancer patients receiving platinum-based chemotherapy (cisplatin/carboplatin). The primary exposure is `cr_cys_7` (creatinine/cystatin C ratio < 0.7).

## Running the Analysis

This project uses R Markdown. To render the primary analysis:

```r
rmarkdown::render("final code for ratio of cystatin and cre_platinum_ae_revised_0709 downloaded 1127.Rmd")
```

Or open in RStudio and use the **Knit** button. Output is an HTML document.

## Files

- **`final code for ratio of cystatin and cre_platinum_ae_revised_0709 downloaded 1127.Rmd`** — Primary analysis file (~3,700 lines). This is the authoritative version.
- **`Copy 709.Rmd`** — Earlier draft; may differ from the primary file.
- **`CystatinCInPatientsO_DATA_2025-07-24_1327.csv`** — REDCap export (880 patients, ~150 variables).
- **`Cystatin C in Patients on Cisplatin and Carboplatin _ REDCap.pdf`** — REDCap data dictionary for variable reference.

The primary `.Rmd` also loads external data files (RPDR exports: diagnoses, labs, medications, demographics as `.txt`/`.xlsx` files) that are expected to exist in paths hardcoded in the script.

## Architecture / Data Pipeline

The analysis follows a linear pipeline within the `.Rmd` file:

1. **Data loading** — Merges REDCap CSV with RPDR clinical data (diagnoses, labs, medications, demographics) and supplementary Excel files.
2. **Data cleaning** — Standardizes column names, handles missing values, processes date fields.
3. **Variable creation** — Constructs clinical variables:
   - Kidney function: eGFR from creatinine (CKD-EPI), eGFR from cystatin C, CKD stage
   - Exposure: `cr_cys_7` (creatinine/cystatin C ratio, binary threshold < 0.7)
   - Comorbidity: Charlson score, 15+ drug indicators
   - Treatment: platinum type, dose category (low/high)
4. **Outcome definition** — Events within 90-day follow-up:
   - Grade 2/3 adverse events: anemia, thrombocytopenia, AKI
   - Hospitalizations (11 categories), ED visits (7 categories)
   - Electrolyte abnormalities: hypokalemia (K < 3), hypomagnesemia (Mg < 0.9), hyponatremia (Na < 125)
   - 90-day mortality
5. **Statistical analysis** — Descriptive tables (gtsummary/tableone), competing risk regression (tidycmprsk), cumulative incidence plots (ggcuminc).

## Key R Packages

| Purpose | Packages |
|---|---|
| Data manipulation | tidyverse, dplyr, readxl, openxlsx |
| Descriptive stats | tableone, gtsummary |
| Competing risks | tidycmprsk, cmprsk |
| Survival analysis | survival, survminer, ggsurvfit, finalfit |
| Visualization | ggplot2, ggpubr |
| Comorbidity scoring | comorbidity (Charlson index) |
| Missing data | mice |

## Key Clinical Concepts

- **cr_cys_7**: The main exposure — binary indicator for creatinine/cystatin C ratio < 0.7. Low ratio suggests muscle wasting (sarcopenia) independent of GFR.
- **Competing risks framework**: Death is treated as a competing event for non-fatal outcomes; `tidycmprsk::crr()` is used instead of standard Cox regression.
- **Platinum dosing**: Cisplatin ≥ 70 mg/m² and carboplatin AUC ≥ 5 are categorized as "high dose."
- **CKD staging**: Based on Cockcroft-Gault eGFR from pre-baseline creatinine values from RPDR labs.
- **eGFR cap at 125**: Both `ckd_epi_gfr_cre_cys_unindex` and `cockcroft` are capped at 125 mL/min in the Jiaxuan analysis files (`jiaxuan_whole.qmd`, `jiaxuan_carbo.qmd`). Unindexing by BSA can produce physiologically implausible values (e.g., >400 mL/min) in patients with extreme body habitus. Always use the capped versions for eGFR ratio, eGFR discrepancy, and all downstream models/plots.
