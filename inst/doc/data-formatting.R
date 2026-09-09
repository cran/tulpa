## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  fig.width = 6, fig.height = 4
)
set.seed(20260529)

## ----cran-gate, include = FALSE-----------------------------------------------
# The model fits below are evaluated when the article is built locally, in CI
# and for the pkgdown site (all of which set NOT_CRAN). CRAN's check farm gives
# the whole check a ten-minute budget, which these fits do not fit inside, so
# there the code is shown without being run.
EVAL_FITS <- identical(Sys.getenv("NOT_CRAN"), "true")
knitr::opts_chunk$set(eval = EVAL_FITS)

## ----load, message = FALSE----------------------------------------------------
# library(tulpa)

## ----parse-show---------------------------------------------------------------
# pf <- tulpa_parse_formula(y ~ x + z + (1 | g) + (1 + x || site))
# pf

## ----make-data----------------------------------------------------------------
# n  <- 200
# df <- data.frame(
#   y    = rpois(n, 3),
#   x    = rnorm(n),
#   z    = rnorm(n),
#   g    = factor(sample(letters[1:6], n, replace = TRUE)),
#   site = factor(sample(paste0("s", 1:4), n, replace = TRUE))
# )
# str(df)

## ----build--------------------------------------------------------------------
# bundle <- tulpa_build_model_data(pf, df)
# names(bundle)

## ----design-------------------------------------------------------------------
# dim(bundle$X)
# colnames(bundle$X)
# head(bundle$X, 3)

## ----counts-------------------------------------------------------------------
# c(n_obs = bundle$n_obs, n_fixed = bundle$n_fixed,
#   n_re_terms = bundle$n_re_terms)

## ----re-intercept-------------------------------------------------------------
# re1 <- bundle$re_terms[[1]]
# re1[c("group_var", "n_groups", "n_coefs", "has_intercept")]
# re1$levels

## ----re-idx-------------------------------------------------------------------
# head(re1$group_idx, 12)
# table(re1$group_idx)

## ----re-slope-----------------------------------------------------------------
# re2 <- bundle$re_terms[[2]]
# re2[c("group_var", "n_groups", "n_coefs", "correlated")]
# head(re2$slope_matrix)

## ----re-nested----------------------------------------------------------------
# pn <- tulpa_parse_formula(y ~ x + (1 | g/site))
# pn$n_re_terms
# vapply(pn$random_effects, `[[`, character(1), "group_var")

## ----binom-cbind--------------------------------------------------------------
# db <- data.frame(x = rnorm(n))
# prob   <- plogis(-0.2 + 0.8 * db$x)
# db$succ <- rbinom(n, 15, prob)
# db$fail <- 15 - db$succ
# 
# pf_b   <- tulpa_parse_formula(cbind(succ, fail) ~ x)
# bun_b  <- tulpa_build_model_data(pf_b, db)
# head(bun_b$y, 3)

## ----binom-ntrials------------------------------------------------------------
# db$tot <- 15L
# fit_b <- tulpa(succ ~ x, data = db, family = "binomial",
#                n_trials = db$tot, mode = "laplace")
# coef(fit_b)
# 
# fit_cbind <- tulpa(cbind(succ, fail) ~ x, data = db, family = "binomial",
#                    mode = "laplace")
# max(abs(coef(fit_cbind) - coef(fit_b)))

## ----offset-------------------------------------------------------------------
# dp <- data.frame(x = rnorm(n), expo = runif(n, 1, 8))
# dp$y <- rpois(n, dp$expo * exp(0.1 + 0.5 * dp$x))
# 
# pf_o  <- tulpa_parse_formula(y ~ x + offset(log(expo)))
# bun_o <- tulpa_build_model_data(pf_o, dp)
# head(bun_o$offset, 4)
# colnames(bun_o$X)

## ----offset-fit---------------------------------------------------------------
# fit_o <- tulpa(y ~ x + offset(log(expo)), data = dp,
#                family = "poisson", mode = "laplace")
# coef(fit_o)

## ----err-group, error = TRUE--------------------------------------------------
try({
# bad <- tulpa_parse_formula(y ~ x + (1 | region))
# tulpa_build_model_data(bad, df)
})

## ----err-response, error = TRUE-----------------------------------------------
try({
# tulpa_build_model_data(tulpa_parse_formula(count ~ x), df)
})

## ----err-spatial, error = TRUE------------------------------------------------
try({
# tulpa_parse_formula(y ~ spatial(x, g))
})

## ----err-spatial-spec, error = TRUE-------------------------------------------
try({
# tulpa(y ~ x + spatial(g), data = df, family = "poisson", mode = "laplace")
})

