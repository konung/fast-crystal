require "benchmark"
puts Crystal::DESCRIPTION

SLUG = "test_some_kind_of_long_file_name.cr"

def slower
  (SLUG =~ /^test_/) == 0
end

def slow
  SLUG.match(/^test_/) == 0
end

def fast
  SLUG.starts_with?("test_")
end

Benchmark.ips do |x|
  x.report("String#=~") { slower }
  x.report("String#match") { slow }
  x.report("String#start_with?") { fast }
end
