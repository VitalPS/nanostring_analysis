# BUIDING TABLE WITH BATCH TRAITS

ncounter_raw_data <- read.xls.RCC("input/raw_data.xlsx",
                         sheet = 1)


sample_names <- ncounter_raw_data %>%
  `[[`("x") %>%
  dplyr::select(-c(1:3)) %>%
  colnames()


batch_traits <- ncounter_raw_data %>%
  `[[`("header") %>%
  t(.) %>%
  as.data.frame() %>%
  dplyr::select("file.name") %>%
  rename(c("cartridge" = "file.name")) %>%
  mutate(cartridge = stringr::str_extract(.$cartridge, "C\\d{1,}")) %>% # change this line of code depending on the cartridge name
  dummy_cols(
    select_columns = c("cartridge"),
    remove_first_dummy = F,
    remove_selected_columns = T
  ) %>%
  `rownames<-`(sample_names) %>%
  mutate_all( ~ recode(.,
                       "0" = 1,
                       "1" = 2))
  



# Creating XLSX file

writing_batch_traits_table <- function(){
  WriteXLS(
    batch_traits,
    "output/batch_traits.xlsx",
    col.names = T,
    row.names = T
  )
}

output_directory_check(writing_batch_traits_table())

