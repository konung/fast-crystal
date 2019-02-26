require "benchmark"
puts Crystal::DESCRIPTION

HASH_SYMBOLS = {:cool => "ruby", :fast => "crystal"}
HASH_STRINGS = {"cool" => "ruby", "fast" => "crystal"}

def bracket_with_symbol
  HASH_SYMBOLS[:fast]
end

def fetch_with_symbol
  HASH_SYMBOLS.fetch(:fast, nil)
end

def dig_with_symbol
  HASH_SYMBOLS.dig(:fast)
end

def bracket_with_string
  HASH_STRINGS["fast"]
end

def fetch_with_string
  HASH_STRINGS.fetch("fast", nil)
end

def dig_with_string
  HASH_STRINGS.dig("fast")
end

Benchmark.ips do |x|
  x.report("Hash#[], symbol") { bracket_with_symbol }
  x.report("Hash#fetch, symbol") { fetch_with_symbol }
  x.report("Hash#dig, symbol") { bracket_with_symbol }
  x.report("Hash#[], string") { bracket_with_string }
  x.report("Hash#fetch, string") { fetch_with_string }
  x.report("Hash#dig, string") { bracket_with_string }
end
