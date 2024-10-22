# plots.R
# This script contains plotting functions

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(ggsignif))
suppressPackageStartupMessages(library(emmeans))

# Function to plot the statistical analysis results
plot_anova_results <- function(data, model, metric) {
  data <- data %>% filter(is.finite(Value))

  # Compute maximum y-values for each comparison to avoid overlap
  y_max <- max(data$Value, na.rm = TRUE)
  y_min <- min(data$Value, na.rm = TRUE)

  # Adjust y_min to 15 if metric is "sw_duration" or "fw_duration"
  if (metric %in% c("fw_occurrence")) {
    y_min <- 0
  }
  else if (metric %in% c("sw_duration", "fw_duration")) {
    y_min <- 5
    y_max <- 25
  }

  # Calculate the means for each experiment within each phase
  data_means <- data %>%
    group_by(Phase, Experiment, Transition) %>% 
    summarise(Mean = mean(Value, na.rm = TRUE), .groups = "drop")

  # Plot
  p <- ggplot(data, aes(x = Phase, y = Value)) +
    geom_boxplot(aes(fill = Phase),
      show.legend = FALSE
    ) +
    geom_jitter(
      data = data_means,
      aes(x = Phase, y = Mean, color = factor(Transition)),
      size = 3,
      shape = 16,
      show.legend = FALSE,
      width = 0.1
    ) +
    theme_classic(base_size = 21) +
    scale_x_discrete(labels = function(x) {
      tools::toTitleCase(x)
    }) +
    labs(
      x = "Estrus phase",
      y = get_label(metric)
    ) +
    scale_fill_brewer(palette = "Accent") +
    coord_cartesian(ylim = c(y_min, NA))

  # Extract pairwise comparisons from the model
  pairwise_comparisons <- emmeans::emmeans(model, pairwise ~ Phase)
  comparison_results <- as.data.frame(pairwise_comparisons$contrasts)
  comparison_results <- comparison_results[rev(
    seq_len(nrow(comparison_results))
  ), ]

  # Map p-values to stars
  comparison_results <- comparison_results %>%
    mutate(stars = case_when(
      p.value < 0.05 ~ "*",
    ))

  # Check if there are significant comparisons (excluding NA values)
  significant_comparisons <- comparison_results %>%
    filter(!is.na(stars) & stars != "")
  comparisons <- significant_comparisons %>%
    mutate(contrast = strsplit(as.character(contrast), " - ")) %>%
    pull(contrast)
  
  if (nrow(significant_comparisons) > 0) {
    # Define y-offsets for significance bars to prevent overlap, scaled based on the number of comparisons
    offset <- y_max * 0.015 * (nrow(significant_comparisons))  # Adjust offset based on the number of bars
    
    # Generate y_positions for each comparison
    bar_positions <- y_max + seq_len(nrow(significant_comparisons)) * offset
    
    # Plot with adjusted significance bars
    p <- p + geom_signif(
      comparisons = comparisons,
      annotations = significant_comparisons$stars,
      map_signif_level = FALSE,
      textsize = 5,
      tip_length = 0.02, # Controls the length of the brackets
      y_position = bar_positions,
      margin_top = 0.0,
      size = 1.3
    )
  } else {
    # If there are no significant comparisons, reset y_max
    p <- p + coord_cartesian(ylim = c(y_min, y_max))
  }
}

# Function to plot the propagation direction data
plot_prop_direction <- function(data) {
  p <- ggplot(data, aes(x = Phase, y = Data, fill = Direction)) +
    geom_bar(stat = "identity", position = "stack") +
    labs(
      x = "Estrus phase",
      y = "Propagation directions (%)"
    ) +
    scale_x_discrete(labels = function(x) {
      toupper(substr(x, 1, 1))
    }) + # Use only the first letter and capitalise it
    scale_fill_brewer(palette = "Accent") +
    theme_classic(base_size = 21) +
    theme(legend.title = element_blank()) # Remove the legend title
}
