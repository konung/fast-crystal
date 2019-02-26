require "benchmark"
puts Crystal::DESCRIPTION

STRING = "2018-03-21T11:26:50Z"

def fast
  Time.parse_iso8601(STRING)
end

def slow
  Time.parse(STRING, "%FT%TZ", Time::Location.load("Europe/London"))
end

Benchmark.ips do |x|
  x.report("Time.parse_iso8601") { fast }
  x.report("Time.parse") { slow }
end
