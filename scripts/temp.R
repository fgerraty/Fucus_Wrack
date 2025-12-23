
wrack_scaled <- wrack_predictors %>%
  dplyr::select(-wave_exposure, -percent_boulder, -percent_cobble, -percent_pebble, -percent_granule, -percent_sand) %>% 
  mutate(across(
    .cols = 5:14,          # columns beach_width through high_tide
    .fns  = ~ if(is.numeric(.x)) as.numeric(scale(.x)) else .x))


predictors <- names(wrack_scaled)[5:14]
predictors

# all subsets except empty model
all_models <- map(1:length(predictors), ~ combn(predictors, ., simplify = FALSE)) %>% 
  unlist(recursive = FALSE)


is_collinear <- function(vars, df, threshold = 0.7) {
  cor_mat <- cor(df[, vars], use = "pairwise.complete.obs")
  is_col <- any(abs(cor_mat[upper.tri(cor_mat)]) > threshold)
  return(is_col)
}


non_collinear_sets <- keep(all_models, ~ !is_collinear(.x, wrack_scaled))
length(non_collinear_sets)


library(purrr)
library(glmmTMB)

# Define a safe model fitting function
fit_model <- function(vars) {
  # Construct the formula: additive predictors + random effect
  fmla <- as.formula(
    paste("wrack_biomass ~", paste(vars, collapse = " + "), "+ (1|site)")
  )
  # Fit the model safely
  possibly(glmmTMB, otherwise = NULL)(fmla, data = wrack_scaled, family = Gamma(link = "log"))
}

# Map over all non-collinear predictor sets
fitted_models <- map(non_collinear_sets, fit_model)

# Remove NULLs (failed models)
fitted_models2 <- compact(fitted_models)


model_selection <- model.sel(fitted_models)
model_selection




model_sel_df <- as.data.frame(model_selection)

write_csv(model_sel_df, "temp/model_selection2.csv")


