library(teems)

data <- ems_data(dat_input = "~/dat/GTAP/v10A/flexagg10AY14/gsddat.har",
                 par_input = "~/dat/GTAP/v10A/flexagg10AY14/gsdpar.har",
                 set_input = "~/dat/GTAP/v10A/flexagg10AY14/gsdset.har",
                 REG = "big3",
                 TRAD_COMM = "macro_sector",
                 ENDW_COMM = "labor_agg")

model <- ems_model(
  tab_file = "GTAPv6.2",
  var_omit = c(
    "atall",
    "tfd",
    "avaall",
    "tf",
    "tfm",
    "tgd",
    "tgm",
    "tpd",
    "tpm"
  )
)

cmf_path <- ems_deploy(data = data,
                       model = model)

outputs <- ems_solve(cmf_path = cmf_path,
                     n_tasks = 2,
                     n_subintervals = 2,
                     steps = c(2, 4, 8),
                     matrix_method = "DBBD",
                     solution_method = "mod_midpoint")
