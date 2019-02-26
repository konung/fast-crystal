require "benchmark"
puts Crystal::DESCRIPTION

ARRAY = (1..1000).to_a

def fast
  ARRAY.reduce(&.+)
end

def slow
  ARRAY.reduce { |a, i| a + i }
end

Benchmark.ips do |x|
  x.report("reduce to_proc") { fast }
  x.report("reduce block") { slow }
end
