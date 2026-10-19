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

## ----eval = FALSE-------------------------------------------------------------
# # Current release, built for Windows and macOS
# install.packages("tulpa",
#                  repos = c("https://gcol33.r-universe.dev",
#                            "https://cloud.r-project.org"))
# 
# # Development version from GitHub
# install.packages("pak")
# pak::pak("gcol33/tulpa")
# 
# # Pin a release
# pak::pak("gcol33/tulpa@v0.6.0")

## ----load, message = FALSE----------------------------------------------------
# library(tulpa)

## ----mode-info----------------------------------------------------------------
# inference_mode_info()

## ----auto-build---------------------------------------------------------------
# n <- 400L; K <- 20L
# W <- matrix(0, K, K)
# for (i in 1:K) { j <- if (i < K) i + 1L else 1L; W[i, j] <- W[j, i] <- 1 }
# x      <- rnorm(n)
# region <- factor(sample(1:K, n, replace = TRUE))
# field  <- as.numeric(scale(sin(2 * pi * (1:K) / K)))[region]
# ds <- data.frame(y = rbinom(n, 1, plogis(-0.2 + 0.7 * x + field)),
#                  x = x, region = region)

## ----auto-spatial-------------------------------------------------------------
# fit_auto <- tulpa(y ~ x + spatial(region), data = ds, family = "binomial",
#                   spatial = list(type = "icar", adjacency = W), mode = "auto")
# summary(fit_auto)$inference[c("backend", "inference_tier", "selection_reason")]

## ----auto-large---------------------------------------------------------------
# nL <- 60000L
# xL <- rnorm(nL)
# dL <- data.frame(y = 0.5 + 1.2 * xL + rnorm(nL, sd = 0.8), x = xL)
# fit_big <- tulpa(y ~ x, data = dL, family = "gaussian", mode = "auto",
#                  phi = 0.8^2)
# summary(fit_big)$inference[c("backend", "inference_tier", "selection_reason")]

## ----auto-large-coef----------------------------------------------------------
# coef(fit_big)

## ----laplace-fit--------------------------------------------------------------
# set.seed(101)
# g  <- factor(sample(1:12, n, replace = TRUE))
# u  <- rnorm(12, sd = 0.6)
# db <- data.frame(y = rbinom(n, 1, plogis(-0.3 + 1.0 * x + u[g])),
#                  x = x, g = g)
# fit_lap <- tulpa(y ~ x + (1 | g), data = db, family = "binomial",
#                  mode = "laplace", sigma_re = 0.6)
# coef(fit_lap)

## ----pathfinder-fit-----------------------------------------------------------
# fit_pf <- tulpa(y ~ x + (1 | g), data = db, family = "binomial",
#                 mode = "pathfinder", sigma_re = 0.6,
#                 control = list(n_draws = 450))
# coef(fit_pf)
# summary(fit_pf)$reliability$elbo

## ----mala-fit-----------------------------------------------------------------
# fit_mala <- tulpa(y ~ x + (1 | g), data = db, family = "binomial",
#                   mode = "mala", sigma_re = 0.6,
#                   control = list(n_iter = 450, warmup = 150))
# coef(fit_mala)
# summary(fit_mala)$reliability$mean_accept

## ----imh-fit------------------------------------------------------------------
# fit_imh <- tulpa(y ~ x + (1 | g), data = db, family = "binomial",
#                  mode = "imh_laplace", sigma_re = 0.6,
#                  control = list(n_iter = 450, warmup = 150))
# coef(fit_imh)
# summary(fit_imh)$reliability$mean_accept

## ----gibbs-fields-------------------------------------------------------------
# round(coef(fit_auto), 3)
# draws_auto <- posterior_sample(fit_auto)
# tail(colnames(draws_auto), 3)
# round(colMeans(draws_auto)[c("log_tau_spatial", "phi_spatial[1]")], 3)

## ----re-cov-slope-------------------------------------------------------------
# set.seed(20260531)
# ng <- 60; ni <- 15
# g   <- rep(seq_len(ng), each = ni)
# xg  <- rnorm(ng * ni)
# Sig <- matrix(c(0.9^2,            0.5 * 0.9 * 0.6,
#                 0.5 * 0.9 * 0.6,  0.6^2), 2)
# b   <- matrix(rnorm(ng * 2), ng) %*% chol(Sig)
# eta <- -0.2 + 0.7 * xg + b[g, 1] + b[g, 2] * xg
# dsl <- data.frame(y = rbinom(ng * ni, 1, plogis(eta)),
#                   x = xg, g = factor(g))
# 
# fit_rc <- tulpa(y ~ x + (1 + x | g), data = dsl,
#                 family = "binomial", mode = "laplace")
# summary(fit_rc)$inference$backend

## ----re-cov-sigma-------------------------------------------------------------
# round(attr(VarCorr(fit_rc), "cov")$g, 3)

## ----re-cov-k-----------------------------------------------------------------
# round(attr(diagnostics(fit_rc), "pareto_k"), 2)

## ----ep-fit, eval = FALSE-----------------------------------------------------
# fit_ep <- tulpa(y ~ x, data = d, family = "binomial", mode = "ep")
# coef(fit_ep)

## ----timing-------------------------------------------------------------------
# t_lap  <- system.time(
#   f_lap  <- tulpa(y ~ x + (1 | g), data = db, family = "binomial",
#                   mode = "laplace", sigma_re = 0.6))[["elapsed"]]
# t_mala <- system.time(
#   f_mala <- tulpa(y ~ x + (1 | g), data = db, family = "binomial",
#                   mode = "mala", sigma_re = 0.6,
#                   control = list(n_iter = 450, warmup = 150)))[["elapsed"]]
# t_pf   <- system.time(
#   f_pf   <- tulpa(y ~ x + (1 | g), data = db, family = "binomial",
#                   mode = "pathfinder", sigma_re = 0.6,
#                   control = list(n_draws = 450)))[["elapsed"]]

## ----timing-table-------------------------------------------------------------
# slope_se <- function(f) coef(summary(f))["x", "std.error"]
# data.frame(
#   backend  = vapply(list(f_lap, f_mala, f_pf),
#                     function(f) summary(f)$inference$backend, character(1)),
#   tier     = vapply(list(f_lap, f_mala, f_pf),
#                     function(f) summary(f)$inference$inference_tier,
#                     numeric(1)),
#   slope    = round(c(coef(f_lap)["x"], coef(f_mala)["x"],
#                      coef(f_pf)["x"]), 3),
#   slope_se = round(c(slope_se(f_lap), slope_se(f_mala),
#                      slope_se(f_pf)), 3),
#   seconds  = round(c(t_lap, t_mala, t_pf), 3)
# )

## ----glance-------------------------------------------------------------------
# glance(f_mala)[c("n_samples", "mean_accept", "n_divergent")]

