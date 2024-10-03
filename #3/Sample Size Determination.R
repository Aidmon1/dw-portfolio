#reading core wire data------

core_data = readxl::read_excel(path = here::here("./data/raw/30 - 175 Wires.xlsx"),
                               skip = 2L)

# had to subset to get rid of blank column 10-----
core_data = subset(core_data,select = -c(10))


# sampling wire data code international and domestic----- 

sample_core_wire_data1 = core_data %>% 
  dplyr::filter(`eWire Txn Transfer Type Code` == 'INTLD') %>%
  dplyr::sample_n(size = 15, replace = FALSE)

sample_core_wire_data2 = core_data %>% 
  dplyr::filter(`eWire Txn Transfer Type Code` == 'DOMC') %>%
  dplyr::sample_n(size = 15, replace = FALSE)

#combining the wire samples
sample_wire_data = dplyr::bind_rows(sample_core_wire_data1,sample_core_wire_data2
                                    )

#writing excel sheet
writexl::write_xlsx(x = sample_wire_data,
                    path = here::here("./data/prepd/sample of wire data.xlsx"))
