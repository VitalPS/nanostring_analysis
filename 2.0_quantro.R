
## STEP 1. READ RAW DATA AND CONVERT IT TO LOG2

ncounter_raw_data <- read.xls.RCC("input/raw_data.xlsx",
                         sheet = 1)
# Loading the .xlsx raw data obtained pos processing into nSolver

# OBS.: The raw_data.xlsx MUST HAVE before gene names (line 16 - before POS_A gene)
# a line with the following:
# Column A: "Code Class"
# Column B: "Name"
# Column C: "Accession"

sample_names <- ncounter_raw_data %>%
  `[[`("x") %>%
  dplyr::select(-c(1:3)) %>%
  colnames()

quantro_data <- ncounter_raw_data %>%
  `[[`("x") %>%
  `row.names<-`(.$Name) %>%
  filter(Code.Class == "Endogenous") %>%
  select(-c(1:3)) %>%
  log2() %>%
  as.matrix()



## STEP 2. LER TRAITS E CRIAR VETOR

raw_patients_data <- read.xlsx("input/patients.xlsx")

patients_traits <- raw_patients_data %>%
  dplyr::select(resposta_ao_tratamento) %>%
  mutate(
    response = as.numeric(case_when(
      resposta_ao_tratamento %in% c(1, 2, 3, 5) ~ "2", #responder
      resposta_ao_tratamento %in% c(4) ~ "1" #non-responder
    ))
  ) %>%
  dplyr::select(-resposta_ao_tratamento) %>%
  `row.names<-`(sample_names)



writing_patients_traits_table <- function(){
  WriteXLS(
    patients_traits,
    "output/patients_traits.xlsx",
    col.names = T,
    row.names = F
  )
}

output_directory_check(writing_patients_traits_table())




# STEP 3. CREATE BOXPLOT FROM RAW DATA

writing_boxplot <-
  function() {
    #### conferir cores da legenda no boxplot
    png(filename = "output/boxplot_quantro.png",
        width = 1800,
        height = 600)
    matboxplot(quantro_data,
               groupFactor = patients_traits$response,
               ylab = "Log2 raw counts")
    dev.off()
  }

output_directory_check(writing_boxplot())




# STEP 4. CREATE DENSITY PLOT FROM RAW DATA

writing_density_plot <- 
  function() {
    png(filename = "output/matdensity_quantro.png",
        width = 800,
        height = 800)
    matdensity(
      quantro_data,
      groupFactor = patients_traits$response,
      xlab = "Log2 raw counts",
      ylab = "Density"
    )
    #legend('topright', c("", ""), col = c(1,2,3,4,5), lty = 1, lwd = 3)
    dev.off()
  }

output_directory_check(writing_density_plot())




# STEP 5. PERFORM STATISTICAL ANALYSIS

qtest <- quantro(quantro_data,
                 groupFactor = patients_traits$response)
qtest
anova(qtest)


qtestPerm <- quantro(quantro_data,
                     groupFactor = patients_traits$response, B = 1000)
qtestPerm
quantroPlot(qtestPerm)

dev.off()
