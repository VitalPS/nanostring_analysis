
## STEP 1. READING AND CLEANING NANOSTRING AND PATIENTS DATA

ncounter_raw_data <- read.xls.RCC("input/raw_data.xlsx",
                                  sheet = 1)

sample_names <- ncounter_raw_data %>%
  `[[`("x") %>%
  dplyr::select(-c(1:3)) %>%
  colnames()


raw_patients_data <- read.xlsx("input/patients.xlsx")

patients_traits <- raw_patients_data %>%
  dplyr::select(resposta_ao_tratamento) %>%
  mutate(response = as.numeric(
    case_when(
      resposta_ao_tratamento %in% c(1, 2, 3, 5) ~ "2", #responder
      resposta_ao_tratamento %in% c(4) ~ "1" #non-responder
    )
  )) %>%
  dplyr::select(-resposta_ao_tratamento) %>%
  `row.names<-`(sample_names)



## STEP 2. NORMALIZING GENE EXPRESSION DATA

nanostringnorm_data <- NanoStringNorm(
  x = ncounter_raw_data$x,
  CodeCount = "none",
  Background = "none",
  SampleContent = "housekeeping.geo.mean",
  OtherNorm = "none",
  round.values = F,
  take.log = T,
  traits = patients_traits
)


# Extracting normalized gene expression
write_normalized_data_table <- function() {
  nanostring_normalized <- nanostringnorm_data$normalized.data
  
  WriteXLS(
    nanostring_normalized,
    "output/nanostring_normalized_data.xlsx",
    col.names = T,
    row.names = T
  )
}

output_directory_check(write_normalized_data_table())


# Extracting normalized expression statistics summary
write_statistics_summary_table <- function() {
  statistics <- nanostringnorm_data$gene.summary.stats.norm
  
  WriteXLS(
    statistics,
    "output/nanostring_normalized_statistics.xlsx",
    col.names = T,
    row.names = T
  )
}

output_directory_check(write_statistics_summary_table())



# STEP 3. CREATING A PDF FILE WITH BOXPLOT OF ENDOGENOURS GENES BEFORE AND AFTER NORMALIZATION

endogenous_normalized <- nanostringnorm_data %>%
  `[[`("normalized.data") %>%
  filter(Code.Class == "Endogenous") %>%
  dplyr::select(-c(1:3))

endogenous_non_normalized <- ncounter_raw_data %>%
  `[[`("x") %>%
  filter(Code.Class == "Endogenous") %>%
  `row.names<-`(.$Name) %>%
  dplyr::select(-c(1:3)) %>%
  log2()


writing_boxplot_endogenous_normalized_and_nonnormalized_data <-
  function() {
    pdf("output/boxplot_endogenous_genes_after_before_normalization",
        width = 14)
    
    boxplot(
      endogenous_normalized,
      col = "blue",
      las = 2,
      main = "Endogenous after normalization"
    )
    
    boxplot(
      endogenous_non_normalized,
      col = "blue",
      las = 2,
      main = "Endogenous before normalization"
    )
    
    dev.off()
  }

output_directory_check(writing_boxplot_endogenous_normalized_and_nonnormalized_data())



# STEP 4. CREATING A PDF FILE WITH BOXPLOT OF HOUSEKEEPING GENES BEFORE AND AFTER NORMALIZATION

housekeeping_normalized <- nanostringnorm_data %>%
  `[[`("normalized.data") %>%
  filter(Code.Class == "Housekeeping") %>%
  dplyr::select(-c(1:3))

housekeeping_non_normalized <- ncounter_raw_data %>%
  `[[`("x") %>%
  filter(Code.Class == "Housekeeping") %>%
  `row.names<-`(.$Name) %>%
  dplyr::select(-c(1:3)) %>%
  log2()


writing_boxplot_housekeeping_normalized_and_nonnormalized_data <-
  function() {
    pdf("output/boxplot_housekeeping_genes_after_before_normalization",
        width = 14)
    
    boxplot(
      housekeeping_normalized,
      col = "red",
      las = 2,
      main = "Endogenous after normalization"
    )
    
    boxplot(
      housekeeping_non_normalized,
      col = "red",
      las = 2,
      main = "Endogenous before normalization"
    )
    
    dev.off()
  }

output_directory_check(writing_boxplot_housekeeping_normalized_and_nonnormalized_data())



## STEP 5. CREATING A PDF FILE WITH GRAPHS SUMMARIZING THE QUALITY CONTROL PARAMETERS

writing_quality_control_nanostringnorm_graphs <- function() {
  pdf("output/quality_control_nanostringnorm_summary_.pdf")
  
  
  Plot.NanoStringNorm(x = nanostringnorm_data,
                      label.best.guess = T,
                      plot.type = 'all')
  
  
  dev.off()
}

output_directory_check(writing_quality_control_nanostringnorm_graphs())
