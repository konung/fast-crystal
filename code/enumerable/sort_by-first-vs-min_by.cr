require "benchmark"
puts Crystal::DESCRIPTION

ARRAY = (1..100).to_a

def fast
  ARRAY.min_by { |x| x.succ }
end

def slow
  ARRAY.sort_by { |x| x.succ }.first
end

Benchmark.ips do |x|
  x.report("Enumerable#min_by") { fast }
  x.report("Enumerable#sort_by...first") { slow }
end
