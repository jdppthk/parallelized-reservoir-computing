function prediction = predict(w,w_out,x,w_in,pl,chunk_size,frontWkrIdx, rearWkrIdx,N, locality)

prediction = zeros(chunk_size,pl);

for i=1:pl
    x_augment = x;
    x_augment(2:2:N) = x_augment(2:2:N).^2;
    out = (w_out)*x_augment;
    labBarrier;
    rear_out = labSendReceive(frontWkrIdx ,rearWkrIdx, out(end-locality+1:end));
    front_out = labSendReceive(rearWkrIdx, frontWkrIdx, out(1:locality));
    feedback = vertcat(rear_out, out, front_out);
    x = tanh(w*x + w_in*feedback); 
    prediction(:,i) = out;
end