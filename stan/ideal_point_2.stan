// ideal point model
// identification:
// - xi ~ hierarchical
// - except 2 fixed senators
data {
  // number of individuals
  int N;
  // number of items
  int K;
  // observed votes
  int<lower = 0, upper = N * K> Y_obs;
  int y_idx_leg[Y_obs];
  int y_idx_vote[Y_obs];
  int y[Y_obs];
  // priors
  // on items
  real alpha_loc;
  real<lower = 0.> alpha_scale;
  real beta_loc;
  real<lower = 0.> beta_scale;
  real beta_skew;
  // on legislators
  int N_xi_obs;
  int idx_xi_obs[N_xi_obs];
  vector[N_xi_obs] xi_obs;
  int N_xi_param;
  int idx_xi_param[N_xi_param];
}
parameters {
  // item difficulties
  vector[K] alpha;
  // item discrimination
  vector[K] beta;
  // unknown ideal points
  vector[N_xi_param] xi_param;
  // hyperpriors
  real<lower = 0.> tau;
  real<lower = 0.> zeta;
}
transformed parameters {
  // create xi from observed and parameter ideal points
  vector[Y_obs] mu;
  vector[N] xi;
  xi[idx_xi_param] = xi_param;
  xi[idx_xi_obs] = xi_obs;
  for (i in 1:Y_obs) {
    mu[i] = alpha[y_idx_vote[i]] + beta[y_idx_vote[i]] * xi[y_idx_leg[i]];
  }
}
model {
  alpha ~ normal(alpha_loc, alpha_scale);
  beta ~ skew_normal(beta_loc, beta_scale, beta_skew);
  // soft center ideal points
  // in transformed block enforce hard-centering
  xi_param ~ normal(zeta, tau);
  zeta ~ normal(0., 10.);
  tau ~ cauchy(0., 5.);
  y ~ bernoulli_logit(mu);
}
generated quantities {
  vector[Y_obs] log_lik;
  for (i in 1:Y_obs) {
    log_lik[i] = bernoulli_logit_lpmf(y[i] | mu[i]);
  }
}
