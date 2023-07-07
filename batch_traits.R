x <- raw_data$x
y <- raw_data$header


install.packages("fastDummies")
library(fastDummies)


batch_traits <- y %>%
  t(.) %>%
  as.data.frame() %>%
  select("file.name", "sample.id") %>%
  rename(c("cartridge" = "file.name", "amostra" = "sample.id")) %>%
  `row.names<-`(NULL) %>%
  stringr::str_extract(amostra, "[a-z]{1,2}")