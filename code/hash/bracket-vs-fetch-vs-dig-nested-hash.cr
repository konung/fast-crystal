require "benchmark"
puts Crystal::DESCRIPTION

h = {:a => {:b => {:c => {:d => {:e => "foo"}}}}}

alias HS = Hash(Symbol, String)

Benchmark.ips do |x|
  x.report "Hash#dig?" do
    h.dig?(:a, :b, :c, :d, :e)
  end

  x.report "Hash#dig" do
    h.dig(:a, :b, :c, :d, :e)
  end

  x.report "Hash#[]" do
    h[:a][:b][:c][:d][:e]
  end

  x.report "Hash#[] &&" do
    h[:a] && h[:a][:b] && h[:a][:b][:c] && h[:a][:b][:c][:d] && h[:a][:b][:c][:d][:e]
  end

  # Both of these approaches break on 3rd level of nesting with error > no overload matches 'String#[]' with type Symbol
  # or undefined method 'fetch' for String

  # x.report "Hash#[] ||" do
  #   (((((((h[:a] || HS.new)[:b]) || HS.new)[:c]) || HS.new)[:d]) || HS.new)[:e]
  # end

  # x.report "Hash#fetch fallback" do
  #   h.fetch(:a, HS.new).fetch(:b, HS.new).fetch(:c, HS.new).fetch(:d, HS.new).fetch(:e, nil)
  # end
end
