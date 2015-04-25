using W2vUtils
using MultivariateStats
using Gadfly

wv = load(ARGS[1], W2vData)

(words, dists) = distance(wv, ARGS[2]; n=15)

vecs = W2vUtils.projection(wv, words)

model = fit(PCA, vecs'; maxoutdim=2)

transvecs = transform(model, vecs')

pca_plot = plot(x=transvecs[1, :], y=transvecs[2, :], label=words, Geom.point, Geom.label)
draw(PDF(ARGS[3], 4inch, 3inch), pca_plot)
