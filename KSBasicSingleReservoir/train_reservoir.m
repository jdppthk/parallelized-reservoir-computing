function [x, wout, A, win] = train_reservoir(resparams, data)

A = generate_reservoir(resparams.N, resparams.radius, resparams.degree);
q = resparams.N/resparams.num_inputs;
win = zeros(resparams.N, resparams.num_inputs);
for i=1:resparams.num_inputs
    rng(i)
    ip = resparams.sigma*(-1 + 2*rand(q,1));
    win((i-1)*q+1:i*q,i) = ip;
end
%win = resparams.sigma*(-1 + 2*rand(resparams.N, resparams.num_inputs));

states = reservoir_layer(A, win, data, resparams);

wout = train(resparams, states, data);

x = states(:,end);
