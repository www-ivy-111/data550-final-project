library(tidyverse)
library(caret)
library(knitr)

here::i_am("code/01_split_data.R")

# Read the data --------------------------------
data_path <- here::here("data/Thyroid_Diff.csv")
Thy_Diff.raw <- read_csv(data_path)

Thy_Diff.raw <- Thy_Diff.raw %>% 
  rename(
    "Tumor" = "T",
    "Node" = "N",
    "Metastasis" = "M",
    "Smoking History" = "Hx Smoking",
    "Radiothreapy History" = "Hx Radiothreapy"
  )


# Split the dataset --------------------------------
set.seed(111)
Thy_Diff <- mutate(Thy_Diff.raw, Recurred = if_else(Recurred=="Yes", 1, 0))
index <- createDataPartition(y = Thy_Diff$Recurred, p = 0.7, list=FALSE)

train_df <- Thy_Diff[index, ]
test_df <- Thy_Diff[-index, ]


Thy_Diff <- mutate(Thy_Diff, Train = if_else(row_number() %in% index, "Training", "Testing"))
kable(t(table(Thy_Diff$Train)))

saveRDS(
  Thy_Diff,
  file = here::here("data", "clean_data.rds")
)

saveRDS(
  train_df,
  file = here::here("data", "train.rds")
)

saveRDS(
  test_df,
  file = here::here("data", "test.rds")
)


