FROM rocker/r-ubuntu as base

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y pandoc

# Build directory
RUN mkdir /project
WORKDIR /project

RUN mkdir data code report output renv


# COPY necessary files  
COPY data data
COPY code code
COPY report report
COPY Makefile .
COPY .Rprofile .
COPY renv.lock .
COPY renv/activate.R renv
COPY renv/settings.json renv

RUN R -e "renv::restore(prompt = FALSE)"

# Generate the report in the image
CMD make report
