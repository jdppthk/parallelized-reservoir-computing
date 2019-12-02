function states = reservoir_layer(A, win, input, resparams)

states = zeros(resparams.N, resparams.train_length);
x = zeros(resparams.N,1);


for i = 1:resparams.discard_length
    x = tanh(A*x + win*input(:,i));
end

states(:,1) = x;

for i = 1:resparams.train_length-1
    states(:,i+1) = tanh(A*states(:,i) + win*input(:,resparams.discard_length + i));
end
