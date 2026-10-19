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
# Read here, not in a gated chunk: chunk options are evaluated whether or not
# the chunk runs, so a flag a chunk option reads has to exist either way.
has_ggplot <- requireNamespace("ggplot2", quietly = TRUE)

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

## ----sim-gaussian-------------------------------------------------------------
# n  <- 400
# x  <- rnorm(n)
# y  <- 0.5 + 1.2 * x + rnorm(n, sd = 0.8)
# df <- data.frame(y = y, x = x)

## ----fit-gaussian-------------------------------------------------------------
# fit <- tulpa(y ~ x, data = df, family = "gaussian",
#              mode = "laplace", phi = 0.8^2)
# coef(fit)

## ----summary-gaussian---------------------------------------------------------
# summary(fit)

## ----confint-gaussian---------------------------------------------------------
# confint(fit)

## ----sim-re-------------------------------------------------------------------
# g  <- factor(sample(1:12, n, replace = TRUE))
# u  <- rnorm(12, sd = 0.6)
# df$y <- 0.5 + 1.2 * df$x + u[g] + rnorm(n, sd = 0.8)
# df$g <- g
# 
# fit_re <- tulpa(y ~ x + (1 | g), data = df, family = "gaussian",
#                 mode = "laplace", sigma_re = 0.6, phi = 0.8^2)
# coef(fit_re)

## ----ranef--------------------------------------------------------------------
# head(ranef(fit_re), 4)

## ----compare------------------------------------------------------------------
# m0 <- tulpa(y ~ 1,     data = df, family = "gaussian", mode = "laplace", phi = 0.8^2)
# m1 <- tulpa(y ~ x,     data = df, family = "gaussian", mode = "laplace", phi = 0.8^2)
# m2 <- tulpa(y ~ x + (1 | g), data = df, family = "gaussian",
#             mode = "laplace", sigma_re = 0.6, phi = 0.8^2)
# compare_models(intercept = m0, slope = m1, slope_re = m2, criterion = "loglik")

## ----predict------------------------------------------------------------------
# nd <- data.frame(x = seq(-2, 2, length.out = 50))
# pr <- predict(fit_re, newdata = nd, se.fit = TRUE)
# head(pr, 3)

## ----predict-plot, eval = has_ggplot && EVAL_FITS, fig.alt = "Predicted response across x with a 95 percent credible band"----
# library(ggplot2)
# ggplot(data.frame(x = nd$x, fit = pr$fit, lo = pr$lower, hi = pr$upper),
#        aes(x, fit)) +
#   geom_ribbon(aes(ymin = lo, ymax = hi), fill = "steelblue", alpha = 0.25) +
#   geom_line(linewidth = 1) +
#   labs(x = "x", y = "predicted y") +
#   theme(panel.background = element_rect(fill = "transparent"),
#         plot.background  = element_rect(fill = "transparent"))

## ----families-----------------------------------------------------------------
# # Poisson counts
# dp <- data.frame(y = rpois(n, exp(0.2 + 0.6 * x)), x = x)
# coef(tulpa(y ~ x, data = dp, family = "poisson", mode = "laplace"))
# 
# # Beta proportions in (0, 1), precision phi
# mu <- plogis(0.1 + 0.8 * x)
# db <- data.frame(y = rbeta(n, mu * 8, (1 - mu) * 8), x = x)
# coef(tulpa(y ~ x, data = db, family = "beta", mode = "laplace", phi = 8))

## ----modes, eval = FALSE------------------------------------------------------
# inference_mode_info()

## ----tiers--------------------------------------------------------------------
# df_b <- df
# df_b$y <- rbinom(n, 1, plogis(-0.3 + 1.0 * df$x + u[df$g]))
# 
# fit_lap <- tulpa(y ~ x + (1 | g), data = df_b, family = "binomial",
#                  mode = "laplace", sigma_re = 0.6)
# fit_mala <- tulpa(y ~ x + (1 | g), data = df_b, family = "binomial",
#                   mode = "mala", sigma_re = 0.6,
#                   control = list(n_iter = 450, warmup = 150))

## ----tiers-compare------------------------------------------------------------
# data.frame(
#   term    = names(coef(fit_lap)),
#   laplace = round(coef(fit_lap), 3),
#   mala    = round(coef(fit_mala), 3)
# )

## ----tier-fields--------------------------------------------------------------
# unlist(summary(fit_mala)$inference[c("backend", "inference_tier")])

## ----trace-plot, fig.width = 6, fig.height = 4, fig.alt = "Trace of the MALA chain for the fixed effects"----
# plot(fit_mala, type = "trace")

