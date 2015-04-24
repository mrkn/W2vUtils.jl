const MAX_WORD_LENGTH = 50

function read_word(stream)
  buffer = IOBuffer(MAX_WORD_LENGTH)
  while !eof(stream)
    ch = read(stream, Uint8)
    if ch == 0x20
      break
    elseif ch != 0x0A
      write(buffer, ch)
    end
  end
  return takebuf_string(buffer)
end

function read_vector(stream, dim)
  res = Array(Float64, dim)
  for i = 1:dim
    res[i] = float64(read(stream, Float32))
  end
  return res / norm(res)
end
