report/report.html: split_data EDA modeling
	Rscript code/04_render_report.R

output/clean_data.rds output/test.rds output/train.rds: code/01_split_data.R data/Thyroid_Diff.csv
	Rscript code/01_split_data.R

output/table1.rds output/descriptive_bar_outcome.png output/descriptive_pie_charts.png: code/02_EDA.R output/clean_data.rds
	Rscript code/02_EDA.R

output/test_1.rds output/train_1.rds: code/03_modeling.R output/test.rds output/train.rds
	Rscript code/03_modeling.R

output/univariate_variables.rds output/multivariable_model.rds output/multivariable_model_tbl.rds output/stepwise_model.rds output/stepwise_model_tbl.rds output/final_model.rds output/final_model_tbl.rds output/evaluation_tbl.rds output/roc_plots.png output/threshold_sens_plot.png output/threshold_prec_plot.png:\
 code/03_modeling.R output/test.rds output/train.rds
	Rscript code/03_modeling.R 

.PHONY: report
report: report/report.html   

.PHONY: split_data
split_data: output/clean_data.rds output/test.rds output/train.rds

.PHONY: EDA
EDA: output/table1.rds output/descriptive_bar_outcome.png output/descriptive_pie_charts.png

.PHONY: modeling
modeling: output/univariate_variables.rds output/multivariable_model.rds\
 output/multivariable_model_tbl.rds output/stepwise_model.rds\
 output/stepwise_model_tbl.rds output/final_model.rds output/final_model_tbl.rds\
 output/evaluation_tbl.rds output/roc_plots.png\
 output/threshold_sens_plot.png output/threshold_prec_plot.png
 
.PHONY: clean
clean:
	rm -f output/* && rm -f report/*.html && rm -f data/*.rds
	