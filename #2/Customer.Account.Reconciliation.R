#reading source data ----

# reading customer data 
core_data_cust = readxl::read_excel(path = here::here("./data/prepd/prepd_core-customers.xlsx"))

#reading account data
core_data_acct = readxl::read_excel(path = here::here("./data/prepd/prepd_core-accounts.xlsx"))
core_data_acct = core_data_acct %>% filter(!is.na(id_contract))
#reading model data 
model_data = readxl::read_excel(path = here::here("./data/prepd/prepd_ecs-model-accounts.xlsx"))

model_data = model_data %>% dplyr::filter(profile_status != "Closed" & profile_status != "Pending Closure")

# reconciliation part-----

# customer id's that are not in model 
core_data_cust$.cid_in_model = core_data_cust$client %in% model_data$customer_code
discrepancies_cust = core_data_cust %>% dplyr::filter(!.cid_in_model)

# account id's that are not in model 
core_data_acct$.aid_in_model = core_data_acct$id_contract %in% model_data$account_number
discrepancies_acct = core_data_acct %>% dplyr::filter(!.aid_in_model)
discrepancies_acct = discrepancies_acct %>% dplyr::filter(!str_detect(id_contract,pattern = "^[A-z]"))

# testing for duplicates

dups_cust = core_data_cust %>% select(client,name,complete_name) %>% unique() %>% count(name,complete_name,sort = TRUE) %>% dplyr::filter(n>1)

dups_acct = core_data_acct %>% select(customer_id,customer_name) %>% unique() %>% count(customer_name,sort = TRUE) %>% dplyr::filter(n>1)

# write to excel file ----

writexl::write_xlsx(
  x = discrepancies_acct,
  path = here::here(
    "./analysis/recon-cust-accnt/output/discrepancies_acct.xlsx")
)

writexl::write_xlsx(
  x = discrepancies_cust,
  path = here::here("./analysis/recon-cust-accnt/output/discrepancies_cust.xlsx")
)

