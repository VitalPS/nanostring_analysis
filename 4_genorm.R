
### PERFORMING GENORM ANALYSIS


## STEP 1. EXTRACTING AND PROCESSING RAW DATA

## Ler arquivo xlsx
raw_data <- read.xls.RCC("input/raw_data.xlsx",
                         sheet = 1)

# Extracting gene count from 'rawdata' list as a dataframe named 'data'
data <- raw_data %>%
  `[[`("x") %>%
  `row.names<-`(.$Name)

controls_data <- data %>%
  filter(Code.Class %in% c("Positive", "Negative")) %>%
  dplyr::select(-c(1:3))

endogenous_data <- data %>%
  filter(Code.Class %in% c("Endogenous")) %>%
  dplyr::select(-c(1:3))

housekeeping_data <- data %>%
  filter(Code.Class %in% c("Housekeeping")) %>%
  dplyr::select(-c(1:3))



## STEP 2. IMPLEMENTING GENORM

genorm_data <- selectHKs(
  as.matrix(t(housekeeping_data)),
  method = "geNorm",
  Symbols = row.names(housekeeping_data),
  minNrHK = 2,
  log = FALSE
)

genorm_ranking <- as.data.frame(genorm_data$ranking) %>%
  rename(ranking = `genorm_data$ranking`) %>%
  mutate(row_id = row_number())

genorm_meanM <- as.data.frame(genorm_data$meanM) %>%
  rename(meanM = `genorm_data$meanM`) %>%
  mutate(row_id = row_number())

genorm_variation <- as.data.frame(genorm_data$variation) %>%
  rename(variation = `genorm_data$variation`) %>%
  mutate(row_id = row_number())




## STEP 3. GETTING MINIMAL VARIATION

position_min_variation <- genorm_variation %>%
  mutate(row_id = row_number()) %>%
  filter(variation == min(variation)) %>%
  pull(row_id)


genorm_variation <- genorm_variation %>%
  mutate(selection = case_when(row_id >= position_min_variation ~ "selected",
                               .default =  "unselected",)) %>%
  mutate(pairing = factor(row.names(.),
                          levels = unique(rownames(genorm_variation))))


writing_dotplot_variation <- function() {
  png("output/dot_chart_genorm.png", 
      height = 300, 
      width = 400)
  
  ggplot(genorm_variation,
         aes(pairing,
             variation)) +
    geom_point(aes(color = selection),
               position = position_dodge(0.3),
               size = 3) +
    # scale_x_discrete(name = "",
    #                  breaks=c(first,min,last)) +
    labs(color = "") +
    xlab("Names") +
    ylab("Pairwise variation") +
    scale_color_manual(values = c("unselected" = "red",
                                  "selected" = "blue")) +
    theme_pubclean()
  
  dev.off()
}

if (file.exists("output")) {
  writing_dotplot_variation()
  
} else {
  dir.create("output")
  writing_dotplot_variation()
}


## STEP 4. GENERATING TABLES WITH HOUSEKEEPING GENES

# Selected and unselected genes
all_housekeeping_genes <- genorm_ranking %>%
  mutate(
    selection = case_when(row_id %in% genorm_variation$row_id ~ "selected",
                          .default = "unselected",)
  ) %>%
  dplyr::select(-row_id)


writing_hk_table <- function() {
  WriteXLS(
    all_housekeeping_genes,
    "output/all_housekeepings.xlsx",
    col.names = T,
    row.names = F
  )
}

if (file.exists("output")) {
  writing_hk_table()
  
} else {
  dir.create("output")
  writing_hk_table()
}



# Unselected genes
unselected_housekeeping_genes <- all_housekeeping_genes %>%
  filter(selection == "unselected")


writing_unselected_hk_table <- function() {
  WriteXLS(
    unselected_housekeeping_genes,
    "output/unselected_housekeepings.xlsx",
    col.names = T,
    row.names = F
  )
}

if (file.exists("output")) {
  writing_unselected_hk_table()
  
} else {
  dir.create("output")
  writing_unselected_hk_table()
}
