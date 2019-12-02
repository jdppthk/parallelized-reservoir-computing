function w_out = fit(params, states, data)

beta = params.beta;

idenmat = beta*speye(params.N);

w_out = data*transpose(states)*pinv(states*transpose(states)+idenmat);
