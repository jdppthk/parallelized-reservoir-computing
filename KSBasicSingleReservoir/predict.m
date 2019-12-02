function [output,x] = predict(A,win,resparams,x, w_out)

% x_aug = x;
% x_aug(2:2:resparams.N) = x_aug(2:2:resparams.N).^2;
% out = w_out*x_aug;

output = zeros(resparams.num_inputs, resparams.predict_length);


for i = 1:resparams.predict_length
    x_aug = x;
    x_aug(2:2:resparams.N) = x_aug(2:2:resparams.N).^2;
    out = w_out*x_aug;
    output(:,i) = out;
    x = tanh(A*x + win*out);
end
