function A = generate_reservoir(size, radius, degree, labindex, jobid)

rng(labindex+jobid)

sparsity = degree/size;

A = sprand(size, size, sparsity);

e = max(abs(eigs(A)));

A = (A./e).*radius;
