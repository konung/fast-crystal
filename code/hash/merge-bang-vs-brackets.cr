require "benchmark"
puts Crystal::DESCRIPTION

ENUM = (1..100)

def slow
  hsh = {} of Int32 => Int32
  ENUM.each_with_object(hsh) do |e, h|
    h.merge!({e => e})
  end
end

def fast
  hsh = {} of Int32 => Int32
  ENUM.each_with_object(hsh) do |e, h|
    h[e] = e
  end
end

Benchmark.ips do |x|
  x.report("Hash#merge!") { slow }
  x.report("Hash#[]=") { fast }
end
