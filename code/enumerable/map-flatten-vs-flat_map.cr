require "benchmark"
puts Crystal::DESCRIPTION

ARRAY = (1..100).to_a

def slow_flatten
  ARRAY.map { |e| [e, e] }.flatten
end

def fast
  ARRAY.flat_map { |e| [e, e] }
end

Benchmark.ips do |x|
  x.report("Array#map.flatten") { slow_flatten }
  x.report("Array#flat_map") { fast }
end
