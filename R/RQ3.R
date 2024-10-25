library(dplyr)
library(ggplot2)
library(tidyr)

calculate_energy_efficiency <- function(data) {
  data$cpu_utilization <- ((data$cpu_user_time + data$cpu_system_time) * 1000) / (data$execution_time * 4) * 100
  
  data$energy_efficiency_time <- 1 / (data$total_energy * data$execution_time)
  
  data$energy_efficiency_time <- data$energy_efficiency_time * 1e6
  return(data)
}

memory_data <- calculate_energy_efficiency(memory_data)
cpu_data <- calculate_energy_efficiency(cpu_data)
io_data <- calculate_energy_efficiency(io_data)

memory_data$mem_usage <- memory_data$mem_usage / (1024^2)
cpu_data$mem_usage <- cpu_data$mem_usage / (1024^2)
io_data$mem_usage <- io_data$mem_usage / (1024^2)

generate_bar_plot <- function(data, task_type) {
  long_data <- data %>%
    pivot_longer(cols = c("execution_time", "cpu_utilization", "mem_usage", "energy_efficiency_time"),
                 names_to = "metric", values_to = "value") %>%
    mutate(metric = case_when(
      metric == "execution_time" ~ "Execution Time (ms)",
      metric == "cpu_utilization" ~ "CPU Utilization (%)",
      metric == "mem_usage" ~ "Memory Usage (MB)",
      metric == "energy_efficiency_time" ~ "Energy Efficiency (1/MJ·ms)"
    ))

  mean_data <- long_data %>%
    group_by(technique, metric) %>%
    summarize(mean_value = mean(value, na.rm = TRUE), .groups = "drop")

  bar_plot <- ggplot(mean_data, aes(x = technique, y = mean_value, fill = technique)) +
    geom_bar(stat = "identity", position = "dodge") +
    facet_wrap(~ metric, scales = "free_y") +
    labs(title = paste("Mean Comparison -", task_type),
         x = "Technique", y = "Mean Value") +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  ggsave(paste0("images/RQ3/", task_type, "_bar_plot.png"), plot = bar_plot, width = 7, height = 5, dpi = 300)
}

generate_bar_plot(memory_data, "Memory-bound")
generate_bar_plot(cpu_data, "CPU-bound")
generate_bar_plot(io_data, "IO-bound")
