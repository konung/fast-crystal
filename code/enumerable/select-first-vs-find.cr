require "benchmark"
puts Crystal::DESCRIPTION

ARRAY = (1..100).to_a

def slow
  ARRAY.select { |x| x == 15 }.first?
end

def fast
  ARRAY.find { |x| x == 15 }
end

Benchmark.ips(20) do |x|
  x.report("Enumerable#select.first") { slow }
  x.report("Enumerable#find") { fast }
end
