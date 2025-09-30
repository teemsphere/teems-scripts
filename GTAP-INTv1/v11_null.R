library(teems)

data <- ems_data(dat_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har",
                 par_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har",
                 set_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
                 REG = "big3",
                 TRAD_COMM = "macro_sector",
                 ENDW_COMM = "labor_agg",
                 time_steps = c(0, 1, 2, 3, 4, 6, 8, 10, 12, 14, 16),
                 convert_format = TRUE)

model <- ems_model(
  tab_file = "GTAP-INTv1",
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
                     n_tasks = 1,
                     n_subintervals = 1,
                     matrix_method = "LU",
                     solution_method = "Johansen")

ems_solve(cmf_path = cmf_path,
          n_tasks = 2,
          n_subintervals = 2,
          steps = c(2, 4, 8),
          matrix_method = "SBBD",
          solution_method = "mod_midpoint",
          suppress_outputs = TRUE)

ems_solve(cmf_path = cmf_path,
          n_tasks = 2,
          n_subintervals = 2,
          matrix_method = "NDBBD",
          n_timesteps = 11,
          solution_method = "mod_midpoint",
          suppress_outputs = TRUE)


