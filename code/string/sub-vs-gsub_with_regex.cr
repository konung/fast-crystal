require "benchmark"
puts Crystal::DESCRIPTION

URL = "http://www.thelongestlistofthelongeststuffatthelongestdomainnameatlonglast.com/wearejustdoingthistobestupidnowsincethiscangoonforeverandeverandeverbutitstilllookskindaneatinthebrowsereventhoughitsabigwasteoftimeandenergyandhasnorealpointbutwehadtodoitanyways.html"

def slow_1
  s = URL.dup
  s.sub "http://", ""
end

def slow_2
  s = URL.dup
  s.gsub "http://", ""
end

def slow_3
  s = URL.dup
  s.sub %r{http://}, ""
end

def slow_4
  s = URL.dup
  s.gsub %r{http://}, ""
end

Benchmark.ips do |x|
  x.report("String#sub(string)") { slow_1 }
  x.report("String#gsub(string)") { slow_2 }
  x.report("String#sub/regexp/") { slow_3 }
  x.report("String#gsub/regexp/") { slow_4 }
end
