type W2vData
  vocabulary::Array{UTF8String}
  projection::DenseMatrix{Float64}
end

nwords(wv::W2vData)  = size(wv.projection, 1)
projdim(wv::W2vData) = size(wv.projection, 2)

vocabulary(wv::W2vData) = wv.vocabulary
projection(wv::W2vData) = wv.projection

wordindex(wv::W2vData, word::UTF8String) = findfirst(vocabulary(wv), word)
wordindices(wv::W2vData, words::Array{UTF8String}) = [wordindex(wv, w) for w in words]

function projection(wv::W2vData, word::UTF8String)
  wi = wordindex(wv, word)
  projection(wv)[wi, :]
end

function projection(wv::W2vData, words::Array{UTF8String})
  wis = wordindices(wv, words)
  projection(wv)[wis, :]
end

function distance(wv::W2vData, word1::UTF8String, word2::UTF8String)
  vec1 = projection(wv, word1)
  vec2 = projection(wv, word2)
  sum(vec1 .* vec2)
end

function distance(wv::W2vData, word::UTF8String; n=15)
  wi = wordindex(wv, word)
  wi == 0 && return []

  vec = projection(wv, word)
  bestw = repeat([utf8("")]; inner=[n])
  bestd = -ones(Float64, n)

  for i = 1:nwords(wv)
    i == wi && continue

    w = vocabulary(wv)[i]
    d = sum(vec .* projection(wv)[i, :])

    for j = 1:n
      if d > bestd[j]
        if j < n
          bestd[(j+1):n] = bestd[j:(n-1)]
          bestw[(j+1):n] = bestw[j:(n-1)]
        end
        bestd[j] = d
        bestw[j] = w
        break
      end
    end
  end

  (bestw, bestd)
end

function nearest_words(wv::W2vData, vec::DenseMatrix{Float64}; n=15, reject_words::Array{UTF8String}=[])
  vec /= norm(vec)

  bestw = repeat([utf8("")]; inner=[n])
  bestd = -ones(Float64, n)

  for i = 1:nwords(wv)
    w = vocabulary(wv)[i]
    in(w, reject_words) && continue

    d = sum(vec .* projection(wv)[i, :])

    for j = 1:n
      if d > bestd[j]
        if j < n
          bestd[(j+1):n] = bestd[j:(n-1)]
          bestw[(j+1):n] = bestw[j:(n-1)]
        end
        bestd[j] = d
        bestw[j] = w
        break
      end
    end
  end

  (bestw, bestd)
end

function analogy(wv::W2vData, words::Array{UTF8String}; n=15)
  length(words) < 3 && return ()

  v1 = projection(wv, words[1])
  v2 = projection(wv, words[2])
  v3 = projection(wv, words[3])
  vec = v2 - v1 + v3

  nearest_words(wv, vec; n=n, reject_words=words)
end

function load(filename::String, ::Type{W2vData})
  io = open(filename, "r")
  headline = readline(io)
  (n, dim) = map(integer, split(headline))

  vocabulary = Array(UTF8String, n)
  projection = Array(Float64, n, dim)

  for i = 1:n
    vocabulary[i] = read_word(io)
    projection[i, :] = read_vector(io, dim)
  end

  W2vData(vocabulary, projection)
end
