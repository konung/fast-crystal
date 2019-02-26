require "benchmark"
puts Crystal::DESCRIPTION

RANGE = ("a".."zzz")
HASH  = RANGE.to_a.shuffle.zip(RANGE.to_a).to_h

def fast
  HASH.to_a.sort_by { |k, _v| k }.to_h
end

def slow
  HASH.to_a.sort.to_h
end

Benchmark.ips do |x|
  x.report("sort_by + to_h") { fast }
  x.report("sort + to_h") { slow }
end
