

## CALLING REQUIRED PACKAGES

packages <- c(
  "NanoStringNorm",
  "quantro",
  "NormqPCR",
  "factoextra",
  
  "tidyverse",
  "ggpubr",
  "WriteXLS",
  "openxlsx",
  
  "fastDummies",
  "doParallel",
  
  "NACHO"
)

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install(packages,
                     # quiet = T,
                     dependencies = T)

lapply(packages,
       library,
       character.only = T,
       logical.return = T)

rm(list = ls())



## IMPORTANT FUNCTIONS

# Create a output directory if it doesn't exist

output_directory_check <-
  function(x) {
    if (file.exists("output")) {
      x
      
    } else {
      dir.create("output")
      x
    }
  }
