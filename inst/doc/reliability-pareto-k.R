## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  fig.width = 6, fig.height = 4
)
set.seed(20260619)

## ----cran-gate, include = FALSE-----------------------------------------------
# The model fits below are evaluated when the article is built locally, in CI
# and for the pkgdown site (all of which set NOT_CRAN). CRAN's check farm gives
# the whole check a ten-minute budget, which these fits do not fit inside, so
# there the code is shown without being run.
EVAL_FITS <- identical(Sys.getenv("NOT_CRAN"), "true")
knitr::opts_chunk$set(eval = EVAL_FITS)

## ----load, message = FALSE----------------------------------------------------
# library(tulpa)

## ----build--------------------------------------------------------------------
# S     <- 25L
# nb    <- lapply(seq_len(S), function(s) setdiff(c(s - 1L, s + 1L), c(0L, S + 1L)))
# nn    <- lengths(nb)
# field <- as.numeric(scale(cumsum(rnorm(S, 0, 0.4))))
# 
# mk_arm <- function(m, fam) {
#   si  <- sample(S, m, replace = TRUE)
#   x   <- rnorm(m)
#   lin <- 0.2 + 0.5 * x + 0.8 * field[si]
#   y   <- if (fam == "binomial") rbinom(m, 1L, plogis(lin)) else lin + rnorm(m, 0, 0.5)
#   list(y = as.numeric(y), n_trials = rep(1L, m), X = cbind(1, x),
#        spatial_idx = si, family = fam,
#        # residual VARIANCE; the gaussian arm is simulated at residual SD 0.5
#        phi = if (fam == "gaussian") 0.5^2 else 1)
# }
# 
# prior <- list(type = "icar", n_spatial_units = S,
#               adj_row_ptr = c(0L, cumsum(nn)), adj_col_idx = unlist(nb) - 1L,
#               n_neighbors = nn, sigma_grid = seq(0.2, 1.6, length.out = 7))

## ----fit----------------------------------------------------------------------
# resp <- list(occ = mk_arm(200L, "binomial"),
#              pos = mk_arm(200L, "gaussian"))
# fit <- tulpa_nested_laplace_joint(
#   responses = resp,
#   prior     = prior,
#   control   = list(k_samples = 400L))
# 
# c(pareto_k = round(fit$pareto_k, 3),
#   is_ess   = round(fit$pareto_k_is_ess, 1))
# fit$pareto_k_scope

## ----band---------------------------------------------------------------------
# band <- cut(fit$pareto_k, c(-Inf, 0.5, 0.7, Inf),
#             labels = c("good", "ok", "unreliable"))
# band

## ----threshold----------------------------------------------------------------
# k_usable <- function(S) pmin(1 - 1 / log10(S), 0.7)
# S_grid   <- c(100, 200, 400, 1000, 2154, 4000)
# data.frame(draws = S_grid, usable_boundary = round(k_usable(S_grid), 3))

## ----bootstrap----------------------------------------------------------------
# c(k       = round(fit$pareto_k, 3),
#   ci_low  = round(fit$pareto_k_ci_low, 3),
#   ci_high = round(fit$pareto_k_ci_high, 3))
# fit$pareto_k_band_confident

## ----more-draws---------------------------------------------------------------
# fit_hi <- tulpa_nested_laplace_joint(
#   responses = resp,
#   prior     = prior,
#   control   = list(k_samples = 1500L))
# 
# c(k              = round(fit_hi$pareto_k, 3),
#   ci_low         = round(fit_hi$pareto_k_ci_low, 3),
#   ci_high        = round(fit_hi$pareto_k_ci_high, 3),
#   band_confident = fit_hi$pareto_k_band_confident)

## ----k-quality----------------------------------------------------------------
# fit_q <- tulpa_nested_laplace_joint(
#   responses = resp,
#   prior     = prior,
#   control   = list(k_quality = "good"))
# 
# c(requested = fit_q$k_quality_requested,
#   reached   = fit_q$k_quality_reached,
#   best      = fit_q$k_quality_best,
#   draws     = fit_q$diagnose_draws)
# fit_q$k_quality_reason

## ----skew---------------------------------------------------------------------
# fit$inner_skew
# fit$inner_skew_idx

## ----skew-band----------------------------------------------------------------
# cut(abs(fit$inner_skew), c(-Inf, 0.5, 1.0, Inf),
#     labels = c("good", "ok", "unreliable"))

