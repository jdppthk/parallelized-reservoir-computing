function pred_collect = res_train_predict(in, test_in, resparams, jobid, locality, chunk_size, pred_marker_array, sync_length)


[x, w_out, w, w_in] = train_reservoir(resparams, in, labindex, jobid, locality, chunk_size);

frontWkrIdx = mod(labindex, numlabs) + 1; % one worker to the front
rearWkrIdx = mod(labindex - 2, numlabs) + 1; % one worker to the rear

num_preds = length(pred_marker_array);

pred_collect = zeros(chunk_size,num_preds*resparams.predict_length);

for pred_iter = 1:num_preds

    prediction_marker = pred_marker_array(pred_iter);
        
    x = synchronize(w,x,w_in,test_in,prediction_marker,sync_length);

    prediction = predict(w,w_out,x,w_in,resparams.predict_length,chunk_size, frontWkrIdx, rearWkrIdx,resparams.N, locality);

    pred_collect(:,(pred_iter-1)*resparams.predict_length+1:pred_iter*resparams.predict_length) = prediction;
    
end

