library(ggplot2)

memory_data <- read.csv("memory_run_table.csv")
cpu_data <- read.csv("cpu_run_table.csv")
io_data <- read.csv("io_run_table.csv")

create_boxplot <- function(data, task_type) {
  p <- ggplot(data, aes(x = technique, y = total_energy, fill = technique)) +
    geom_boxplot() +
    theme_minimal() +
    labs(
         title = paste("Energy Consumption by Technique (", task_type, " Task)", sep = ""),
         x = "Technique", y = "Total Energy (Joules)"
    ) +
    theme(legend.position = "none")

  print(p)
  ggsave(paste("images/boxplot/", task_type, "_task_energy_boxplot.png", sep = ""), plot = p, width = 8, height = 6, dpi = 300)

  return(p)
}

create_boxplot(memory_data, "Memory-bound")

create_boxplot(cpu_data, "CPU-bound")

create_boxplot(io_data, "IO-bound")