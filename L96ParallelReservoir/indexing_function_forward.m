function forward_overlap = indexing_function_forward(chunk_end, locality, num_inputs)

if chunk_end + locality <= num_inputs
    forward_overlap = chunk_end+1:chunk_end+locality;
elseif chunk_end+locality>num_inputs && chunk_end == num_inputs
    forward_overlap = 1:mod(chunk_end + locality, num_inputs);
elseif chunk_end+locality>num_inputs && chunk_end < num_inputs
    forward_overlap = horzcat(chunk_end+1:num_inputs, 1:mod(chunk_end+locality, num_inputs));
else forward_overlap = -NaN;
end