## ----spatial-build------------------------------------------------------------
# K <- 20
# W <- matrix(0, K, K)
# for (i in 1:K) { j <- if (i < K) i + 1 else 1; W[i, j] <- W[j, i] <- 1 }
# 
# region <- factor(sample(1:K, n, replace = TRUE))
# field  <- as.numeric(scale(sin(2 * pi * (1:K) / K)))[region]
# ds <- data.frame(y = rbinom(n, 1, plogis(-0.2 + 0.7 * x + field)),
#                  x = x, region = region)
# 
# fit_sp <- tulpa(y ~ x + spatial(region), data = ds, family = "binomial",
#                 spatial = list(type = "icar", adjacency = W),
#                 mode = "laplace")
# coef(fit_sp)

## ----spatial-plot, eval = has_ggplot && EVAL_FITS, fig.alt = "Estimated spatial field effect per region around the ring"----
# library(ggplot2)
# fe <- field_effects(fit_sp)
# ggplot(data.frame(region = fe$unit, effect = fe$estimate), aes(region, effect)) +
#   geom_line(linewidth = 1, colour = "steelblue") +
#   geom_point() +
#   labs(x = "region", y = "field effect") +
#   theme(panel.background = element_rect(fill = "transparent"),
#         plot.background  = element_rect(fill = "transparent"))

## ----temporal-fit-------------------------------------------------------------
# Tt    <- 30
# time  <- sample(seq_len(Tt), n, replace = TRUE)
# trend <- 1.2 * sin(2 * pi * seq_len(Tt) / Tt)
# xt    <- rnorm(n)
# dt    <- data.frame(y = rpois(n, exp(0.4 + 0.5 * xt + trend[time])),
#                     x = xt, time = time)
# 
# fit_t <- tulpa(y ~ x, data = dt, family = "poisson",
#                temporal = temporal_rw1("time"), mode = "auto")
# coef(fit_t)

## ----temporal-plot, fig.alt = "Estimated temporal random-walk trend against the simulated truth"----
# g  <- tulpa_outer_grid(fit_t)
# te <- colSums(g$weights * g$modes)[g$n_fixed + seq_len(Tt)]
# ggplot(data.frame(time = seq_len(Tt),
#                   est = te - mean(te),
#                   truth = trend - mean(trend)),
#        aes(time)) +
#   geom_line(aes(y = truth), linewidth = 1, colour = "grey50") +
#   geom_line(aes(y = est), linewidth = 1, colour = "steelblue") +
#   labs(x = "time", y = "trend (centred)") +
#   theme(panel.background = element_rect(fill = "transparent"),
#         plot.background  = element_rect(fill = "transparent"))

## ----prior-fit----------------------------------------------------------------
# fam <- tulpa_family(
#   "poisson",
#   function(eta, params, n_obs, ...) rpois(n_obs, exp(eta[[1]]))
# )
# pp <- prior_predict(y ~ x, family = fam, data = dp, n_draws = 50,
#                     priors = tulpa_priors(beta = prior_normal(0, 1)))
# pp

## ----prior-plot, fig.alt = "Prior predictive densities of the simulated response under the chosen priors"----
# sims <- data.frame(
#   value = unlist(pp$y),
#   draw  = factor(rep(seq_along(pp$y), lengths(pp$y)))
# )
# ggplot(sims, aes(value, group = draw)) +
#   geom_density(colour = "steelblue", alpha = 0.3) +
#   labs(x = "simulated y", y = "density") +
#   theme(panel.background = element_rect(fill = "transparent"),
#         plot.background  = element_rect(fill = "transparent"))

## ----tgmrf-build, message = FALSE---------------------------------------------
# library(Matrix)
# m <- 20
# D2 <- diff(diag(m), differences = 1)
# R  <- crossprod(D2)               # RW1 structure matrix
# blk <- tgmrf(
#   Q     = function(theta) as(theta[1] * (R + 1e-4 * diag(m)), "dgCMatrix"),
#   prior = function(theta) dgamma(theta[1], 2, 1, log = TRUE),
#   init  = c(tau = 1)
# )
# blk

## ----tgmrf-plot, fig.alt = "Sparsity pattern of the user-defined RW1 precision matrix"----
# Q1 <- as.matrix(blk$Q(c(tau = 1)))
# ix <- which(Q1 != 0, arr.ind = TRUE)
# ggplot(data.frame(row = ix[, 1], col = ix[, 2]), aes(col, row)) +
#   geom_tile(fill = "steelblue") +
#   scale_y_reverse() +
#   labs(x = "column", y = "row") +
#   theme(panel.background = element_rect(fill = "transparent"),
#         plot.background  = element_rect(fill = "transparent"))

## ----tidy---------------------------------------------------------------------
# tidy(fit_re)

## ----glance-------------------------------------------------------------------
# glance(fit_mala)[c("n_samples", "logLik", "mean_accept", "n_divergent")]

