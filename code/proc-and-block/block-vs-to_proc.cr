require "benchmark"
puts Crystal::DESCRIPTION

RANGE = (1..100)

def slow
  RANGE.map { |i| i.to_s }
end

def fast
  RANGE.map(&.to_s)
end

Benchmark.ips do |x|
  x.report("Block .map{|i| i.some_method}")  { slow }
  x.report("Shortcut .map(&.some_method)") { fast }
end
