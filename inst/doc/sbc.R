## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  fig.width = 7, fig.height = 5
)
set.seed(20260828)

## ----cran-gate, include = FALSE-----------------------------------------------
# The fits below are evaluated when the article is built locally, in CI and for
# the pkgdown site (all of which set NOT_CRAN). Each experiment here runs a few
# hundred fits, which does not fit inside CRAN's ten-minute budget for the whole
# check, so there the code is shown without being run.
EVAL_FITS <- identical(Sys.getenv("NOT_CRAN"), "true")
knitr::opts_chunk$set(eval = EVAL_FITS)

## ----load, message = FALSE----------------------------------------------------
# library(tulpa)

## ----fixture------------------------------------------------------------------
# GRID <- exp(seq(log(0.2), log(1.5), length.out = 7))
# PHI  <- 0.7
# BETA <- c(-0.2, 0.7)
# 
# simulate_one <- function(seed) {
#   set.seed(seed)
#   sigma  <- GRID[sample.int(length(GRID), 1L)]
#   region <- rep(seq_len(6L), each = 4L)
#   X      <- cbind(1, rnorm(24L))
#   u      <- rnorm(6L, 0, sigma)
#   list(y      = as.numeric(X %*% BETA) + u[region] + rnorm(24L, 0, PHI),
#        X      = X,
#        region = region,
#        theta  = c(beta1 = BETA[1], beta2 = BETA[2], sigma = sigma))
# }
# 
# fit_one <- function(d) {
#   tulpa_nested_laplace(
#     y = d$y, n_trials = rep(1L, length(d$y)), X = d$X,
#     prior = list(list(type = "iid", obs_idx = d$region,
#                       n_units = max(d$region), sigma_grid = GRID)),
#     family = "gaussian", phi = PHI,
#     control = list(n_threads = 1L, keep_grid_hessians = TRUE,
#                    auto_recenter = FALSE, progress = FALSE))
# }

## ----arms---------------------------------------------------------------------
# arms <- function(d) {
#   fit <- fit_one(d)
#   m   <- coef(fit)
#   se  <- sqrt(diag(vcov(fit)))
#   D   <- tulpa_posterior_draws(fit, n = 2000)
#   w   <- fit$weights / sum(fit$weights)
# 
#   list(
#     mixture = list(
#       beta1 = sbc_draws(D[, 1]),
#       beta2 = sbc_draws(D[, 2]),
#       sigma = sbc_discrete(as.numeric(fit$theta_grid), w)),
#     collapsed = list(
#       beta1 = sbc_normal(m[1], se[1]),
#       beta2 = sbc_normal(m[2], se[2])),
#     narrow = list(
#       beta1 = sbc_normal(m[1], se[1] / 1.25),
#       beta2 = sbc_normal(m[2], se[2] / 1.25)))
# }

## ----prior-predictive---------------------------------------------------------
# res <- sbc("prior_predictive",
#            simulator  = simulate_one,
#            fitter     = arms,
#            n_sim      = 200L,
#            flat_prior = c("beta1", "beta2"))
# res

## ----crps---------------------------------------------------------------------
# summary(res, baseline = "mixture")

## ----plot-raw, fig.alt = "PIT ECDF difference from uniform against the simultaneous band"----
# plot(res, arm = c("mixture", "narrow"), quantity = "beta2")

## ----plot-folded, fig.alt = "Folded PIT ECDF difference from uniform against the simultaneous band"----
# plot(res, arm = c("mixture", "narrow"), quantity = "beta2", folded = TRUE)

## ----posterior-model----------------------------------------------------------
# d_obs <- simulate_one(99L)
# 
# model <- list(
#   data_obs = d_obs,
# 
#   fit = function(data) fit_one(data),
# 
#   draw_theta = function(fit, seed) {
#     set.seed(seed)
#     b <- tulpa_posterior_draws(fit, n = 1L)
#     k <- attr(b, "cells")[1]
#     c(beta1 = unname(b[1, 1]), beta2 = unname(b[1, 2]),
#       sigma = as.numeric(fit$theta_grid)[k])
#   },
# 
#   simulate = function(theta, seed) {
#     set.seed(seed)
#     region <- rep(seq_len(6L), each = 4L)
#     X      <- cbind(1, rnorm(24L))
#     u      <- rnorm(6L, 0, theta[["sigma"]])
#     list(y = as.numeric(X %*% theta[c("beta1", "beta2")]) +
#            u[region] + rnorm(24L, 0, PHI),
#          X = X, region = region)
#   },
# 
#   pool = function(obs, rep) list(
#     y      = c(obs$y, rep$y),
#     X      = rbind(obs$X, rep$X),
#     region = as.integer(c(obs$region, rep$region + max(obs$region)))),
# 
#   arms = function(fit, data) {
#     m  <- coef(fit)
#     se <- sqrt(diag(vcov(fit)))
#     D  <- tulpa_posterior_draws(fit, n = 2000)
#     list(
#       mixture = list(
#         beta1 = sbc_draws(D[, 1]),
#         beta2 = sbc_draws(D[, 2]),
#         sigma = sbc_discrete(as.numeric(fit$theta_grid),
#                              fit$weights / sum(fit$weights))),
#       narrow = list(
#         beta1 = sbc_normal(m[1], se[1] / 1.25),
#         beta2 = sbc_normal(m[2], se[2] / 1.25)))
#   },
# 
#   group_ids = function(data) data$region)

## ----posterior-run------------------------------------------------------------
# pres <- sbc("posterior", model = model, n_sim = 200L)
# pres

## ----premises-----------------------------------------------------------------
# str(pres$premises)

## ----combined-----------------------------------------------------------------
# fit <- fit_one(d_obs)
# diagnostics(fit, sbc = res)

