require "benchmark"
puts Crystal::DESCRIPTION

RANGE = ("a".."zzz")
HASH  = RANGE.to_a.shuffle.zip(RANGE.to_a).to_h
KEY   = "zz"

def key_fast
  HASH.has_key? KEY
end

def key_slow
  HASH.keys.includes? KEY
end

Benchmark.ips do |x|
  x.report("Hash#keys.includes?") { key_slow }
  x.report("Hash#has_key?") { key_fast }
end
