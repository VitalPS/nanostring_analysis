
## STEP 1. READ RAW DATA AND CONVERT IT TO LOG2

raw_data <- read.xls.RCC("raw_data.xlsx",
               sheet = 1)
# Loading the .xlsx raw data obtained pos processing into nSolver

# OBS.: The raw_data.xlsx MUST HAVE before gene names (line 16 - before POS_A gene)
# a line with the following:
# Column A: "Code Class"
# Column B: "Name"
# Column C: "Accession"


quantro_data <- raw_data %>%
  `[[`("x") %>% # Extracting gene count from 'rawdata' list as a dataframe named 'data'
  `row.names<-`(.$Name) %>% # Naming each record (observation)
  filter(Code.Class == "Endogenous") %>% # Excluding non-endogenous genes from the dataset
  select(-c(1:3)) %>% # excluding extra info from the dataset
  log2() %>% # converting expression values into log2
  as.matrix() # converting data frame to matrix 



## STEP 2. LER TRAITS E CRIAR VETOR

traits <- read.xlsx("../raw_data/PerfilDosPacientes.xlsx")

traits_final <- traits %>% 
  select(resposta_ao_tratamento) %>%
  mutate(
    response = case_when(
      resposta_ao_tratamento %in% c(1, 2, 3, 5) ~ "responder",
      resposta_ao_tratamento %in% c(4) ~ "non_responder")) %>%
  select(- resposta_ao_tratamento) %>%
  `row.names<-`(traits$record_id)


# boxplot
png(filename = "boxplot_quantro.png",
    width = 1800,
    height = 600)
matboxplot(quantro_data,
           groupFactor = designs$group,
           ylab = "Log2 raw counts")
dev.off()


#### conferir cores da legenda no boxplot
# plot da densidade
png(filename = "matdensity_quantro.png",
    width = 800,
    height = 800)
matdensity(
  quantro_data,
  groupFactor = designs$group,
  xlab = "Log2 raw counts",
  ylab = "Density"
)
#legend('topright', c("", ""), col = c(1,2,3,4,5), lty = 1, lwd = 3)
dev.off()



###
qtest <- quantro(quantro_data,
                 groupFactor = traits_final$response)
qtest
anova(qtest)


qtestPerm <- quantro(quantro_data,
                     groupFactor = traits_final$response, B = 1000)
qtestPerm


quantroPlot(qtestPerm)
dev.off()
