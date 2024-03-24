here::i_am(
  "code/04_render_report.R"
)

rmarkdown::render(
  here::here("report", "report.Rmd")
)