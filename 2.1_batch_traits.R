# BUIDING TABLE WITH BATCH TRAITS

raw_data <- read.xls.RCC("input/raw_data.xlsx",
                         sheet = 1)

y <- raw_data$header

batch_traits <- y %>%
  t(.) %>%
  as.data.frame() %>%
  select("file.name", "sample.id") %>%
  rename(c("cartridge" = "file.name", "ID" = "sample.id")) %>%
  mutate(cartridge = stringr::str_extract(.$cartridge, "C\\d{1,}")) %>% # change this line of code depending on the cartridge name
  dummy_cols(
    select_columns = c("cartridge"),
    remove_first_dummy = F,
    remove_selected_columns = T
  ) %>%
  mutate_at(vars(-("ID")),
            ~ recode(.,
                     "0" = 1,
                     "1" = 2))



# Creating XLSX file

writing_xlsx <- function() {
  WriteXLS(
    batch_traits,
    "output/batch_traits.xlsx",
    col.names = T,
    row.names = F
  )
}


if (file.exists("output")) {
  writing_xlsx()
  
} else {
  dir.create("output")
  writing_xlsx()
}
