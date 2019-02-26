require "benchmark"
puts Crystal::DESCRIPTION

ENUM = (1..100)

def slow
  ENUM.reduce({} of Int32 => Int32) do |h, e|
    h.merge({e => e})
  end
end

def fast
  ENUM.reduce({} of Int32 => Int32) do |h, e|
    h.merge!({e => e})
  end
end

Benchmark.ips do |x|
  x.report("Hash#merge") { slow }
  x.report("Hash#merge!") { fast }
end
