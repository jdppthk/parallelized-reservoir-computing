function states = reservoir_layer(A, win, input, resparams)

states = zeros(resparams.N, resparams.train_length);

for i = 1:resparams.train_length-1
    states(:,i+1) = tanh(A*states(:,i) + win*input(:,i));
end
    

