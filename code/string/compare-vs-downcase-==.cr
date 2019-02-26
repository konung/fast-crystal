require "benchmark"
puts Crystal::DESCRIPTION

SLUG = "ABCD"

def slow
  SLUG.downcase == "abcd"
end

def fast
  SLUG.compare("abcd", true) == 0
end

Benchmark.ips do |x|
  x.report("String#downcase + ==") { slow }
  x.report("String#compare") { fast }
end
