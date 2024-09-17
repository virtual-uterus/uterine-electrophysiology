# statistical_analysis.R
# This is the main script

if (!require("tidyverse")) install.packages("tidyverse")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("argparse")) install.packages("argparse")
if (!require("ggsignif")) install.packages("ggsignif", dependencies = TRUE)
if (!require("lme4")) install.packages("lme4")
if (!require("emmeans")) install.packages("emmeans")
if (!require("car")) install.packages("car")

# Load required packages
library(argparse)
library(lme4)
library(tidyverse)
library(ggplot2)
library(ggsignif)
library(emmeans)
library(car)

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

# Perform mixed-effects model
model <- lmer(Value ~ Phase + (1 | Experiment / Event), data = long_data)

# Extract residuals from the model
residuals <- residuals(model)

ks_test_res <- ks.test(residuals(model),
  "pnorm",
  mean = mean(residuals(model)), sd = sd(residuals(model))
)
print(ks_test_res)

# Plot a Q-Q plot to visually inspect the residuals for normality
qqnorm(residuals)
qqline(residuals)

# Plot results
plot_anova_results(long_data, model, metric)

# Save the plot to a file
save_file <- paste0(metric, ".png")
save_path <- file.path(file.path(base_dir(), args$save_dir), save_file)
ggsave(save_path, plot = last_plot(), dpi = 300)
