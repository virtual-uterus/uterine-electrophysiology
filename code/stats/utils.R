# utils.R
# This script contains utility functions

# Function that returns base directory
base_dir <- function() {
  return(path.expand("~/Documents/phd"))
}

# Function to load specific metric data and add a phase column
load_metric <- function(metric, path) {
  # Define the estrus stages and initialize an empty list to store the data
  estrus_stages <- c("proestrus", "estrus", "metestrus", "diestrus")
  metric_data <- list()

  # Loop over each estrus stage
  for (stage in estrus_stages) {
    # Construct the file path
    file_path <- file.path(path, stage, paste0(metric, ".csv"))

    # Check if the file exists
    if (file.exists(file_path)) {
      # Read the data, first row as column names (experiment names)
      data <- read.csv(file_path, header = FALSE)

      # Extract experiment numbers (first row) and event numbers (second row)
      experiment_numbers <- as.character(data[1, ])
      event_numbers <- as.character(data[2, ])

      # Extract the actual observation data (from the third row onwards)
      observations <- data[-c(1, 2), ]

      # Convert the data to long format
      long_data <- pivot_longer(as.data.frame(observations),
        cols = everything(),
        names_to = NULL,
        values_to = "Value"
      )

      # Add the experiment and event columns and phase
      long_data$Experiment <- rep(experiment_numbers, each = nrow(observations))
      long_data$Transition <- rep(event_numbers, each = nrow(observations))
      long_data$Phase <- stage
      long_data$Value <- as.numeric(long_data$Value)

      # Store the reshaped data in the list
      metric_data[[stage]] <- long_data
    } else {
      warning(sprintf('File "%s" not found. Skipping.', file_path))
      metric_data[[stage]] <- data.frame() # Empty data frame if file not found
    }
  }

  return(metric_data)
}

# Function to load propagation direction data and add a phase column
load_direction <- function(path) {
  # Define the estrus stages and initialize an empty list to store the data
  estrus_stages <- c("proestrus", "estrus", "metestrus", "diestrus")
  metric_data <- list()

  # Loop over each estrus stage
  for (stage in estrus_stages) {
    # Construct the file path
    file_path <- file.path(path, stage, paste0("prop_direction", ".csv"))

    # Check if the file exists
    if (file.exists(file_path)) {
      # Read the data, first row as column names (experiment names)
      data <- read.csv(file_path, header = FALSE)

      # Convert the data to long format
      long_data <- pivot_longer(as.data.frame(data),
        cols = everything(),
        names_to = NULL,
        values_to = "Value"
      )

      # Add the phase
      long_data$Phase <- stage
      long_data$Value <- as.numeric(long_data$Value)

      # Store the reshaped data in the list
      metric_data[[stage]] <- long_data
    } else {
      warning(sprintf('File "%s" not found. Skipping.', file_path))
      metric_data[[stage]] <- data.frame() # Empty data frame if file not found
    }
  }

  return(metric_data)
}

# Function to combine data from different estrus stages
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
    "fw_presence" = "Fast-wave presence (%)",
    "prop_vel" = "Propagation velocity (mm/s)",
    "Unknown Metric" # Fallback for metrics not listed
  )
  return(label)
}
