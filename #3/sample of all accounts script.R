#reading core data all accounts
core_data = readxl::read_excel(path = here::here("./data/raw/25 - All Accounts.xlsx"),
                              skip = 2L )

sample_all_core_accounts_data = core_data %>% dplyr::sample_n(size = 25,
                                                            replace = FALSE)

# writing excel file

writexl::write_xlsx(x = sample_all_core_accounts_data,
                    path = here::here("./data/prepd/sample of All Accounts.xlsx"))