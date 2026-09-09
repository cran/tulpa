## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>", fig.width = 6, fig.height = 4)
set.seed(20260716)

## ----cran-gate, include = FALSE-----------------------------------------------
# The model fits below are evaluated when the article is built locally, in CI
# and for the pkgdown site (all of which set NOT_CRAN). CRAN's check farm gives
# the whole check a ten-minute budget, which these fits do not fit inside, so
# there the code is shown without being run.
EVAL_FITS <- identical(Sys.getenv("NOT_CRAN"), "true")
knitr::opts_chunk$set(eval = EVAL_FITS)

## ----load, message = FALSE----------------------------------------------------
# library(tulpa)

## ----sim----------------------------------------------------------------------
# G   <- 60L                 # groups
# npg <- 12L                 # observations per group
# N   <- G * npg
# grp <- rep(seq_len(G), each = npg)
# x   <- rnorm(N)
# 
# # True Sigma: sd 0.7 (intercept), 0.5 (slope), correlation 0.4.
# Sigma <- matrix(c(0.7^2,            0.4 * 0.7 * 0.5,
#                   0.4 * 0.7 * 0.5,  0.5^2), 2)
# u <- t(t(chol(Sigma)) %*% matrix(rnorm(2 * G), 2))   # G x 2 group effects
# eta <- 0.2 + 0.5 * x + u[grp, 1] + u[grp, 2] * x
# y   <- rpois(N, exp(eta))
# d   <- data.frame(y = y, x = x, g = factor(grp))

## ----fit----------------------------------------------------------------------
# fit <- tulpa(y ~ x + (1 + x | g), data = d, family = "poisson",
#              mode = "laplace")
# fit$posterior[, c("parameter", "median", "ci_lo", "ci_hi")]

## ----gibbs, eval = FALSE------------------------------------------------------
# fit_gibbs <- tulpa(y ~ x + (1 + x | g), data = d, family = "poisson",
#                    mode = "laplace",
#                    control = list(re_cov = "gibbs",
#                                   n_iter = 2000L, warmup = 1000L))

