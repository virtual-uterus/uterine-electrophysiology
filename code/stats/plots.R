# plots.R
# This script contains plotting functions

# Function to plot the results
plot_anova_results <- function(data, model, metric) {
  # Remove non-finite values
  data <- data %>% filter(is.finite(Value))

  # Calculate the means for each experiment within each phase
  data_means <- data %>%
    group_by(Phase, Experiment) %>%
    summarise(Mean = mean(Value, na.rm = TRUE), .groups = "drop")

  # Plot
  p <- ggplot(data, aes(x = Phase, y = Value)) +
    geom_boxplot(aes(fill = Phase),
      outlier.shape = NA,
      show.legend = FALSE
    ) + # Boxplot
    geom_point(
      data = data_means,
      aes(x = Phase, y = Mean, color = "#FF0000"),
      size = 3,
      shape = 16,
      show.legend = FALSE
    ) + # Mean points
    theme_classic(base_size = 14) +
    scale_x_discrete(labels = function(x) {
      tools::toTitleCase(x)
    }) + # Capitalize first letter of x-axis labels
    labs(
      x = "Estrus phase",
      y = get_label(metric)
    ) +
    scale_fill_brewer(palette = "Pastel1") +

    # Define comparisons and their y-positions
    comparisons <- list(
    c("metestrus", "diestrus"),
    c("estrus", "metestrus"),
    c("estrus", "diestrus"),
    c("proestrus", "estrus"),
    c("proestrus", "metestrus"),
    c("proestrus", "diestrus")
  )

  # Compute maximum y-values for each comparison to avoid overlap
  y_max <- max(data$Value, na.rm = TRUE)

  # Define y-offsets for significance bars to prevent overlap
  offset <- y_max * 0.05 # Increase the offset as needed

  # Generate y_positions for each comparison
  y_positions <- sapply(seq_along(comparisons), function(i) y_max + i * offset)

  # Plot with adjusted significance bars
  p <- p + geom_signif(
    comparisons = comparisons,
    map_signif_level = TRUE, test = "t.test",
    textsize = 3,
    y_position = y_positions
  )
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
