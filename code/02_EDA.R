library(tidyverse)
library(ggplot2)
library(gtsummary)
library(patchwork)
library(ggeasy)
library(cowplot)
library(colorspace) 

here::i_am("code/02_EDA.R")
Thy_Diff <- readRDS(here::here("data", "clean_data.rds"))

Thy_Diff <- mutate(Thy_Diff, Recurred = if_else(Recurred==1, "Yes", "No"))


# Table 1 --------------------------------
table_1 <- Thy_Diff %>% 
  tbl_summary(by = Train) %>% 
  add_overall()
table_1

saveRDS(
  table_1,
  file = here::here("output", "table1.rds")
)


# Outcome variable --------------------------------
recurred_plt <- ggplot(data = Thy_Diff) + 
  geom_bar(aes(Recurred, fill = Recurred)) + 
  ggtitle("Distribution of Recurred") + 
  ylab("Count") + 
  theme_classic() + 
  ggeasy::easy_center_title() +
  scale_fill_brewer(palette = "Pastel1")

png(filename = here::here("output", "descriptive_bar_outcome.png"),
    width = 1200, height = 700, res = 200)
recurred_plt
dev.off()


# Continuous Variable --------------------------------
## Age by Gender
age_by_gender_plt <- ggplot(data = Thy_Diff) + 
  geom_histogram(aes(x=Age, fill=Gender)) + 
  ylab("Count") + 
  theme_classic() + 
  ggeasy::easy_center_title() +
  scale_fill_brewer(palette = "Pastel1")

## Age by Recurred
age_by_recuured_plt <- ggplot(data = Thy_Diff) + 
  geom_boxplot(aes(y=Age, x=Recurred, fill=Recurred)) + 
  theme_classic() + 
  ggeasy::easy_center_title() +
  scale_fill_brewer(palette = "Pastel1") +
  theme(legend.position = "none")

## Age by Stage
age_by_stage_plt <- ggplot(data = Thy_Diff) + 
  geom_boxplot(aes(y=Age, x=Stage, fill=Stage)) + 
  theme_classic() + 
  ggeasy::easy_center_title() +
  scale_fill_brewer(palette = "Pastel1") +
  theme(legend.position = "none")

## Age by Risk
age_by_risk_plt <- ggplot(data = Thy_Diff) + 
  geom_boxplot(aes(y=Age, x=Risk, fill=Risk)) + 
  theme_classic() + 
  ggeasy::easy_center_title() +
  scale_fill_brewer(palette = "Pastel1") +
  theme(legend.position = "none")

png(filename = here::here("output", "descriptive_age_plots.png"),
    width = 2400, height = 1400, res = 200)
plot_grid(plotlist = list(age_by_gender_plt, age_by_recuured_plt, age_by_stage_plt, age_by_risk_plt), align = "h", nrow = 2)
dev.off()


# Categorical Variables --------------------------------
pie_df <- Thy_Diff[, !(colnames(Thy_Diff) %in% c("Age", "Recurred"))]

Pie_fn <- function(col){
  pie_df_sub <- as.data.frame(table(pie_df[col]))
  colnames(pie_df_sub)[1] <- "levels"
  ggplot(pie_df_sub, aes(x = "", y = Freq, fill = levels)) +
    geom_bar(width = 1, stat = "identity") +
    coord_polar("y", start = 0) +
    theme_void() + 
    labs(title = col, fill = col) +
    scale_fill_brewer(palette = "Pastel1")
} 

pie_list <- lapply(colnames(pie_df), Pie_fn)

png(filename = here::here("output", "descriptive_pie_charts.png"),
    width = 3000, height = 1600, res = 200)
plot_grid(plotlist = pie_list, align = "vh", nrow = 4)
dev.off()
