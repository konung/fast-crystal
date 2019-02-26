require "benchmark"
puts Crystal::DESCRIPTION

def fast
  return "Not found" unless "foo".match(/boo/)
end

def slow
  return "Not found" unless "foo" =~ /boo/
end

def slower
  return "Not found" unless /boo/ === "foo"
end

Benchmark.ips do |x|
  x.report("String#=~") { slow }
  x.report("Regexp#===") { slower }
  x.report("String#match") { fast }
end
