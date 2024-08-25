# plots.R
# This script contains plotting functions

# Function to plot the statistical analysis results
plot_anova_results <- function(data, model, metric) {
  data <- data %>% filter(is.finite(Value))

  # Calculate the means for each experiment within each phase
  data_means <- data %>%
    group_by(Phase, Experiment) %>%
    summarise(Mean = mean(Value, na.rm = TRUE), .groups = "drop")

  # Perform ANOVA
  aov_results <- aov(Value ~ Phase, data = data)
  summary(aov_results)

  # Perform post-hoc test if ANOVA is significant
  if (summary(aov_results)[[1]][["Pr(>F)"]][1] < 0.05) {
    posthoc_results <- TukeyHSD(aov_results)

    # Extract the results for plotting
    comparisons <- rownames(posthoc_results$Phase)
    p_values <- posthoc_results$Phase[, "p adj"]
    y_positions <- seq(max(data$Value, na.rm = TRUE) + 0.05, length.out = length(comparisons))

    sig_data <- data.frame(
      group1 = sapply(strsplit(comparisons, "-"), `[`, 1),
      group2 = sapply(strsplit(comparisons, "-"), `[`, 2),
      p_value = p_values,
      y_position = y_positions
    )
  } else {
    sig_data <- NULL
  }

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
    theme_classic(base_size = 14) +
    scale_x_discrete(labels = function(x) {
      tools::toTitleCase(x)
    }) +
    labs(
      x = "Estrus phase",
      y = get_label(metric)
    ) +
    scale_fill_brewer(palette = "Pastel1")

  if (!is.null(sig_data)) {
    p <- p + geom_signif(
      comparisons = list(
        c("metestrus", "diestrus"),
        c("estrus", "metestrus"),
        c("estrus", "diestrus"),
        c("proestrus", "estrus"),
        c("proestrus", "metestrus"),
        c("proestrus", "diestrus")
      ),
      map_signif_level = TRUE,
      textsize = 3,
      y_position = sig_data$y_position
    )
  }
}

# Function to plot the propagation direction data
plot_prop_direction <- function(data) {
  p <- ggplot(data, aes(x = Phase, y = Value, fill = Direction)) +
    geom_bar(stat = "identity", position = "stack") +
    labs(
      x = "Estrus phase",
      y = "Propagation directions (%)"
    ) +
    scale_x_discrete(labels = function(x) {
      tools::toTitleCase(x)
    }) + # Capitalize first letter of x-axis labels
    scale_fill_brewer(palette = "Pastel1") +
    theme_classic(base_size = 14) +
    theme(legend.title = element_blank()) # Remove the legend title
}
