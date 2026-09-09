## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  fig.width = 6, fig.height = 4
)
set.seed(20260518)

## ----cran-gate, include = FALSE-----------------------------------------------
# The model fits below are evaluated when the article is built locally, in CI
# and for the pkgdown site (all of which set NOT_CRAN). CRAN's check farm gives
# the whole check a ten-minute budget, which these fits do not fit inside, so
# there the code is shown without being run.
EVAL_FITS <- identical(Sys.getenv("NOT_CRAN"), "true")
knitr::opts_chunk$set(eval = EVAL_FITS)

## ----load, message = FALSE----------------------------------------------------
# library(tulpa)
# library(Matrix)

## ----block--------------------------------------------------------------------
# periodic_ar1 <- function(n) {
#   tgmrf(
#     Q = function(theta) {
#       sigma <- exp(theta[1]); rho <- tanh(theta[2])
#       d <- rep((1 + rho^2) / sigma^2, n)
#       o <- rep(-rho / sigma^2, n)
#       M <- Matrix::bandSparse(n, k = c(-1, 0, 1),
#                               diagonals = list(o, d, o))
#       M[1, n] <- M[n, 1] <- -rho / sigma^2     # wrap
#       methods::as(methods::as(M, "generalMatrix"), "CsparseMatrix")
#     },
#     prior = function(theta) {
#       dnorm(theta[1], 0, 1, log = TRUE) +     # weak on log_sigma
#       dnorm(theta[2], 0, 1, log = TRUE)       # weak on atanh_rho
#     },
#     init   = c(log_sigma = 0, atanh_rho = atanh(0.3)),
#     bounds = list(lower = c(log(0.3), atanh(0.0)),
#                   upper = c(log(3.0), atanh(0.9))),
#     name   = "periodic_ar1"
#   )
# }

## ----sim----------------------------------------------------------------------
# n <- 40L
# theta_true <- c(log(0.8), atanh(0.6))
# blk        <- periodic_ar1(n)
# 
# # z | theta_true ~ N(0, Q(theta_true)^{-1})
# Q_true <- blk$Q(theta_true)
# L      <- Matrix::Cholesky(Q_true)
# z_true <- as.numeric(Matrix::solve(L, rnorm(n), system = "Lt"))
# 
# # y_i ~ Poisson(exp(beta_0 + z_i))
# beta0 <- 0.3
# y     <- rpois(n, exp(beta0 + z_true))
# X     <- matrix(1, n, 1L)

## ----laplace------------------------------------------------------------------
# fit_lap <- tulpa_nested_laplace(
#   y = y, n_trials = rep(1L, n), X = X,
#   prior  = blk,
#   family = "poisson"
# )
# fit_lap$theta_mean    # posterior mean over the outer grid

## ----vi-----------------------------------------------------------------------
# fit_vi <- tulpa_tgmrf(
#   y = y, n_trials = rep(1L, n), X = X, block = blk,
#   family  = "poisson", mode = "vi",
#   n_draws = 800L
# )
# fit_vi$mode_theta
# fit_vi$elbo

## ----imh----------------------------------------------------------------------
# fit_imh <- tulpa_tgmrf(
#   y = y, n_trials = rep(1L, n), X = X, block = blk,
#   family = "poisson", mode = "imh",
#   n_iter = 1200L, warmup = 400L
# )
# fit_imh$means
# fit_imh$mean_accept

## ----nuts, eval = FALSE-------------------------------------------------------
# fit_nuts <- tulpa_tgmrf(
#   y = y, n_trials = rep(1L, n), X = X, block = blk,
#   family    = "poisson", mode = "nuts",
#   n_iter    = 200L, warmup = 100L,
#   max_depth = 4L
# )
# fit_nuts$means

## ----compare------------------------------------------------------------------
# data.frame(
#   parameter = blk$theta_names,
#   true      = theta_true,
#   laplace   = fit_lap$theta_mean,
#   vi_mode   = fit_vi$mode_theta,
#   imh_mean  = fit_imh$means
# )

