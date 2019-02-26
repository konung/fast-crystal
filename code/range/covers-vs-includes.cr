require "benchmark"
puts Crystal::DESCRIPTION


BEGIN_OF_JULY = Time.new(2015, 7, 1)
END_OF_JULY = Time.new(2015, 7, 31)
DAY_IN_JULY = Time.new(2015, 7, 15)

Benchmark.ips do |x|
  x.report("range#covers?") { (BEGIN_OF_JULY..END_OF_JULY).covers? DAY_IN_JULY }
  x.report("range#includes?") { (BEGIN_OF_JULY..END_OF_JULY).includes? DAY_IN_JULY }
  x.report("plain compare") { BEGIN_OF_JULY < DAY_IN_JULY && DAY_IN_JULY < END_OF_JULY }
end

