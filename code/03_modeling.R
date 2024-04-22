library(tidyverse)
library(ggplot2)
library(gtsummary)
library(car)
library(ROCR)
library(pROC)
library(knitr)
library(broom)
library(parameters)

here::i_am("code/03_modeling.R")

train_df <- readRDS(here::here("data", "train.rds"))
test_df <- readRDS(here::here("data", "test.rds"))

# Step 1: Fit univariate models --------------------------------
train_df[, -1] <- lapply(train_df[, -1], as.factor)

col <- colnames(train_df)[colnames(train_df) %in% "Recurred" == FALSE]
var.uni <- c()

for (i in col){
  uni.model <- glm(train_df[["Recurred"]]~train_df[[i]], family = binomial(link = "logit"))
  p <- summary(uni.model)$coefficients[-1,"Pr(>|z|)"]  
  if (any(p <= 0.05)){
    var.uni <- append(var.uni, as.character(i))
  }
}

saveRDS(
  var.uni,
  file = here::here("output", "univariate_variables.rds")
)


# Step 2: Fit multivariable model --------------------------------
model1 <- glm(Recurred ~ Age + I(Gender) + I(Smoking) + I(`Smoking History`) + I(`Radiothreapy History`) + I(Adenopathy) + I(Focality) + I(Tumor) +I(Node) + I(Stage) + I(Response), family = "binomial", data = train_df)

model1.vif <- kable(vif(model1))
print(model1.vif)

model1_tbl <- tbl_regression(model1, exponentiate = TRUE, tidy_fun = broom.helpers::tidy_parameters)
model1_tbl

saveRDS(
  model1,
  file = here::here("output", "multivariable_model.rds")
)

saveRDS(
  model1_tbl,
  file = here::here("output", "multivariable_model_tbl.rds")
)


# Step 3: Stepwise selection --------------------------------
model.step <- step(model1, direction = "backward")
summary(model.step)

model.step.vif <- kable(vif(model.step))
print(model.step.vif)

model2_tbl <- tbl_regression(model.step, exponentiate = TRUE)
model2_tbl

saveRDS(
  model.step,
  file = here::here("output", "stepwise_model.rds")
)

saveRDS(
  model1_tbl,
  file = here::here("output", "stepwise_model_tbl.rds")
)


# Step 4: Final Model --------------------------------
train_df1 <- train_df %>%
  mutate(Smoker = if_else((Smoking=="Yes")|(`Smoking History`=="Yes"), "Yes", "No")) 
test_df1 <- test_df %>%
  mutate(Smoker = if_else((Smoking=="Yes")|(`Smoking History`=="Yes"), "Yes", "No"))

saveRDS(
  train_df1,
  file = here::here("data", "train_1.rds")
)
saveRDS(
  test_df1,
  file = here::here("data", "test_1.rds")
)

model3 <- glm(formula = Recurred ~ Age + I(Gender) + I(Smoker) + I(Focality) + I(Node) + I(Response), family = "binomial", 
              data = train_df1)

model3.vif <- kable(vif(model3))
print(model3.vif)

model3_tbl <- tbl_regression(model3, exponentiate = TRUE)
model3_tbl

saveRDS(
  model3,
  file = here::here("output", "final_model.rds")
)

saveRDS(
  model3_tbl,
  file = here::here("output", "final_model_tbl.rds")
)

# Model Evaluation --------------------------------
## Prediction 
predictions <- predict(model3, newdata = test_df1, type = "response")
test_df1$predict <- as.numeric(predictions>0.3)


## Confusion Matrix 
confusion_mat <- table(test_df1$predict, test_df1$Recurred)
TP <- confusion_mat[2,2]
TN <- confusion_mat[1,1]
FP <- confusion_mat[2,1]
FN <- confusion_mat[1,2]

accuracy <- (TP+TN)/(TP+FN+FP+TN)
sensitivity <- TP/(TP+FN)
precision <- TP/(TP+FP)
specificity <- TN/(TN+FP)

evaluation_tbl <- data.frame(
  Accuracy = round(accuracy, 4),
  Precision = round(precision, 4),
  Sensitivity = round(sensitivity, 4),
  Specificity = round(specificity, 4)
)
kable(evaluation_tbl)

saveRDS(
  evaluation_tbl,
  file = here::here("output", "evaluation_tbl.rds")
)

## ROC 
png(filename = here::here("output", "roc_plots.png"),
    width = 1344, height = 960, res = 200)
roc <- roc(test_df$Recurred, predictions, plot = TRUE, print.auc = TRUE)
dev.off()



## Threshold 
pred <- prediction(predictions, test_df$Recurred)

sens <- data.frame(x=unlist(performance(pred, "sens")@x.values), 
                   y=unlist(performance(pred, "sens")@y.values))
spec <- data.frame(x=unlist(performance(pred, "spec")@x.values), 
                   y=unlist(performance(pred, "spec")@y.values))
prec <- data.frame(x=unlist(performance(pred, "prec")@x.values), 
                   y=unlist(performance(pred, "prec")@y.values))
rec <- data.frame(x=unlist(performance(pred, "rec")@x.values), 
                  y=unlist(performance(pred, "rec")@y.values))

png(filename = here::here("output", "threshold_sens_plot.png"),
    width = 1344, height = 960, res = 200)
sens %>% ggplot(aes(x,y)) + 
  geom_line() + 
  geom_line(data=spec, aes(x,y,col="red")) +
  scale_y_continuous(sec.axis = sec_axis(~., name = "Specificity")) +
  labs(x='Cutoff', y="Sensitivity") +
  theme(axis.title.y.right = element_text(colour = "red"), legend.position="none") +
  theme_classic()
dev.off()

png(filename = here::here("output", "threshold_prec_plot.png"),
    width = 1344, height = 960, res = 200)
prec %>% ggplot(aes(x,y)) + 
  geom_line() + 
  geom_line(data=rec, aes(x,y,col="red")) +
  scale_y_continuous(sec.axis = sec_axis(~., name = "Recall")) +
  labs(x='Cutoff', y="Precision") +
  theme(axis.title.y.right = element_text(colour = "red"), legend.position="none") +
  theme_classic()
dev.off()
