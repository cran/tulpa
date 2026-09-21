## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  fig.width = 6, fig.height = 4
)
set.seed(20260529)
has_ggplot <- requireNamespace("ggplot2", quietly = TRUE)

## ----cran-gate, include = FALSE-----------------------------------------------
# The model fits below are evaluated when the article is built locally, in CI
# and for the pkgdown site (all of which set NOT_CRAN). CRAN's check farm gives
# the whole check a ten-minute budget, which these fits do not fit inside, so
# there the code is shown without being run.
EVAL_FITS <- identical(Sys.getenv("NOT_CRAN"), "true")
knitr::opts_chunk$set(eval = EVAL_FITS)

## ----load, message = FALSE----------------------------------------------------
# library(tulpa)

## ----first-evidence-----------------------------------------------------------
# n  <- 500
# x  <- rnorm(n)
# y0 <- 0.5 + 1.2 * x + rnorm(n, sd = 0.8)
# df <- data.frame(y = y0, x = x)
# 
# fit <- tulpa(y ~ x, data = df, family = "gaussian",
#              mode = "laplace", phi = 0.8^2)
# logLik(fit)

## ----evidence-attrs-----------------------------------------------------------
# c(df = attr(logLik(fit), "df"), nobs = attr(logLik(fit), "nobs"))

## ----sim-ladder---------------------------------------------------------------
# n  <- 500
# x  <- rnorm(n)
# z  <- rnorm(n)
# g  <- factor(sample(1:15, n, replace = TRUE))
# u  <- rnorm(15, sd = 0.7)
# y  <- 0.5 + 1.2 * x + 0.8 * z + u[g] + rnorm(n, sd = 0.8)
# dat <- data.frame(y = y, x = x, z = z, g = g)

## ----fit-ladder---------------------------------------------------------------
# m0 <- tulpa(y ~ 1, data = dat, family = "gaussian",
#             mode = "laplace", phi = 0.8^2)
# m1 <- tulpa(y ~ x, data = dat, family = "gaussian",
#             mode = "laplace", phi = 0.8^2)
# m2 <- tulpa(y ~ x + (1 | g), data = dat, family = "gaussian",
#             mode = "laplace", sigma_re = 0.7, phi = 0.8^2)
# m3 <- tulpa(y ~ x + z + (1 | g), data = dat, family = "gaussian",
#             mode = "laplace", sigma_re = 0.7, phi = 0.8^2)

## ----ladder-evidence----------------------------------------------------------
# ll <- c(intercept = as.numeric(logLik(m0)),
#         slope     = as.numeric(logLik(m1)),
#         slope_re  = as.numeric(logLik(m2)),
#         full      = as.numeric(logLik(m3)))
# data.frame(model = names(ll), logLik = round(ll, 1),
#            gain = c(NA, round(diff(ll), 1)))

## ----ladder-plot, eval = has_ggplot && EVAL_FITS, fig.alt = "Bar chart of cumulative log evidence by ladder rung"----
# library(ggplot2)
# pd <- data.frame(model = factor(names(ll), levels = names(ll)),
#                  rel = ll - ll[1])
# ggplot(pd, aes(model, rel)) +
#   geom_col(width = 0.6, fill = "#3a6ea5") +
#   labs(x = NULL, y = "log evidence vs. null") +
#   theme_minimal() +
#   theme(panel.background = element_rect(fill = "transparent", colour = NA),
#         plot.background  = element_rect(fill = "transparent", colour = NA))

## ----noise-term---------------------------------------------------------------
# dat$w <- rnorm(n)
# m4 <- tulpa(y ~ x + z + w + (1 | g), data = dat, family = "gaussian",
#             mode = "laplace", sigma_re = 0.7, phi = 0.8^2)
# c(full = round(as.numeric(logLik(m3)), 2),
#   plus_noise = round(as.numeric(logLik(m4)), 2),
#   gain = round(as.numeric(logLik(m4)) - as.numeric(logLik(m3)), 2))

## ----compare------------------------------------------------------------------
# compare_models(intercept = m0, slope = m1,
#                slope_re = m2, full = m3, criterion = "loglik")

## ----binom-ladder-------------------------------------------------------------
# set.seed(101)
# xb  <- rnorm(n); zb <- rnorm(n)
# yb  <- rbinom(n, 1, plogis(-0.4 + 1.1 * xb + 0.9 * zb))
# dfb <- data.frame(y = yb, x = xb, z = zb)
# 
# b0 <- tulpa(y ~ 1,     data = dfb, family = "binomial", mode = "laplace")
# b1 <- tulpa(y ~ x,     data = dfb, family = "binomial", mode = "laplace")
# b2 <- tulpa(y ~ x + z, data = dfb, family = "binomial", mode = "laplace")
# compare_models(intercept = b0, x = b1, xz = b2, criterion = "loglik")

## ----non-nested---------------------------------------------------------------
# mx <- tulpa(y ~ x, data = dat, family = "gaussian",
#             mode = "laplace", phi = 0.8^2)
# mz <- tulpa(y ~ z, data = dat, family = "gaussian",
#             mode = "laplace", phi = 0.8^2)
# compare_models(x_only = mx, z_only = mz, criterion = "loglik")

## ----interpret-gap------------------------------------------------------------
# gain <- as.numeric(logLik(b2)) - as.numeric(logLik(b1))
# c(log_evidence_gain = round(gain, 2),
#   evidence_ratio    = round(exp(gain), 1))

## ----bridge-------------------------------------------------------------------
# y_obs   <- 1.5
# log_post <- function(theta)
#   dnorm(y_obs, theta, 1, log = TRUE) + dnorm(theta, 0, 10, log = TRUE)
# post_sd  <- sqrt(100 / 101)
# draws    <- matrix(rnorm(4000, y_obs * 100 / 101, post_sd), ncol = 1)
# bs <- bridge_sampling(draws, log_post)
# c(bridge = round(bs$log_marginal, 3),
#   exact  = round(dnorm(y_obs, 0, sqrt(101), log = TRUE), 3))

## ----glance-one---------------------------------------------------------------
# glance(m3)

## ----glance-stack-------------------------------------------------------------
# do.call(rbind, Map(function(m, nm) cbind(model = nm, glance(m)),
#                    list(m0, m1, m2, m3),
#                    c("intercept", "slope", "slope_re", "full")))

## ----tidy-winner--------------------------------------------------------------
# tidy(m3)

## ----waic-needs, error = TRUE-------------------------------------------------
try({
# loo::waic(b2)
})

## ----model-average------------------------------------------------------------
# ma <- model_average(slope = m1, slope_re = m2, full = m3,
#                     weights = "waic")
# ma$weights
# head(round(ma$averaged, 3))

