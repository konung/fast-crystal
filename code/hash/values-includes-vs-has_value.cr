require "benchmark"
puts Crystal::DESCRIPTION

RANGE = ("a".."zzz")
HASH  = RANGE.to_a.shuffle.zip(RANGE.to_a).to_h
VALUE = "zz"

def value_fast
  HASH.has_value? VALUE
end

def value_slow
  HASH.values.includes? VALUE
end

Benchmark.ips do |x|
  x.report("Hash#values.includes?") { value_slow }
  x.report("Hash#has_value?") { value_fast }
end
