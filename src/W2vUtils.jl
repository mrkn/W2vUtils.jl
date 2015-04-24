module W2vUtils

  export
  W2vData,
  nwords,
  projdim,
  vocabulary,
  wordindex,
  projection,
  distance,
  nearest_words,
  analogy,
  load

  include("common.jl")
  include("w2v_data.jl")

end # module
