

## CALLING REQUIRED PACKAGES

packages <- c(
  "NanoStringNorm",
  "quantro",
  "NormqPCR",
  
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
                     quiet = T,
                     dependencies = T)

lapply(packages,
       library,
       character.only = T,
       logical.return = T)

rm(list = ls())
