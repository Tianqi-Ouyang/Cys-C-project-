# Pipeline diagram for analysis_2026-03-19.qmd
# Run this script to regenerate pipeline_plot.png

library(ggplot2)
library(grid)

# --- node definitions ---
nodes <- data.frame(
  id    = 1:14,
  label = c(
    "REDCap CSV\n(880 patients)",
    "Standardise &\nrename ED/Hosp",
    "Hosp events\n(reasons 1–11)",
    "Side effect\n(hosp 1–7)",
    "Create final_master\n+ drug indicators",
    "Rename dates\n(empi→EMPI,\nbl_date→baseline_sample_date)",
    "Load RPDR\n(lab / lab_new /\ndia / med)",
    "Pre-baseline labs\n(HGB, PLT, ALB,\nCRE, K, MG, NA)",
    "eGFR pipeline\n(Cockcroft, CKD-EPI\ncre / cys / combined)",
    "AE outcome labs\n(Anemia g2/3,\nThrom g2/3,\nAKI g2/3)",
    "Data cleaning\n(mortality, exclusions,\nexposure, BMI, platinum,\nCharlson, thyroid)",
    "cmp_variable()\n(all outcomes:\nAE + hosp + electrolytes)",
    "Electrolyte outcomes\n(Hypokalemia,\nHypomagnesemia,\nHyponatremia)",
    "final_master\n(analysis-ready)"
  ),
  x = c(1,  2,  3,  4,   3,   3,   5,   6,   7,   6,   5,   6,   6,   8),
  y = c(8,  8,  8,  8,   6,   4,   8,   7,   6,   5,   3,   2,   4,   1),
  fill = c(
    "#AED6F1","#AED6F1","#AED6F1","#AED6F1",
    "#A9DFBF","#A9DFBF",
    "#FAD7A0","#FAD7A0","#FAD7A0","#FAD7A0",
    "#D7BDE2",
    "#F9E79F",
    "#FAD7A0",
    "#EC7063"
  ),
  stringsAsFactors = FALSE
)

# --- edges (from → to) ---
edges <- data.frame(
  from = c(1, 2, 3, 4, 1, 5, 6, 7, 8, 9, 10, 6, 11, 12, 13),
  to   = c(2, 3, 4, 5, 5, 6, 5, 8, 9, 11,11, 7, 12, 14, 12)
)

p <- ggplot() +
  # edges
  geom_segment(
    data = edges,
    aes(
      x    = nodes$x[from], xend = nodes$x[to],
      y    = nodes$y[from], yend = nodes$y[to]
    ),
    arrow = arrow(length = unit(0.25, "cm"), type = "closed"),
    colour = "grey50", linewidth = 0.6
  ) +
  # nodes
  geom_tile(
    data = nodes,
    aes(x = x, y = y, fill = fill),
    width = 1.6, height = 0.9, colour = "grey30", linewidth = 0.4
  ) +
  geom_text(
    data = nodes,
    aes(x = x, y = y, label = label),
    size = 2.4, lineheight = 0.9
  ) +
  scale_fill_identity() +
  coord_fixed() +
  theme_void() +
  labs(
    title    = "Analysis Pipeline — analysis_2026-03-19.qmd",
    subtitle = paste0(
      "Blue = REDCap  |  Green = Merge/rename  |  ",
      "Orange = RPDR  |  Purple = Cleaning  |  Yellow = cmp_variable  |  Red = Output"
    )
  ) +
  theme(
    plot.title    = element_text(size = 11, face = "bold", hjust = 0.5, margin = margin(b = 4)),
    plot.subtitle = element_text(size = 7,  hjust = 0.5,  colour = "grey40")
  )

ggsave(
  filename = "/Users/to909/Desktop/Meg/Cystain C redcap/pipeline_plot.png",
  plot = p, width = 14, height = 9, dpi = 150
)
message("Saved: pipeline_plot.png")
