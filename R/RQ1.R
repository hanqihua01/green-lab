library(dplyr)
library(car)
library(ARTool)
library(ggplot2)

memory_data <- read.csv("memory_run_table.csv")
cpu_data <- read.csv("cpu_run_table.csv")
io_data <- read.csv("io_run_table.csv")

fill_missing_values <- function(data) {
  for (col in colnames(data)) {
    if (any(is.na(data[[col]]))) {
      data[[col]][is.na(data[[col]])] <- mean(data[[col]], na.rm = TRUE) 
    }
  }
  return(data)
}

memory_data_filled <- fill_missing_values(memory_data)
cpu_data_filled <- fill_missing_values(cpu_data)
io_data_filled <- fill_missing_values(io_data)

perform_analysis <- function(task_data, task_type) {

  task_data$technique <- as.factor(task_data$technique)

  shapiro_results <- task_data %>%
    group_by(technique) %>%
    summarize(shapiro_p_value = shapiro.test(total_energy)$p.value)
  print(paste("Shapiro-Wilk Test Results for", task_type, ":"))
  print(shapiro_results)
  
  normality_check <- all(shapiro_results$shapiro_p_value > 0.05)
  
  levene_test_result <- leveneTest(total_energy ~ technique, data = task_data)
  print(paste("Levene’s Test Result for", task_type, ":"))
  print(levene_test_result)
  
  homogeneity_check <- levene_test_result$`Pr(>F)`[1] > 0.05
  
  if (normality_check && homogeneity_check) {
    print(paste("Performing standard ANOVA for", task_type, "..."))
    anova_result <- aov(total_energy ~ technique, data = task_data)
    summary(anova_result)
    
    if (summary(anova_result)[[1]]$`Pr(>F)`[1] < 0.05) {
      tukey_result <- TukeyHSD(anova_result)
      print(paste("Tukey’s HSD Results for", task_type, ":"))
      print(tukey_result)
    }
    
  } else {
      print(paste("Performing ARTool for", task_type, "due to assumption violations..."))
      
      art_result <- art(total_energy ~ technique, data = task_data)
      anova_result <- anova(art_result)
      
      print(anova_result)

      if (anova_result$`Pr(>F)`[1] < 0.05) {
        print("ARTool ANOVA is significant. Performing post-hoc comparisons...")
        
        art_posthoc <- art.con(art_result, "technique")
        print(summary(art_posthoc))
      } else {
        print("ARTool ANOVA is not significant. No post-hoc analysis required.")
      
    }
  }
  
p <- ggplot(task_data, aes(x = technique, y = total_energy, fill = technique)) +
      geom_violin(trim = FALSE) +
      geom_boxplot(width = 0.1) +
      theme_minimal() +
      labs(title = paste("Energy Consumption by Technique (", task_type, ")", sep = ""),
           x = "Technique", y = "Total Energy (Joules)") +
      theme(legend.position = "none")
  ggsave(paste("images/RQ1/", task_type, "_violin.png", sep = ""), plot = p, width = 8, height = 6, dpi = 300)
  
  return(p)
}

memory_plot <- perform_analysis(memory_data_filled, "Memory-bound")

cpu_plot <- perform_analysis(cpu_data_filled, "CPU-bound")

io_plot <- perform_analysis(io_data_filled, "IO-bound")
