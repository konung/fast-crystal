require "benchmark"
puts Crystal::DESCRIPTION

ENUM = (1..100).to_a

alias Hashie = Hash(String | Symbol, String | Int32)
ORIGINAL_HASH = Hashie{"foo" => "bar"}

def fast
  ENUM.reduce([] of Hashie) do |accumulator, element|
    accumulator << (Hashie{:bar => element}.merge!(ORIGINAL_HASH) { |_key, left, _right| left })
  end
end

def slow
  ENUM.reduce([] of Hashie) do |accumulator, element|
    accumulator << ORIGINAL_HASH.merge(Hashie{:bar => element})
  end
end

def slow_dup
  ENUM.reduce([] of Hashie) do |accumulator, element|
    accumulator << ORIGINAL_HASH.dup.merge!(Hashie{:bar => element})
  end
end

Benchmark.ips do |x|
  x.report("{}#merge!(Hash) do end") { fast }
  x.report("Hash#merge({})") { slow }
  x.report("Hash#dup#merge!({})") { slow_dup }
end
