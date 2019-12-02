 function jobid = parallel_reservoir_benchmarking_pv(request_pool_size)
 
 index_file = matfile('/lustre/jpathak/F10/testing_ic_indexes.mat');
 %index_file = matfile('F8/testing_ic_indexes.mat');

 full_pred_marker_array = index_file.testing_ic_indexes;
 
 num_indices = length(full_pred_marker_array);
 
 num_divided_jobs = 10;
 
 indices_per_job = num_indices/num_divided_jobs;
 
 for index_iter = 1:1
    tic;
    partial_pred_marker_array = full_pred_marker_array((index_iter-1)*indices_per_job + 1:index_iter*indices_per_job);

    pred_marker_array = Composite(request_pool_size);
    which_index_iter = Composite(request_pool_size);
 
    for i=1:length(pred_marker_array)
        pred_marker_array{i} = partial_pred_marker_array;
        which_index_iter{i} = index_iter;
    end
        
    spmd(request_pool_size)
        
        jobid = 1;
 
        m = matfile('/lustre/jpathak/F10/train_input_sequence.mat'); 
%        m = matfile('F8/train_input_sequence.mat');
        
%        tf = matfile('F8/test_input_sequence.mat');
        tf = matfile('/lustre/jpathak/F10/test_input_sequence.mat');
        
        sigma = 0.1;  %% simple scaling of data by a scalar

        [len, num_inputs] = size(m, 'train_input_sequence');

        num_workers = numlabs; %numlabs is a matlab func that returns the number of workers allocated. equal to request_pool_size

        chunk_size = num_inputs/numlabs; %%%%%%%%%% MUST DIVIDE (each reservoir responsible for this chunk)

        l = labindex; % labindex is a matlab function that returns the worker index

        chunk_begin = chunk_size*(l-1)+1;

        chunk_end = chunk_size*l;

        locality = 2; % there are restrictions on the allowed range of this parameter. check documentation
   
        rear_overlap = indexing_function_rear(chunk_begin, locality, num_inputs);  %spatial overlap on the one side
        
        forward_overlap = indexing_function_forward(chunk_end, locality, num_inputs);  %spatial overlap on the other side

        overlap_size = length(rear_overlap) + length(forward_overlap); 

        approx_reservoir_size = 5000;  % number of nodes in an individual reservoir network (approximate upto the next whole number divisible by number of inputs)

        avg_degree = 3; %average connection degree

        resparams.sparsity = avg_degree/approx_reservoir_size;
        
        resparams.degree = avg_degree;
        
        nodes_per_input = round(approx_reservoir_size/(chunk_size+overlap_size));

        resparams.N = nodes_per_input*(chunk_size+overlap_size); % exact number of nodes in the network

        resparams.train_length = 79000;  %number of time steps used for training

        resparams.discard_length = 1000;  %number of time steps used to discard transient (generously chosen)

        resparams.predict_length = 2999;  %number of steps to be predicted

        resparams.radius = 0.6; % spectral radius of the reservoir
        
        resparams.beta = 0.0001; % ridge regression regularization parameter
        
        u = zeros(len, chunk_size + overlap_size); % this will be populated by the input data to the reservoir

        u(:,1:locality) = m.train_input_sequence(1:end, rear_overlap);

        u(:,locality+1:locality+chunk_size) = m.train_input_sequence(1:end, chunk_begin:chunk_end);

        u(:,locality+chunk_size+1:2*locality+chunk_size) = m.train_input_sequence(1:end,forward_overlap);

        u = sigma*u;
        
        test_u = zeros(20000, chunk_size + overlap_size); % this will be populated by the input data to the reservoir

        test_u(:,1:locality) = tf.test_input_sequence(1:end, rear_overlap);

        test_u(:,locality+1:locality+chunk_size) = tf.test_input_sequence(1:end, chunk_begin:chunk_end);

        test_u(:,locality+chunk_size+1:2*locality+chunk_size) = tf.test_input_sequence(1:end,forward_overlap);

        test_u = sigma*test_u;
        
        pred_collect = res_train_predict(transpose(u), transpose(test_u), resparams, jobid, locality, chunk_size, pred_marker_array);

        collated_prediction = gcat(pred_collect,1,1);
        
    end

    runtime = toc;
    approx_reservoir_size = approx_reservoir_size{1};
    locality = locality{1};
    num_workers = num_workers{1};
    jobid = jobid{1};
    data_file = m{1};
    test_file = tf{1};
    resparams = resparams{1};
    sigma = sigma{1};
    num_inputs = num_inputs{1};
    pred_collect = collated_prediction{1};
    pred_marker_array = pred_marker_array{1};
    num_preds = length(pred_marker_array);
    diff = zeros(num_inputs, num_preds*resparams.predict_length);
    trajectories_true = zeros(num_inputs, num_preds*resparams.predict_length);
    for pred_iter = 1:num_preds
        prediction_marker = pred_marker_array(pred_iter);
        trajectories_true(:, (pred_iter-1)*resparams.predict_length + 1: pred_iter*resparams.predict_length) = transpose(sigma*test_file.test_input_sequence(prediction_marker+32 + 1:prediction_marker+32 + resparams.predict_length,:));
        diff(:, (pred_iter-1)*resparams.predict_length+1:pred_iter*resparams.predict_length) ...
            = transpose(sigma*test_file.test_input_sequence(prediction_marker+32 +1:prediction_marker + 32 + resparams.predict_length,:))...
        -  pred_collect(:,(pred_iter-1)*resparams.predict_length+1:pred_iter*resparams.predict_length);
        error = sqrt(mean(diff.^2, 1));
    end

    which_index_iter = which_index_iter{1};
%    filename = ['J40F8lorenz-' num2str(approx_reservoir_size) '-locality' num2str(locality) '-numlabs' num2str(num_workers) '-jobid' num2str(jobid) '-index_iter', num2str(which_index_iter)];
    filename = ['/lustre/jpathak/F10/J40F10lorenz-' num2str(approx_reservoir_size) '-locality' num2str(locality) '-numlabs' num2str(num_workers) '-jobid' num2str(jobid) '-index_iter', num2str(which_index_iter)];
    
    save(filename, 'pred_collect', 'error', 'diff', 'pred_marker_array', 'trajectories_true');
    
 end

 



    



