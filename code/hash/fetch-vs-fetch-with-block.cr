require "benchmark"
puts Crystal::DESCRIPTION

HASH    = {:writing => :fast_ruby}
DEFAULT = "fast ruby"

Benchmark.ips do |x|
  x.report("Hash#fetch + const") { HASH.fetch(:writing, DEFAULT) }
  x.report("Hash#fetch + block") { HASH.fetch(:writing) { "fast ruby" } }
  x.report("Hash#fetch + arg") { HASH.fetch(:writing, "fast ruby") }
end
