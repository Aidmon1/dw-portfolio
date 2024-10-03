# reading core data from T24 -----

core_data_paths = dir(
  path = here::here("./data/raw/RL 23 - Core Transaction Data/"),
  pattern = "\\.xlsx$",
  full.names = TRUE,
  recursive = FALSE
)
core_data = lapply(
  core_data_paths,
  FUN = function(.path) {
    readxl::read_excel(path = .path,
                       sheet = 1L,
                       col_types = "text") %>% janitor::clean_names()
  }
) 
core_data_fnames = base::basename(core_data_paths)
core_data = bind_rows(core_data, .id = ".source_file")

# reading model data from ECS -----

model_data = readxl::read_excel(path = here::here("./data/raw/ECS Trans Full Pop.xlsx"),
                                col_types = "text") %>% janitor::clean_names()


# core preprocessing ----

# core data corrections

core_data = core_data %>%
  mutate(amount_lcy = as.numeric(amount_lcy),
         amount_fcy = as.numeric(amount_fcy),
         value_date = value_date %>% 
           as.numeric() %>% lubridate::as_date(.,origin = "1899-12-30"),
         exposure_date = exposure_date %>%
           as.numeric() %>% lubridate::as_date(.,origin = "1899-12-30"),
         date_time = date_time %>% 
           as.numeric() %>% lubridate::as_date(.,origin = "1899-12-30")
)
  
# model data corrections 

model_data = model_data %>%
  mutate(
    original_amount = as.numeric( original_amount),
    debit = as.numeric(debit),
    credit = as.numeric(credit),
    local_trans_code = str_remove(string = local_trans_code, pattern = "[A-z]"),
    transaction_date= transaction_date %>%
      as.numeric() %>% lubridate::as_date(.,origin = "1899-12-30"),
    effective_date = effective_date %>%
      as.numeric() %>% lubridate::as_date(.,origin = "1899-12-30"),
    ) %>% mutate(.amount = abs(original_amount))%>% mutate(.recon = T)

# reconciliation ----

recon = left_join(
  x = core_data,
  y = model_data %>%
    select(transaction_date,account_number,.amount,local_trans_code,.recon),
  by = c(
    "exposure_date" = "transaction_date",
    #"amount_lcy" = ".amount",
    "transaction_code" = "local_trans_code",
    "account_number" = "account_number"
  ),
  relationship = "many-to-many"
) %>%
  mutate(.recon = ifelse(is.na(.recon), FALSE, TRUE))

# discrepancies

discrepancies = recon %>%
  dplyr::filter(!grepl("[A-z]",account_number) & !.recon )

#writing to excel

writexl::write_xlsx(
  x = discrepancies,
  path = here::here("./analysis/recon-txn/output/tm-tran-discrepancies.xlsx")
)
  