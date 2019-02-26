require "benchmark"
puts Crystal::DESCRIPTION

ARRAY = (0..100_000_000).to_a

Benchmark.ips do |x|
  x.report("find")    { ARRAY.find    { |number| number > 77_777_777 } }
  x.report("bsearch") { ARRAY.bsearch { |number| number > 77_777_777 } }
end
