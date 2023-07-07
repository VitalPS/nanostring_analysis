
## CALLING REQUIRED PACKAGES

packages <- c("NanoStringNorm",
              "quantro",
              "openxlsx",
              "doParallel",
              "dplyr"
)

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install(
  packages,
  dependencies = T
)

lapply(
  packages,
  library,
  character.only = T,
  logical.return = T
)

rm(list = ls())