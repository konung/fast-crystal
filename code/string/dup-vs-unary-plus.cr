require "benchmark"
puts Crystal::DESCRIPTION

def fast
  "crystal" + ""
end

def slow
  "crystal".dup
end

Benchmark.ips do |x|
  x.report("String#+@") { fast }
  x.report("String#dup") { slow }
  x.compare!
end
