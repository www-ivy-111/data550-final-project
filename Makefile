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
.PHONY: EDA modeling clean split_data report
report: report/report.html   

split_data: output/clean_data.rds output/test.rds output/train.rds

EDA: output/table1.rds output/descriptive_bar_outcome.png output/descriptive_pie_charts.png

modeling: output/univariate_variables.rds output/multivariable_model.rds\
 output/multivariable_model_tbl.rds output/stepwise_model.rds\
 output/stepwise_model_tbl.rds output/final_model.rds output/final_model_tbl.rds\
 output/evaluation_tbl.rds output/roc_plots.png\
 output/threshold_sens_plot.png output/threshold_prec_plot.png
 
clean:
	rm -f output/* && rm -f report/*.html && rm -f data/*.rds
	