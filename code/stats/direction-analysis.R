# direction-analysis.R
# This script loads and plots the propagation direction

# Load required packages
suppressPackageStartupMessages(library(argparse))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(ggplot2))

# Source other scripts
source("utils.R")
source("plots.R")

# Create parser
parser <- ArgumentParser(
  description = "Load and plot the propagation direction."
)
parser$add_argument("dir",
  type = "character",
  help = "path to data directory from base directory"
)
parser$add_argument("--save-dir",
  type = "character", default = "electrophys/figures/stats",
  help = "path to save directory"
)

# Parse arguments
args <- parser$parse_args()

# Retrieve arguments
data_dir <- file.path(base_dir(), args$dir)
metric <- "prop_direction"

# Load the data
data <- load_direction(data_dir)

# Combine data
combined_data <- combine_data(data)

# Calculate the percentage of each direction type
processed_data <- combined_data %>%
  filter(!is.na(Value)) %>% # Remove NA values
  group_by(Phase, Value) %>%
  summarise(Data = n(), .groups = "drop") %>%
  group_by(Phase) %>%
  mutate(Data = 100 * Data / sum(Data)) %>%
  mutate(Direction = factor(Value,
    levels = c("1", "-1", "0"),
    labels = c("Ovaries → Cervix", "Cervix → Ovaries", "Other")
  ))

# Plot results
plot_prop_direction(processed_data)

# Save the plot to a file
save_file <- paste0(metric, ".png")
save_path <- file.path(file.path(base_dir(), args$save_dir), save_file)
ggsave(save_path, plot = last_plot(), dpi = 300)
