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

## ----load, message = FALSE----------------------------------------------------
# library(tulpa)

## ----prior-normal-------------------------------------------------------------
# prior_normal(0, 2.5)
# prior_normal(0, 1)

## ----prior-scale--------------------------------------------------------------
# prior_half_normal(1)
# prior_half_cauchy(2.5)
# prior_gamma(2, 0.1)
# prior_exponential(1)

## ----prior-scale-means--------------------------------------------------------
# c(half_normal_mean = prior_half_normal(1)$sd * sqrt(2 / pi),
#   exponential_mean = 1 / prior_exponential(1)$rate,
#   gamma_mean       = prior_gamma(2, 0.1)$shape / prior_gamma(2, 0.1)$rate)

## ----prior-pc-----------------------------------------------------------------
# prior_pc(U = 1, alpha = 0.01)
# prior_pc(U = 0.5, alpha = 0.05)

## ----pc-pp-data---------------------------------------------------------------
# bin <- tulpa_family("binomial",
#   function(eta, params, n_obs, ...) rbinom(n_obs, 1, plogis(eta[[1]])))
# gdat <- data.frame(y = 0, x = rnorm(200), g = factor(rep(1:20, each = 10)))

## ----pc-pp--------------------------------------------------------------------
# group_spread <- function(pp) {
#   vapply(seq_along(pp$y), function(d) {
#     p <- plogis(pp$linpred[[d]][[1]])
#     sd(tapply(p, gdat$g, mean))
#   }, numeric(1))
# }
# pp_tight <- prior_predict(y ~ x + (1 | g), family = bin, data = gdat,
#   n_draws = 200, priors = tulpa_priors(sigma = prior_pc(1, 0.01)), seed = 7)
# pp_wide  <- prior_predict(y ~ x + (1 | g), family = bin, data = gdat,
#   n_draws = 200, priors = tulpa_priors(sigma = prior_pc(5, 0.01)), seed = 7)
# rbind(tight = quantile(group_spread(pp_tight), c(0.5, 0.9, 0.99)),
#       wide  = quantile(group_spread(pp_wide),  c(0.5, 0.9, 0.99)))

## ----prior-beta---------------------------------------------------------------
# prior_beta(1, 1)
# prior_beta(2, 2)
# prior_beta(5, 2)

## ----defaults-----------------------------------------------------------------
# tulpa_priors()

## ----defaults-annotated-------------------------------------------------------
# priors_default()

## ----defaults-custom----------------------------------------------------------
# tulpa_priors(
#   beta  = prior_normal(0, 1),
#   sigma = prior_pc(U = 0.5, alpha = 0.01)
# )

## ----fe-sim-------------------------------------------------------------------
# n  <- 25
# x  <- rnorm(n)
# y  <- 0.5 + 1.2 * x + rnorm(n, sd = 1.5)
# df <- data.frame(y = y, x = x)

## ----fe-weak------------------------------------------------------------------
# fit_weak <- tulpa(y ~ x, data = df, family = "gaussian",
#                   mode = "laplace", phi = 1.5^2)
# coef(fit_weak)

## ----fe-tight-----------------------------------------------------------------
# fit_tight <- tulpa(y ~ x, data = df, family = "gaussian",
#                    mode = "laplace", phi = 1.5^2,
#                    beta_prior = list(mean = c(0, 0), sd = c(10, 0.2)))
# coef(fit_tight)

## ----fe-compare---------------------------------------------------------------
# data.frame(
#   term  = names(coef(fit_weak)),
#   weak  = round(coef(fit_weak), 3),
#   tight = round(coef(fit_tight), 3)
# )

## ----fe-confint---------------------------------------------------------------
# confint(fit_weak)["x", ]
# confint(fit_tight)["x", ]

## ----pp-family----------------------------------------------------------------
# pois <- tulpa_family(
#   name = "poisson",
#   simulate_fn = function(eta, params, n_obs, ...) rpois(n_obs, exp(eta[[1]]))
# )

## ----pp-data------------------------------------------------------------------
# dat <- data.frame(y = rep(0, 60), x = rnorm(60))

## ----pp-vague-----------------------------------------------------------------
# pp_vague <- prior_predict(
#   y ~ x, family = pois, data = dat, n_draws = 200,
#   priors = tulpa_priors(beta = prior_normal(0, 5)), seed = 1
# )
# pp_vague

## ----pp-vague-range-----------------------------------------------------------
# max(vapply(pp_vague$y, max, numeric(1)))

## ----pp-sensible--------------------------------------------------------------
# pp_ok <- prior_predict(
#   y ~ x, family = pois, data = dat, n_draws = 200,
#   priors = tulpa_priors(beta = prior_normal(0, 1)), seed = 1
# )
# max(vapply(pp_ok$y, max, numeric(1)))

## ----pp-quantiles-------------------------------------------------------------
# vague_all <- unlist(pp_vague$y)
# ok_all    <- unlist(pp_ok$y)
# rbind(
#   vague    = quantile(vague_all, c(0.5, 0.9, 0.99)),
#   sensible = quantile(ok_all,    c(0.5, 0.9, 0.99))
# )

## ----pp-plot, fig.alt = "Prior predictive draws under a vague Normal(0, 5) prior"----
# pp_capped <- pp_vague
# pp_capped$y <- lapply(pp_vague$y, function(yi) pmin(yi, 200))
# plot(pp_capped, max_draws = 40)

## ----pp-plot-ok, fig.alt = "Prior predictive draws under a sensible Normal(0, 1) prior"----
# plot(pp_ok, max_draws = 40)

## ----pc-pp-plot, message = FALSE, eval = has_ggplot && EVAL_FITS, fig.alt = "Between-group spread under two PC priors on sigma"----
# library(ggplot2)
# sp <- rbind(
#   data.frame(prior = "tight (U=1)", spread = group_spread(pp_tight)),
#   data.frame(prior = "wide (U=5)",  spread = group_spread(pp_wide)))
# ggplot(sp, aes(spread, fill = prior)) +
#   geom_density(alpha = 0.5) +
#   labs(x = "SD of group-mean probabilities", y = "Prior predictive density") +
#   theme(panel.background = element_rect(fill = "transparent"),
#         plot.background  = element_rect(fill = "transparent"))

