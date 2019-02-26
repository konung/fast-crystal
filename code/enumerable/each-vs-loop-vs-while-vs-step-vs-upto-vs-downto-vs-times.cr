require "benchmark"
puts Crystal::DESCRIPTION

ARRAY = (1..100).to_a

def using_step
  0.step(by: 1) do |i|
    break unless ARRAY[i]?
    ARRAY[i] ** 2
  end
end

def using_upto
  0.upto(ARRAY.size - 1) do |i|
    ARRAY[i] ** 2
  end
end

def using_downto
  ARRAY.size.downto(1) do |i|
    ARRAY[ARRAY.size - i] ** 2
  end
end

def using_times
  ARRAY.size.times do |i|
    ARRAY[i] ** 2
  end
end

def using_each
  ARRAY.each do |number|
    number ** 2
  end
end

def using_while
  i = 0
  while i < ARRAY.size
    ARRAY[i] ** 2

    i += 1
  end
end

def using_loop
  i = 0
  loop do
    break unless ARRAY[i]?
    ARRAY[i] ** 2
    i += 1
  end
end

Benchmark.ips do |x|
  x.report("#step") { using_step }
  x.report("#upto") { using_upto }
  x.report("#downto") { using_downto }
  x.report("#times") { using_times }
  x.report("#each") { using_each }
  x.report("while") { using_while }
  x.report("loop") { using_loop }
end
