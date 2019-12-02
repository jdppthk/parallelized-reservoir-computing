function [x, wout, A, win] = train_reservoir(resparams, data, labindex, jobid, locality, chunk_size)

[num_inputs,~] = size(data);

A = generate_reservoir(resparams.N, resparams.radius, resparams.degree, labindex, jobid);
q = resparams.N/num_inputs;
win = zeros(resparams.N, num_inputs);
for i=1:num_inputs
    rng(i)
    ip = (-1 + 2*rand(q,1));
    win((i-1)*q+1:i*q,i) = ip;
end

states = reservoir_layer(A, win, data, resparams);

states(2:2:resparams.N,:) = states(2:2:resparams.N,:).^2;

wout = fit(resparams, states, data(locality+1:locality+chunk_size,resparams.discard_length + 1:resparams.discard_length + resparams.train_length));

x = states(:,end);
