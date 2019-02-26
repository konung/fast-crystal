require "benchmark"
puts Crystal::DESCRIPTION

ARRAY = (1..100).to_a

def slow
  ARRAY.shuffle.first
end

def fast
  ARRAY.sample
end

Benchmark.ips do |x|
  x.report("Array#sample") { fast }
  x.report("Array#shuffle.first") { slow }
end
