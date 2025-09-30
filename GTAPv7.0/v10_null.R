library(teems)

data <- ems_data(dat_input = "~/dat/GTAP/v10A/flexagg10AY14/gsddat.har",
                 par_input = "~/dat/GTAP/v10A/flexagg10AY14/gsdpar.har",
                 set_input = "~/dat/GTAP/v10A/flexagg10AY14/gsdset.har",
                 REG = "big3",
                 COMM = "macro_sector",
                 ACTS = "macro_sector",
                 ENDW = "labor_agg",
                 convert_format = TRUE)

model <- ems_model(
  tab_file = "GTAPv7.0",
  var_omit = c("atall",
               "avaall",
               "tfe",
               "tfd",
               "tfm",
               "tgd",
               "tgm",
               "tpdall",
               "tpmall",
               "tid",
               "tim")
)
# reverse ETRE approach
cmf_path <- ems_deploy(data = data,
                       model = model)

outputs <- ems_solve(cmf_path = cmf_path,
                     n_tasks = 1,
                     n_subintervals = 1,
                     matrix_method = "LU",
                     solution_method = "Johansen")
