
## STEP 1. READING AND PROCESSING NANOSTRING NORMALIZED DATA

nanostring_normalized_data <- read.xlsx(
  "output/nanostring_normalized_data.xlsx", 
  sheet = 1
  )

pca <- nanostring_normalized_data %>%
  filter(Code.Class == "Endogenous") %>%
  `row.names<-`(.$Name) %>%
  dplyr::select(-c(1:4)) %>%
  t(.)



# STEP 2. DIVIDING GROUPS BY COLOR AND PERFORMING PCA ANALYSIS

colors <- read.xls("../trait_batch.xlsx", sheet = 1)
rownames(colors) <- colors$X
colors$colors[colors$batch1== "2"] <- "magenta"
colors$colors[colors$batch2 == "2"] <- "blue"
colors$colors[colors$batch3 == "2"] <- "green"
samplenames <- rownames(data_filter)
groupcolors <- colors[match(samplenames,rownames(colors)),] 


pca_analysis <- prcomp(pca, 
                       center = T, 
                       scale. = T)
summary(pca)



# STEP 3. CREATING PCA SCATTERPLOT

writing_pca_scatterplot <- function(){
  png("output/pca_scatter.png");
  pairs(pca_analysis$x[,1:3], 
        pch = 20,
        # col = groupcolors$colors
  )
}

output_directory_check(writing_pca_scatterplot())




# STEP 4. CHECKING PERCENTAGE OF VARIABLES EXPLAINED BY PCA DIMENSION

writing_explanation_variables_pca_graph <- function(){
  png("output/percentage_of_explained_variables_by_pca.png");
  fviz_eig(pca_analysis);
  dev.off()
}

output_directory_check(writing_explanation_variables_pca_graph())


