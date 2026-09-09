## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ----cran-gate, include = FALSE-----------------------------------------------
# The model fits below are evaluated when the article is built locally, in CI
# and for the pkgdown site (all of which set NOT_CRAN). CRAN's check farm gives
# the whole check a ten-minute budget, which these fits do not fit inside, so
# there the code is shown without being run.
EVAL_FITS <- identical(Sys.getenv("NOT_CRAN"), "true")
knitr::opts_chunk$set(eval = EVAL_FITS)

## ----load, message = FALSE----------------------------------------------------
# library(tulpa)

## ----estep, eval = FALSE------------------------------------------------------
# e_step <- function(fits, ...) {
#   # Use the current fits to compute the responsibility of each observation
#   # (e.g. the posterior probability that a zero is a Poisson zero, not a
#   # structural one). Return them as a `weights` element.
#   list(weights = responsibilities)
# }

## ----mstep, eval = FALSE------------------------------------------------------
# m_step_encode <- function(weights, ...) {
#   list(
#     lambda = list(y = counts, n_trials = 1L, X = X_abund,
#                   family = "poisson", offset = log(weights)),
#     pi     = list(y = z,      n_trials = 1L, X = X_zero,
#                   family = "binomial", offset = NULL)
#   )
# }

## ----fit, eval = FALSE--------------------------------------------------------
# fit <- tulpa_em_laplace(
#   e_step        = e_step,
#   m_step_encode = m_step_encode,
#   max_iter      = 30L,
#   tol           = 1e-4
# )
# fit$fits        # the converged per-submodel Laplace fits
# fit$n_iter
# fit$converged

## ----correct, eval = FALSE----------------------------------------------------
# # Multiple imputation: refit on several latent draws and pool.
# fit_mi <- tulpa_em_laplace(e_step, m_step_encode, correction = "mi")
# 
# # Warm-started Gibbs from the EM mode, then pool.
# fit_gibbs <- tulpa_em_laplace(e_step, m_step_encode, correction = "gibbs")

