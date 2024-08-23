# utils.R
# This script contains utility functions

# Function that returns base directory
base_dir <- function() {
  return(path.expand("~/Documents/phd"))
}

# Function to load specific metric data and add a phase column
load_metric <- function(metric, path) {
  # Define the estrous stages and initialize an empty list to store the data
  estrous_stages <- c("proestrus", "estrus", "metestrus", "diestrus")
  metric_data <- list()

  # Loop over each estrous stage
  for (stage in estrous_stages) {
    # Construct the file path
    file_path <- file.path(path, stage, paste0(metric, ".csv"))

    # Check if the file exists
    if (file.exists(file_path)) {
      # Read the data and add a column for the phase
      data <- read.csv(file_path)
      data$Phase <- stage
      metric_data[[stage]] <- data
    } else {
      warning(sprintf('File "%s" not found. Skipping.', file_path))
      metric_data[[stage]] <- data.frame() # Empty data frame if file not found
    }
  }

  return(metric_data)
}

# Function to combine data from different estrous stages
combine_data <- function(data_list) {
  # Combine data from different stages
  combined_data <- bind_rows(data_list, .id = "Phase")
  combined_data$Phase <- factor(combined_data$Phase, levels = names(data_list))
  return(combined_data)
}

# Function to get the proper y-axis label based on the metric
get_label <- function(metric) {
  # Define y-axis labels based on the metric
  label <- switch(metric,
    "sw_duration" = "Slow-wave duration (s)",
    "fw_duration" = "Fast-wave duration (s)",
    "fw_delay" = "Fast-wave delay (s)",
    "event_interval" = "Event interval (s)",
    "fw_occurence" = "Fast-wave occurence (%)",
    "prop_vel" = "Propagation velocity (mm/s)",
    "Unknown Metric" # Fallback for metrics not listed
  )
  return(label)
}
