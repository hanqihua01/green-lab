library(dplyr)
library(car)
library(ARTool)
library(ggplot2)

fill_missing_values <- function(data) {
  for (col in colnames(data)) {
    if (any(is.na(data[[col]]))) {
      data[[col]][is.na(data[[col]])] <- mean(data[[col]], na.rm = TRUE)  # Use mean to fill missing values
    }
  }
  return(data)
}

memory_data <- read.csv("memory_run_table.csv")
cpu_data <- read.csv("cpu_run_table.csv")
io_data <- read.csv("io_run_table.csv")

memory_data <- fill_missing_values(memory_data)
cpu_data <- fill_missing_values(cpu_data)
io_data <- fill_missing_values(io_data)

run_analysis <- function(task_data, task_type) {
  task_data$technique <- as.factor(task_data$technique)

  shapiro_test <- shapiro.test(task_data$total_energy)
  print(paste("Shapiro-Wilk Test for", task_type, ": p-value =", shapiro_test$p.value))
  
  levene_test <- leveneTest(total_energy ~ technique, data = task_data)
  print(paste("Levene’s Test for", task_type, ": p-value =", levene_test$`Pr(>F)`[1]))
  
  if (shapiro_test$p.value > 0.05 && levene_test$`Pr(>F)`[1] > 0.05) {
    print(paste("Performing standard ANOVA for", task_type, "..."))
    anova_result <- aov(total_energy ~ technique, data = task_data)
    print(summary(anova_result))
    return(anova_result)
  } else {
    print(paste("Performing ARTool for", task_type, "due to assumption violations..."))
    art_result <- art(total_energy ~ technique, data = task_data)
    print(anova(art_result))
    return(art_result)
  }
}

extract_p_value <- function(result, task_type) {
  if (inherits(result, "aov")) {
    p_value <- summary(result)[[1]]$`Pr(>F)`[1]
    print(paste("ANOVA p-value for", task_type, ":", p_value))
    return(p_value)
  } else if (inherits(result, "art")) {
    art_summary <- anova(result)
    p_value <- art_summary$`Pr(>F)`[1]
    print(paste("ARTool p-value for", task_type, ":", p_value))
    return(p_value)
  } else {
    print(paste("Unknown result type for", task_type))
    return(NA)
  }
}

memory_anova <- run_analysis(memory_data, "Memory-bound")
cpu_anova <- run_analysis(cpu_data, "CPU-bound")
io_anova <- run_analysis(io_data, "I/O-bound")

p_values <- c(
  extract_p_value(memory_anova, "Memory-bound"),
  extract_p_value(cpu_anova, "CPU-bound"),
  extract_p_value(io_anova, "I/O-bound")
)

p_adjusted <- p.adjust(p_values, method = "bonferroni")
print("Adjusted p-values (Bonferroni):")
print(p_adjusted)

combined_data <- bind_rows(
  mutate(memory_data, task_type = "Memory-bound"),
  mutate(cpu_data, task_type = "CPU-bound"),
  mutate(io_data, task_type = "I/O-bound")
)

combined_data$task_type <- factor(combined_data$task_type, levels = c("Memory-bound", "CPU-bound", "I/O-bound"))

interaction_plot <- ggplot(combined_data, aes(x = task_type, y = total_energy, color = technique, group = technique)) +
  stat_summary(fun = mean, geom = "line", linewidth = 1.5) +  # Use 'linewidth' instead of 'size' for lines
  stat_summary(fun = mean, geom = "point", size = 4) +        # Points remain using 'size'
  theme_minimal() +
  labs(title = "Interaction Plot: Energy Consumption by Task Type and Technique",
       x = "Task Type", y = "Mean Total Energy (Joules)",
       color = "Technique") +
  theme(legend.position = "bottom")

ggsave(paste("images/RQ2/", "interaction_plot_energy.png", sep = ""), plot = interaction_plot, width = 8, height = 6, dpi = 300)
