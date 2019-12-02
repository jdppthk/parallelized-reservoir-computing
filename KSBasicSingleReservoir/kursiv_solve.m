function uu = kursiv_solve(init, ModelParams)


N = ModelParams.N;
d = ModelParams.d;
x = d*(-N/2+1:N/2)'/N;
u = transpose(init);
v = fft(u);
h = ModelParams.tau; 
k = [0:N/2-1 0 -N/2+1:-1]'*(2*pi/d); 
L = k.^2 - k.^4; 
E = exp(h*L); E2 = exp(h*L/2);
M = 16; 
r = exp(1i*pi*((1:M)-.5)/M); 

LR = h*L(:,ones(M,1)) + r(ones(N,1),:);


Q = h*real(mean( (exp(LR/2)-1)./LR ,2));
f1 = h*real(mean( (-4-LR+exp(LR).*(4-3*LR+LR.^2))./LR.^3 ,2));
f2 = h*real(mean( (2+LR+exp(LR).*(-2+LR))./LR.^3 ,2));
f3 = h*real(mean( (-4-3*LR-LR.^2+exp(LR).*(4-LR))./LR.^3 ,2));
nmax = ModelParams.nstep;
g = -0.5i*k;

vv = zeros(N, nmax);

vv(:,1) = v;

for n = 1:nmax
t = n*h;
Nv = g.*fft(real(ifft(v)).^2);
a = E2.*v + Q.*Nv;
Na = g.*fft(real(ifft(a)).^2);
b = E2.*v + Q.*Na;
Nb = g.*fft(real(ifft(b)).^2);
c = E2.*a + Q.*(2*Nb-Nv);
Nc = g.*fft(real(ifft(c)).^2);
v = E.*v + Nv.*f1 + 2*(Na+Nb).*f2 + Nc.*f3;
vv(:,n) = v;
end

uu = transpose(real(ifft(vv)));
