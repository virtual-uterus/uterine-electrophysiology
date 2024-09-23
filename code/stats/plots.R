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

  # Set y_min to 0 if y_min is positive, otherwise set it to y_min
  y_min <- ifelse(y_min > 0, 0, y_min)

  # Calculate the means for each experiment within each phase
  data_means <- data %>%
    group_by(Phase, Experiment) %>%
    summarise(Mean = mean(Value, na.rm = TRUE), .groups = "drop")

  # Plot
  p <- ggplot(data, aes(x = Phase, y = Value)) +
    geom_boxplot(aes(fill = Phase),
      outlier.shape = NA,
      show.legend = FALSE
    ) +
    geom_point(
      data = data_means,
      aes(x = Phase, y = Mean, color = "#FF0000"),
      size = 3,
      shape = 16,
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
    scale_fill_brewer(palette = "Accent") +
    coord_cartesian(ylim = c(y_min, NA))

  # Extract pairwise comparisons from the model
  pairwise_comparisons <- emmeans::emmeans(model, pairwise ~ Phase)
  comparison_results <- as.data.frame(pairwise_comparisons$contrasts)
  comparison_results <- comparison_results[rev(
    seq_len(nrow(comparison_results))
  ), ]

  comparisons <- comparison_results %>%
    mutate(contrast = strsplit(as.character(contrast), " - ")) %>%
    pull(contrast)

  # Map p-values to stars
  comparison_results <- comparison_results %>%
    mutate(stars = case_when(
      p.value < 0.001 ~ "***",
      p.value < 0.01 ~ "**",
      p.value < 0.05 ~ "*",
      TRUE ~ "ns"
    ))

  # Define y-offsets for significance bars to prevent overlap
  offset <- y_max * 0.10 # Increase the offset as needed

  # Generate y_positions for each comparison
  y_positions <- y_max + seq_along(comparisons) * offset

  # Plot with adjusted significance bars
  p <- p + geom_signif(
    comparisons = comparisons,
    annotations = comparison_results$stars,
    map_signif_level = FALSE,
    textsize = 5,
    tip_length = 0.02, # Controls the length of the brackets
    y_position = y_positions,
    margin_top = 0.1,
    size = 1.3
  )
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
