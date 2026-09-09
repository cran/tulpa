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

## ----sim-trend----------------------------------------------------------------
# T_pts <- 30L
# trend <- as.numeric(scale(sin(2 * pi * seq_len(T_pts) / T_pts)))

## ----sim-binomial-------------------------------------------------------------
# set.seed(42)
# n     <- 900L
# time  <- sample(seq_len(T_pts), n, replace = TRUE)
# x     <- rnorm(n)
# eta   <- -0.2 + 0.9 * x + trend[time]
# y     <- rbinom(n, 1, plogis(eta))
# df    <- data.frame(y = y, x = x, time = time)

## ----fit-binomial-------------------------------------------------------------
# tspec <- temporal_rw1("time")
# fit <- tulpa(y ~ x, data = df, family = "binomial",
#              temporal = tspec, mode = "auto")
# coef(fit)

## ----routing------------------------------------------------------------------
# c(backend = fit$backend, tier = fit$inference_tier)
# fit$selection_reason

## ----summary-binomial---------------------------------------------------------
# summary(fit)

## ----confint-binomial---------------------------------------------------------
# confint(fit)

## ----extract-trend------------------------------------------------------------
# w     <- fit$weights / sum(fit$weights)
# nf    <- fit$n_fixed
# phi_hat <- vapply(seq_len(T_pts),
#                   function(u) sum(w * fit$modes[, nf + u]),
#                   numeric(1))
# round(head(phi_hat), 3)

## ----trend-plot, fig.alt = "Estimated RW1 trend across time points overlaid on the true simulated trend"----
# plot(seq_len(T_pts), trend - mean(trend), type = "l", lwd = 2,
#      xlab = "time point", ylab = "centred temporal effect")
# lines(seq_len(T_pts), phi_hat - mean(phi_hat), col = "darkorange", lwd = 2)
# legend("topright", c("truth", "estimate"),
#        col = c("black", "darkorange"), lwd = 2, bty = "n")

## ----trend-cor----------------------------------------------------------------
# round(cor(phi_hat, trend), 3)

## ----tau-summary--------------------------------------------------------------
# c(mean = fit$theta_mean,
#   lower = fit$theta_ci_lo,
#   upper = fit$theta_ci_hi)

## ----intercept-se-------------------------------------------------------------
# summary(fit)["(Intercept)", c("estimate", "std.error")]

## ----predict-link-------------------------------------------------------------
# nd <- data.frame(x = seq(-2, 2, length.out = 50))
# pr <- predict(fit, newdata = nd, type = "link", se.fit = TRUE)
# round(head(pr, 2), 3)

## ----predict-plot, fig.alt = "Centred link-scale prediction across x with the covariate slope and its credible band"----
# ctr <- pr$fit - mean(pr$fit)
# plot(nd$x, ctr, type = "l", lwd = 2,
#      xlab = "x", ylab = "centred linear predictor")
# band <- (pr$upper - pr$lower) / 2
# polygon(c(nd$x, rev(nd$x)),
#         c(ctr - band, rev(ctr + band)),
#         col = adjustcolor("steelblue", 0.25), border = NA)
# lines(nd$x, ctr, lwd = 2)

## ----fit-notemporal-----------------------------------------------------------
# m_nt <- tulpa(y ~ x, data = df, family = "binomial", mode = "laplace")
# as.numeric(logLik(m_nt))

## ----evidence-----------------------------------------------------------------
# lse <- function(v) { m <- max(v); m + log(sum(exp(v - m))) }
# evidence_temporal <- lse(fit$log_marginal)
# c(no_temporal = as.numeric(logLik(m_nt)), temporal = evidence_temporal)

## ----compare------------------------------------------------------------------
# cmp <- compare_models(no_temporal = m_nt,
#                       temporal = fit,
#                       criterion = "loglik")
# cmp

## ----fit-gaussian-------------------------------------------------------------
# set.seed(7)
# yg  <- -0.2 + 0.9 * x + trend[time] + rnorm(n, sd = 0.5)
# dfg <- data.frame(y = yg, x = x, time = time)
# fitg <- tulpa(y ~ x, data = dfg, family = "gaussian",
#               temporal = tspec, mode = "auto", phi = 0.5)
# coef(fitg)["x"]

## ----rw2----------------------------------------------------------------------
# fit_rw2 <- tulpa(y ~ x, data = df, family = "binomial",
#                  temporal = temporal_rw2("time"), mode = "auto")
# coef(fit_rw2)

## ----ar1-panel, eval = FALSE--------------------------------------------------
# # AR1 temporal trend
# tulpa(y ~ x, data = df, family = "binomial",
#       temporal = temporal_ar1("time"), mode = "auto")
# 
# # Panel: one walk per site, shared smoothness
# tulpa(y ~ x, data = panel_df, family = "binomial",
#       temporal = temporal_rw1("time", group_var = "site"), mode = "auto")
# 
# # Additive space-time
# tulpa(y ~ x + spatial(region), data = st_df, family = "binomial",
#       spatial = list(type = "icar", adjacency = W),
#       temporal = temporal_rw1("time"), mode = "auto")

