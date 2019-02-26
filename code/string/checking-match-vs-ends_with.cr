require "benchmark"
puts Crystal::DESCRIPTION

SLUG = "some_kind_of_root_url"

def slower
  SLUG =~ /_(path|url)$/
end

def slow
  SLUG.match(/_(path|url)$/) != nil
end

def fast
   SLUG.ends_with?("_path") || SLUG.ends_with?("_url")
end

Benchmark.ips do |x|
  x.report("String#=~") { slower }
  x.report("String#match") { slow }
  x.report("String#ends_with?") { fast }
end
