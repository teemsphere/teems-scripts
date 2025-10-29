library(teems)

data <- ems_data(
  dat_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har",
  par_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har",
  set_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
  REG = "big3",
  COMM = "macro_sector",
  ACTS = "macro_sector",
  ENDW = "labor_agg",
  time_steps = c(0, 1, 2, 3, 4, 6, 8, 10, 12, 14, 16)
)

model <- ems_model(
  tab_file = "GTAP-REv1",
  var_omit = c(
    "atall",
    "avaall",
    "tfe",
    "tfd",
    "tfm",
    "tgd",
    "tgm",
    "tid",
    "tim"
  )
)

pop <- ems_data(
  dat_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har",
  par_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har",
  set_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
  REG = "full",
  COMM = "macro_sector",
  ACTS = "macro_sector",
  ENDW = "labor_agg"
)$POP

pop$Year <- 2017
regions <- unique(pop$REG)
pop_traj <- expand.grid(
  REG = regions,
  Value = 0,
  Year = c(2018, 2019, 2020, 2021, 2023, 2025, 2027, 2029, 2031, 2033),
  stringsAsFactors = FALSE
)
pop <- rbind(pop, pop_traj)

growth_rates <- data.frame(
  REG = regions,
  growth_rate = runif(length(regions), min = -0.01, max = 0.05)
)

pop <- merge(pop, growth_rates, by = "REG")
base_values <- pop[pop$Year == 2017, c("REG", "Value")]
names(base_values)[2] <- "base_value"
pop <- merge(pop, base_values, by = "REG")

pop$Value[pop$Year > 2017] <-
  pop$base_value[pop$Year > 2017] *
    (1 + pop$growth_rate[pop$Year > 2017])^(pop$Year[pop$Year > 2017] - 2017)
pop$growth_rate <- NULL
pop$base_value <- NULL
pop <- pop[order(pop$REG, pop$Year), ]
pop <- pop[, c("REG", "Year", "Value")]
colnames(pop)[1] <- "REGr"

pop_trajectory <- ems_shock(
  var = "pop",
  type = "scenario",
  input = pop
)

cmf_path <- ems_deploy(
  data = data,
  model = model,
  shock = pop_trajectory
)

outputs <- ems_solve(
  cmf_path = cmf_path,
  n_tasks = 1,
  n_subintervals = 1,
  matrix_method = "SBBD",
  solution_method = "mod_midpoint"
)

pop$REGr <- ifelse(pop$REGr == "chn",
  "chn",
  ifelse(pop$REGr == "usa",
    "usa",
    "row"
  )
)

pop <- aggregate(Value ~ REGr + Year, data = pop, FUN = sum)

check <- merge(pop,
  outputs$dat$pop[, !"ALLTIMEt"],
  by = colnames(pop)[-ncol(pop)]
)

check$check <- ave(check$Value.x, check$REGr, FUN = function(x) {
  base <- x[1]
  ((x - base) / base) * 100
})

all.equal(check$Value.y,
  check$check,
  tolerance = 1e-6
)
