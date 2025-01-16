# plots.R
# This script contains plotting functions

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(ggsignif))
suppressPackageStartupMessages(library(ggpattern))
suppressPackageStartupMessages(library(emmeans))

# Function to plot the statistical analysis results
plot_anova_results <- function(data, model, metric) {
  data <- data %>% filter(is.finite(Value))

  # Compute maximum y-values for each comparison to avoid overlap
  y_max <- max(data$Value, na.rm = TRUE)
  y_min <- 0

  # If metric is "sw_duration" or "fw_duration"
  if (metric %in% c("sw_duration", "fw_duration")) {
    y_max <- 25
  }

  # Calculate the means for each experiment within each phase
  data_means <- data %>%
    group_by(Phase, Experiment, Transition) %>%
    summarise(Mean = mean(Value, na.rm = TRUE), .groups = "drop")

  # Calculate the means and standard deviations for each phase
  data_summary <- data %>%
    group_by(Phase) %>%
    summarise(
      Mean = mean(Value, na.rm = TRUE),
      STD = sd(Value, na.rm = TRUE) / sqrt(n()),
      Value = first(Value),
      .groups = "drop"
    )

  # Plot
  p <- ggplot(data, aes(x = Phase, y = Value)) +
    geom_jitter(
      data = data_means,
      aes(x = Phase, y = Mean),
      color = "black",
      size = 3,
      shape = 16,
      show.legend = FALSE,
      width = 0.1
    ) +
    geom_point(
      data = data_summary,
      aes(x = Phase, y = Mean, color = factor(Phase)),
      size = 4,
      shape = 16,
      show.legend = FALSE
    ) +
    geom_errorbar(
      data = data_summary, # Use data_summary for error bars
      aes(x = Phase, ymin = Mean - STD, ymax = Mean + STD, color = Phase),
      linewidth = 1,
      width = 0.2,
      show.legend = FALSE
    ) +
    theme_classic(base_size = 21) +
    scale_x_discrete(labels = function(x) {
      tools::toTitleCase(x)
    }) +
    labs(
      x = "Estrus phase",
      y = get_label(metric)
    ) +
    scale_colour_brewer(palette = "Set1") +
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
    offset <- y_max * 0.015 * (nrow(significant_comparisons)) # Adjust offset based on the number of bars

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
  p <- ggplot(data, aes(
    x = Phase,
    y = Data,
    fill = Phase,
    pattern = Direction,
    alpha = 0.9,
  )) +
    geom_bar_pattern(
      stat = "identity", position = "stack",
      pattern_angle = 45,
      color = "black", # Add black contour to the bars
      pattern_fill = "black",
      pattern_density = 0.1,
      pattern_spacing = 0.025,
      pattern_key_scale_factor = 0.8,
    ) +
    labs(
      x = "Estrus phase",
      y = "Propagation directions (%)"
    ) +
    scale_x_discrete(labels = function(x) {
      toupper(substr(x, 1, 1))
    }) + # Use only the first letter and capitalise it
    scale_fill_brewer(palette = "Set1") +
    scale_pattern_manual(values = c("none", "circle", "stripe")) +
    theme_classic(base_size = 21) +
    theme(
      legend.title = element_blank(), # Remove the legend title
      legend.key = element_rect(fill = "white", color = "black"),
    ) +
    guides(
      fill = "none", # Remove the fill legend (Phase)
      alpha = "none",
      pattern = guide_legend(
        title = "Direction"
      )
    )
}
