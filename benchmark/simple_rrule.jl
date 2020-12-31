using XConv, LinearAlgebra, PyPlot, Flux, BenchmarkTools
BLAS.set_num_threads(2)

nx = 128
ny = 128
batchsize= 32
n_in = 4
n_out = 4
stride = 1
n_bench = 5
nw   = 3;

X = randn(Float32, nx, ny, n_in, batchsize);
Y0 = randn(Float32, nx, ny, n_out, batchsize);

# Flux network
C = Conv((nw, nw), n_in=>n_out, identity;pad=1, stride=stride)
p = Flux.params(C)

XConv.initXConv(0, "TrueGrad")
g1 = gradient(()->.5*norm(C(X)- Y0), p).grads[p[1]]

XConv.initXConv(2^3, "EVGrad")
g2 = gradient(()->.5*norm(C(X) - Y0), p).grads[p[1]]

XConv.initXConv(0, "TrueGrad")
@btime g1 = gradient(()->.5f0*norm(C(X)- Y0), p);

XConv.initXConv(2^3, "EVGrad")
@btime g2 = gradient(()->.5f0*norm(C(X)- Y0), p);

plot(vec(g2));plot(vec(g1))