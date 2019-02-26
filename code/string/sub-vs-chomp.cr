require "benchmark"
puts Crystal::DESCRIPTION

SLUG = "YourSubclassTypes"

def slow
  SLUG.sub(/Types\z/, "")
end

def fast
  SLUG.chomp("Types")
end

raise Exception.new unless (fast == slow)

Benchmark.ips do |x|
  x.report("String#sub") { slow }
  x.report("String#chomp") { fast }
end
