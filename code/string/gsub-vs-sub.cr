require "benchmark"
puts Crystal::DESCRIPTION

URL = "http://www.thelongestlistofthelongeststuffatthelongestdomainnameatlonglast.com/wearejustdoingthistobestupidnowsincethiscangoonforeverandeverandeverbutitstilllookskindaneatinthebrowsereventhoughitsabigwasteoftimeandenergyandhasnorealpointbutwehadtodoitanyways.html"

def slow
  URL.gsub("http://", "https://")
end

def fast
  URL.sub("http://", "https://")
end

Benchmark.ips do |x|
  x.report("String#gsub") { slow }
  x.report("String#sub") { fast }
end
