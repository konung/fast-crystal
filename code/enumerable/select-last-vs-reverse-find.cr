require "benchmark"
puts Crystal::DESCRIPTION

ARRAY = (1..100).to_a

def fast
  ARRAY.reverse.find { |x| (x % 10).zero? }
end

def slow
  ARRAY.select { |x| (x % 10).zero? }.last?
end

Benchmark.ips do |x|
  x.report("Enumerable#reverse.detect") { fast }
  x.report("Enumerable#select.last") { slow }
end
