## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
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

## ----fit----------------------------------------------------------------------
# # A small nested-Laplace fit over an ICAR field on a chain graph.
# S <- 30L
# W <- matrix(0, S, S)
# for (i in 1:(S - 1)) W[i, i + 1] <- W[i + 1, i] <- 1
# df <- data.frame(region = factor(seq_len(S)))
# df$x <- as.integer(df$region) / 10 + rnorm(S, 0, 0.3)
# df$y <- rbinom(S, 20, plogis(-0.4 + 0.5 * df$x))
# 
# ckpt <- tempfile(fileext = ".ckpt")
# fit <- tulpa(y ~ x + spatial(region), data = df, family = "binomial",
#              n_trials = rep(20L, S),
#              spatial = spatial_car(W, level = "obs"),
#              mode = "laplace",
#              control = list(checkpoint = list(path = ckpt, resume = FALSE)))
# coef(fit)

## ----size---------------------------------------------------------------------
# file.exists(ckpt) && file.info(ckpt)$size > 0

## ----resume-------------------------------------------------------------------
# fit2 <- tulpa(y ~ x + spatial(region), data = df, family = "binomial",
#               n_trials = rep(20L, S),
#               spatial = spatial_car(W, level = "obs"),
#               mode = "laplace",
#               control = list(checkpoint = list(path = ckpt, resume = TRUE)))
# all.equal(coef(fit), coef(fit2))

## ----cleanup, include = FALSE-------------------------------------------------
# unlink(ckpt)

