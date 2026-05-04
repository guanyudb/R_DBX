# Shared ggplot theme — sourced by notebook 03

theme_taxi <- function() {
  ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(face = "bold"),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position  = "bottom"
    )
}

taxi_palette <- c("#0072B2", "#E69F00", "#009E73", "#CC79A7")
