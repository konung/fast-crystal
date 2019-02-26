require "benchmark"
puts Crystal::DESCRIPTION

# 2 + 1 = 3 object
def slow_plus
  "foo" + "bar"
end

def fast_interpolation
  "#{"foo"}#{"bar"}"
end

Benchmark.ips do |x|
  x.report("String#+") { slow_plus }
  x.report("{\"foo\"}{\"bar\"}") { fast_interpolation }
end
