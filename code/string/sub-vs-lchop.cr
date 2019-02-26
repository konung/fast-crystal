require "benchmark"
puts Crystal::DESCRIPTION

SLUG = "YourSubclassType"

def fast
  SLUG.lchop("Your")
end

def slow
  SLUG.sub(/\AYour/, "")
end

raise Exception.new unless (fast == slow)

Benchmark.ips do |x|
  x.report("String#lchop") { fast }
  x.report("String#sub") { slow }
end
