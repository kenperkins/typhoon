merge = (a, b) ->
  o = {}
  o[k] = v for k, v of a
  o[k] = v for k, v of b
  o

exports.merge = merge
