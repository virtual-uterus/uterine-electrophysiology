# statistical_analysis.R
# This is the main script

# Load required packages
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(lme4))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(ggsignif))
suppressPackageStartupMessages(library(emmeans))
suppressPackageStartupMessages(library(car))

# Source other scripts
source("utils.R")
source("plots.R")

# Create parser
parser <- ArgumentParser(description = "Perform statistical analysis on data.")
parser$add_argument("dir",
  type = "character",
  help = "path to data directory from base directory"
)
parser$add_argument("metric", type = "character", help = "metric to analyse")
parser$add_argument("--save-dir",
  type = "character", default = "electrophys/figures/stats",
  help = "path to save directory"
)

# Parse arguments
args <- parser$parse_args()

# Retrieve arguments
data_dir <- file.path(base_dir(), args$dir)
metric <- args$metric

# Load the data
data <- load_metric(metric, data_dir)

# Combine data
long_data <- combine_data(data)

# Check normality using Shapiro-Wilk test for each phase
normality_results <- long_data %>%
  group_by(Phase) %>%
  summarize(normality_p = shapiro.test(Value)$p.value)
# Print normality results
print(normality_results)

# Perform mixed-effects model
model <- aov(Value ~ Phase, data = long_data)

# Plot results
plot_anova_results(long_data, model, metric)

# Save the plot to a file
save_file <- paste0(metric, ".png")
save_path <- file.path(file.path(base_dir(), args$save_dir), save_file)
ggsave(save_path, plot = last_plot(), dpi = 300)
