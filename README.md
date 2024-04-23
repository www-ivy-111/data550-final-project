# Final Project 8    
  
  
##  Project Environment Setting Up  
1. Clone the Repository from the github to your local machine  
2. Navigate to the project directory in terminal  

   
## Report Generation     
There are two ways to generate the report: locally on your computer or using a Docker image.   

- Locally:  
1. Make sure you have `make` and `R` installed on your system  
2. Make sure you have `renv` R package is installed  
3. Open a terminal in the project directory  
4. Run command `make install` to restore the R package environment using `renv`  
5. Run `make report` to compile the final report   

- Using Docker:  
1. Pull the image from [DockerHub Repository](https://hub.docker.com/r/wwwivy111/data550_final_project/)   
2. Run command `make mount-report` in the terminal to generate the report  
(This step works for both Windows-OS and a Mac/Linux-OS)  
3. The compiled report should be in your local `\report` folder  
4. (Optional) If you prefer to build the image yourself instead of downloading it from DockerHub, use the command `make build_image`. An image called "wwwivy111/data550_final_project" will be built.        
   
## Repository stucture
The raw dataset `Thyroid_Diff.csv` was saved in the `data/` folder.  
Codes were saved in the `code/` folder.  
The final report was saved in the `report/` folder.   
  
- README.md
- Makefile
- Dockerfile
- renv.lock
- renv/
- data/
- code/
- output/
- report/
  
   
## Report contents
Key sections include:  
1. Introduction: Introduce the study  
2. Method and Analysis: Describes the methods and results for data preparation, exploratory data analysis, and modeling process and model evaluation  
3. Discussion: Discusses the implications for clinical management and future research
  
  
  
## Code description 

`code/01_split_data.R`  
  
  - cleans the data format  
  - splits the data into train and test set  
  - saves new datasets as different `.rds` objects in `data/` folder  
    (`clean_data.rds`, `train.rds`, `test.rds`)  
  
  
`code/02_EDA.R`  
  
  - conducts Exploratory Data Analysis (EDA)  
  - generates table1 and saves as `table1.rds` object in `output/` folder  
  - generates descriptive plots for outcome, continuous, and categorical variables and saves as `.png` objects in `output/` folder  
    (`descriptive_age_plots.png`, `descriptive_bar_outcome.png`, `descriptive_pie_charts.png`)  
  
  
`code/03_modeling.R`  
  
  - generate new train and test data `train_1.rds` and `test_1.rds` in `data/` folder    
  - fits univariate models and multivariable model, stepwise selection model, and final model  
  - saves models and corresponding tables as different `.rds` objects in `output/` folder  
  - conducts model evaluation for the final model   
  - saves evaluation matrix and ROC plot as `.rds` and `.png` objects in `output/` folder
  
  
`code/04_render_report.R`  
  
  - renders `report.Rmd`  
  
  
`report.Rmd`  

  - reads outputs from `code/01_split_data.R`, `code/02_EDA.R`, `code/03_modeling.R`  
  - makes the final report
  
  
`Makefile`

  - contains rules for building the final report and other targets  
  - `make report` will compile the report into `.html` object
  - `make split_data` will generate the outputs of `code/01_split_data.R`  
  - `make EDA` will generate the outputs of `code/02_EDA.R`  
  - `make modeling` will generate the outputs of `code/03_modeling.R`  
  - `make clean` will clean all outputs  
  
  
  
  
