
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

packages_setup <- function() {
  if (sum(as.numeric(!packages %in% installed.packages())) != 0) {
    vector_unistalled_packages <- packages[packages %in% installed.packages()]
    for (i in 1:length(vector_unistalled_packages )) {
      BiocManager::install(vector_unistalled_packages , dependencies = T)
      break()
    }
    sapply(packages, require, character = T)
  } else {
    sapply(packages, require, character = T)
  }
}

if (!require("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
  packages_setup()
  rm(list = ls())
} else{
  packages_setup()
  rm(list = ls())
}


## SUPPORT FUNCTIONS

# Create a output directory if it doesn't exist

output_directory_check <-
  function(create_output_function) {
    if (file.exists("output")) {
      create_output_function
      
    } else {
      dir.create("output")
      create_output_function
    }
  }
