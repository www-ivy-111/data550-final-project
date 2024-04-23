# Check for renv and restore environment before any task
install:
	@echo "Checking for renv installation"
	@Rscript -e "if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv')"
	@echo "Restoring R package environment"
	@Rscript -e "renv::restore()"

# Split data into training and test datasets
output/clean_data.rds output/test.rds output/train.rds: code/01_split_data.R data/Thyroid_Diff.csv
	Rscript code/01_split_data.R

# Perform exploratory data analysis (EDA)
output/table1.rds output/descriptive_bar_outcome.png output/descriptive_pie_charts.png: code/02_EDA.R output/clean_data.rds
	Rscript code/02_EDA.R

# Perform Modeling
output/test_1.rds output/train_1.rds output/univariate_variables.rds output/multivariable_model.rds output/multivariable_model_tbl.rds output/stepwise_model.rds output/stepwise_model_tbl.rds output/final_model.rds output/final_model_tbl.rds output/evaluation_tbl.rds output/roc_plots.png output/threshold_sens_plot.png output/threshold_prec_plot.png:\
 code/03_modeling.R output/test.rds output/train.rds
	Rscript code/03_modeling.R 

# Generate the final report
report/report.html: split_data EDA modeling
	Rscript code/04_render_report.R

# Phony targets for workflow steps
.PHONY: EDA modeling clean split_data report mount-report

report:    
	Rscript code/01_split_data.R
	Rscript code/02_EDA.R
	Rscript code/03_modeling.R 
	Rscript code/04_render_report.R

split_data: output/clean_data.rds output/test.rds output/train.rds

EDA: output/table1.rds output/descriptive_bar_outcome.png output/descriptive_pie_charts.png

modeling: output/univariate_variables.rds output/multivariable_model.rds\
 output/multivariable_model_tbl.rds output/stepwise_model.rds\
 output/stepwise_model_tbl.rds output/final_model.rds output/final_model_tbl.rds\
 output/evaluation_tbl.rds output/roc_plots.png\
 output/threshold_sens_plot.png output/threshold_prec_plot.png
 
clean:
	rm -f output/* && rm -f report/*.html && rm -f data/*.rds

# ------------------------------------------------------------------------------
# DOCKER-ASSOCITATED RULES

PROJECTFILES = report/report.Rmd code/01_split_data.R code/02_EDA.R code/03_modeling.R code/04_render_report.R Makefile
RENVFILES = renv.lock renv/activate.R renv/settings.json

# Rule to build image 
build_image: Dockerfile $(PROJECTFILES) $(RENVFILES)
	docker build -t wwwivy111/data550_final_project .
	touch $@

# Rule to run container 
## Detect OS
OS := $(shell uname -s)
## Set volume mount path prefix based on OS
ifeq ($(OS),Windows_NT)
	VOLUME_PREFIX := "/"
else
	VOLUME_PREFIX := ""
endif
## Mount Rule
mount-report: 
	docker run -v "$(OS_PATH_PREFIX)$(PWD)/report":/project/report wwwivy111/data550_final_project



