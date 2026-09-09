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

## ----adjacency----------------------------------------------------------------
# K <- 25
# W <- matrix(0, K, K)
# for (i in 1:K) {
#   j <- if (i < K) i + 1 else 1
#   W[i, j] <- W[j, i] <- 1
# }

## ----truth--------------------------------------------------------------------
# field_true <- as.numeric(scale(sin(2 * pi * (1:K) / K)))
# beta0 <- -0.2
# beta1 <-  0.8

## ----simulate-----------------------------------------------------------------
# n      <- 800
# x      <- rnorm(n)
# region <- sample(1:K, n, replace = TRUE)
# eta    <- beta0 + beta1 * x + field_true[region]
# y      <- rbinom(n, size = 1, prob = plogis(eta))
# ds     <- data.frame(y = y, x = x, region = factor(region))

## ----fit----------------------------------------------------------------------
# fit <- tulpa(y ~ x + spatial(region), data = ds, family = "binomial",
#              spatial = list(type = "icar", adjacency = W),
#              mode = "nested_laplace")
# fit$backend

## ----coef---------------------------------------------------------------------
# coef(fit)

## ----summary------------------------------------------------------------------
# summary(fit)

## ----field-extract------------------------------------------------------------
# w     <- fit$weights / sum(fit$weights)
# nf    <- fit$n_fixed
# field_hat <- vapply(seq_len(K), function(u) sum(w * fit$modes[, nf + u]),
#                     numeric(1))
# round(head(field_hat), 3)

## ----field-plot, fig.alt = "Estimated spatial field per region against the simulated truth, near the identity line"----
# plot(field_true - mean(field_true),
#      field_hat  - mean(field_hat),
#      xlab = "true field (centred)", ylab = "estimated field (centred)",
#      pch = 19, col = "steelblue")
# abline(0, 1, lwd = 2, col = "grey40")

## ----field-cor----------------------------------------------------------------
# cor(field_true, field_hat)

## ----tau----------------------------------------------------------------------
# c(tau_mean = fit$theta_mean,
#   lo = fit$theta_ci_lo, hi = fit$theta_ci_hi)

## ----confint------------------------------------------------------------------
# confint(fit)

## ----intercept-se-------------------------------------------------------------
# summary(fit)["(Intercept)", "std.error"]

## ----predict------------------------------------------------------------------
# nd <- data.frame(x = seq(-2.5, 2.5, length.out = 50))
# pr <- predict(fit, newdata = nd, type = "link", se.fit = TRUE)
# head(pr, 3)

## ----predict-plot, fig.alt = "Predicted logit response across x with a 95 percent credible band"----
# plot(nd$x, pr$fit, type = "n", xlab = "x", ylab = "predicted logit")
# polygon(c(nd$x, rev(nd$x)), c(pr$lower, rev(pr$upper)),
#         col = adjustcolor("steelblue", 0.25), border = NA)
# lines(nd$x, pr$fit, lwd = 2)

## ----compare------------------------------------------------------------------
# m0 <- tulpa(y ~ x, data = ds, family = "binomial", mode = "laplace")
# 
# lse  <- function(z) { m <- max(z); m + log(sum(exp(z - m))) }
# ev_spatial    <- lse(fit$log_marginal)
# ev_nonspatial <- as.numeric(logLik(m0))
# c(nonspatial = ev_nonspatial, spatial = ev_spatial)

## ----compare-diff-------------------------------------------------------------
# ev_spatial - ev_nonspatial

## ----continuous-spec----------------------------------------------------------
# gp_spec <- spatial_gp(~ lon + lat)
# gp_spec$type

## ----spde-fit-----------------------------------------------------------------
# set.seed(20260531)
# n      <- 300
# coords <- data.frame(lon = runif(n), lat = runif(n))
# field  <- 1.4 * (sin(2.5 * coords$lon) + cos(2.5 * coords$lat))
# field  <- field - mean(field)
# xcov   <- rnorm(n)
# y      <- rpois(n, exp(1.0 + 0.5 * xcov + field))
# 
# spde <- spatial_spde(~ lon + lat, data = coords, max_edge = c(0.2, 0.5))
# fit  <- fit_spde(y = y, X = model.matrix(~ xcov), spatial = spde,
#                  family = "poisson", range = 0.4, sigma = 0.9)
# round(fit$beta, 3)

