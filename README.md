# fast-crystal
Benchmarks of common idioms in Crystal, to help write more performant code.

This project is a port to Crystal of [fast-ruby](https://github.com/JuanitoFatas/fast-ruby) project by [JuanitoFatas](https://github.com/JuanitoFatas).

I did this while learning Crystal, as an exercise to dive deeper into various aspects of the superb Crystal language. I also added some Crystal-specific benchmarks, such as comparing NamedTuple vs Hash. ( Spoiler: NamedTuples are much faster!), and removed some that don't make sense for Crystal (there is only Array#size in Crystal, no Array#length and Array#count is provided by Enumerable).

This is also a useful tool for those coming to Crystal from Ruby and other dynamic languages. Some of the assumptions I had about certain idioms in Ruby, are no longer true and maybe reverse in Crystal. For example in Crystal `Array#find` is faster on a sorted Array than `Array#bsearch`, but in Ruby it's the [reverse](https://github.com/JuanitoFatas/fast-ruby#array)

--------------------------------

## How to contribute new benchmarks
* Fork & clone .
* Add a benchmark.
* Update README.md with the results.
* Make a Pull Request with a short explanation / rationale.
* Kick-back and have a drink.
* If you are not sure if the benchmark is warranted, open an issue - let's discuss it.

### Template for the benchmark

```crystal
require "benchmark"
puts Crystal::DESCRIPTION # Always include this, so that we know which OS & version of Crystal, you used.

def fast
end

def slow
end

Benchmark.ips do |x|
  x.report("fast code description") { fast }
  x.report("slow code description") { slow }
end
```

When you run your code don't forget to use `--release` flag, or  you are not going to get accurate benchmarks (you don't need to build first), i.e.:

```shell
crystal code/array/array-first-vs-index.cr --release
```

Copy and paste output from console into README.md under appropriate section.

--------------------------------

## Results

Idioms
------

### Index


- [Array](#array)
- [Range](#range)
- [Time](#time)
- [Proc & Block](#proc--block)
- [String](#string)
- [Hash](#hash)


- [Enumerable](#enumerable)
- [General](#general)

--------------------------------

### Array

##### `Array#[](0)` vs `Array#first` [code](code/array/array-first-vs-index.cr)

```
crystal array-first-vs-index.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

  Array#[0] 405.11M (  2.47ns) (± 3.92%)  0 B/op        fastest
Array#first 358.67M (  2.79ns) (± 3.73%)  0 B/op   1.13× slower

```

##### `Array#[](-1)` vs `Array#last` [code](code/array/array-last-vs-index.cr)

```
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

Array#[-1] 404.99M (  2.47ns) (± 3.10%)  0 B/op        fastest
Array#last 358.27M (  2.79ns) (± 4.23%)  0 B/op   1.13× slower

```

##### `Array#bsearch` vs `Array#find` [code](code/array/bsearch-vs-find.cr)

**WARNING:** `bsearch` ONLY works on *sorted array*. `bsearch` is a bit faster on smaller Arrays, but still lags behind.

```
 crystal code/array/bsearch-vs-find.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

   find  396.3M (  2.52ns) (± 3.52%)  0 B/op        fastest
bsearch  12.11M ( 82.61ns) (± 2.32%)  0 B/op  32.74× slower
```



##### `Array#shuffle.first` vs `Array#sample` [code](code/array/shuffle-first-vs-sample.cr)

> `Array#shuffle` allocates an extra array. <br>
> `Array#sample` indexes into the array without allocating an extra array.

```
crystal code/array/shuffle-first-vs-sample.cr  --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

       Array#sample  76.52M ( 13.07ns) (± 3.39%)    0 B/op         fastest
Array#shuffle.first  535.8k (  1.87µs) (± 2.43%)  832 B/op  142.81× slower
```



##### `Array#insert` vs `Array#unshift` [code](code/array/insert-vs-unshift.cr)

```
crystal code/array/insert-vs-unshift.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

Array#unshift   1.35  (742.07ms) (± 1.42%)  1573696 B/op        fastest
 Array#insert   1.34  (746.59ms) (± 1.20%)  1574201 B/op   1.01× slower
```

--------------------------------


### Range

#### `covers?` vs `includes?` vs `plain comparison` [code](code/range/covers-vs-includes.cr)

`covers?` is essentially an alias for `includes?`, so unlike in Ruby the performance is identical, however they maybe be faster than using `>` and `<` depending on the type of data you are dealing with. For Int32 there is no difference, but for Time(Dates) `includes?` is 1.5x faster.

```
crystal code/range/cover-vs-include.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

  range#covers? 461.38M (  2.17ns) (± 4.44%)  0 B/op   1.00× slower
range#includes? 463.13M (  2.16ns) (± 3.97%)  0 B/op        fastest
  plain compare 292.48M (  3.42ns) (± 4.50%)  0 B/op   1.58× slowe
```

--------------------------------


### Time (Date)

##### `Time.iso8601` vs `Time.parse` [code](code/time/iso8601-vs-parse.cr)

If you know incoming datetime format it's better to use specific function. Unlike in Ruby there is no separate basic type - Date & Time. Everything is just Time. So there is no reason for a separate "Date" benchmark

```
crystal code/time/iso8601-vs-parse.cr  --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

Time.parse_iso8601   9.12M (109.63ns) (± 1.95%)    0 B/op         fastest
        Time.parse  49.88k ( 20.05µs) (± 2.94%)  360 B/op  182.88× slower
```





--------------------------------


### Proc & Block

##### Block vs `Symbol#to_proc` [code](code/proc-and-block/block-vs-to_proc.cr)

There is a small performance penalty in Ruby for using `&:shortcut` , but not in crystal, so use away!

```
crystal code/proc-and-block/block-vs-to_proc.cr   --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx
         Block  283.4k (  3.53µs) (± 3.31%)  2656 B/op        fastest
Symbol#to_proc  281.9k (  3.55µs) (± 3.10%)  2656 B/op   1.01× slower
```

##### `Proc#call` and block arguments vs `yield`[code](code/proc-and-block/proc-call-vs-yield.cr)

In Ruby, method with `yield` can be much faster, but in Crystal, it's almost identical to it's counterparts.
This benchmark has more context in Ruby, because block arguments were passed differently in different versions, incurring heap allocation  and implementing lazy Proc allocation and conversion. This benchmark was ported to Crystal, just to see if there is any penalty (none!) and to see how it works in Crystal. Pay attention to how what you do with block arguments and methods.

```crystal

def slow(&block)
  block.call
end

slow {1+1}
# In Crystal returns
nil

# In Ruby returns
2

```


```
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

   block.call 531.71M (  1.88ns) (± 5.89%)  0 B/op   1.00× slower
block + yield 518.12M (  1.93ns) (± 7.24%)  0 B/op   1.03× slower
 unused block 533.64M (  1.87ns) (± 5.46%)  0 B/op        fastest
        yield 525.73M (   1.9ns) (± 6.76%)  0 B/op   1.02× slower
```



--------------------------------

### String

##### `String#dup` vs `String#+` [code](code/string/dup-vs-unary-plus.cr)

In Crystal, dup is much more effecient at creating shallow copies. No reason to use `"string" + ""` trick anymore ( if you did before)

```
crystal code/string/dup-vs-unary-plus.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

 String#+@ 471.96M (  2.12ns) (± 9.13%)  0 B/op   1.07× slower
String#dup 502.68M (  1.99ns) (± 5.32%)  0 B/op        fastest
```

##### `String#compare` vs `String#downcase + ==` [code](code/string/casecmp-vs-downcase-==.cr)

```
crystal code/string/compare-vs-downcase-==.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

String#downcase + ==  26.74M (  37.4ns) (± 9.13%)  32 B/op        fastest
      String#compare  21.83M (  45.8ns) (± 3.37%)   0 B/op   1.22× slower
```

##### String Concatenation [code](code/string/concatenation.cr)
In Crystal there is no `<<`, `String#concat` or `String#append`. You really only have 2 choices and one is almost 20x faster than the other. So it's not even really a choice: use interpolation whenever possible.

```
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

      String#+  27.71M ( 36.09ns) (± 4.35%)  32 B/op  19.28× slower
{"foo"}{"bar"} 534.16M (  1.87ns) (± 4.21%)   0 B/op        fastest
```

##### `String#match` vs `String.=~` vs `String#starts_with?`/`String#ends_with?` [code (start)](code/string/checking-match-vs-starts_with.cr) [code (end)](code/string/checking-match-vs-ends_with.cr)

If you have limited number of possibilities to match against, prefer to use starts_with/ends_with  whenever possible, because it's orders of magnitude faster.

```
 crystal code/string/end-string-checking-match-vs-end_with.cr  --release
\Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

        String#=~   2.93M (341.26ns) (± 5.67%)  32 B/op  133.53× slower
     String#match   3.07M (325.78ns) (± 2.29%)  32 B/op  127.47× slower
String#ends_with? 391.28M (  2.56ns) (± 3.56%)   0 B/op         fastest
```


##### `Regexp#===` vs `String#match` vs `String#=~`  [code ](code/string/===-vs-=~-vs-match.cr)

While there is speed advantage to using `=~` in Ruby, there is no difference in Crystal in equivalent situations. Keep in mind that `===` returns `true/false` while `=~` returns start position of the match and `.match` returns `MatchData` object which ok if you are using to check for `falsy/thruthy` type values. Also keep in mind that these expressions are not 100% equivalent. ie.:

```crystal
"boo".match(/boo/)`  #=> truthy
/boo/ === "boo"      #=> true
"book".match(/boo/)  #=> truthy
/book/ === "boo"     #=> false!!! So be very careful!
```

```
crystal code/string/===-vs-=\~-vs-match.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

   String#=~  13.76M ( 72.66ns) (± 1.00%)  16 B/op   1.00× slower
  Regexp#===  13.81M (  72.4ns) (± 2.75%)  16 B/op        fastest
String#match  13.77M ( 72.63ns) (± 2.24%)  16 B/op   1.00× slower
```


##### `String#gsub` vs `String#sub`  [code](code/string/gsub-vs-sub.cr)

```
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

 String#sub   2.21M (451.77ns) (± 4.22%)  1249 B/op        fastest
String#gsub   1.15M (869.95ns) (± 2.92%)  1249 B/op   1.93× slower
```

##### `String#gsub` vs `String#tr` [code](code/string/gsub-vs-tr.cr)

In Ruby .tr is a few times faster, but in Crystal you are slightly faster using gsub.

```
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

String#gsub  24.88M ( 40.19ns) (± 2.33%)  32 B/op        fastest
  String#tr  22.68M ( 44.09ns) (± 2.88%)  32 B/op   1.10× slower
```


##### `String#sub!` vs `String#gsub!` vs `String#[]=` [code](code/string/sub-vs-gsub_with_regex.cr)

Whenever possible `sub` will provide fastest performance. (Keep in mind unlike Ruby, Crystal has IMMUTABLE strings, so string[2] = "Ruby", doesn't work!)

```
crystal code/string/sub-vs-gsub_with_regex.cr   --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

 String#sub(string)   2.66M (375.53ns) (± 6.95%)  384 B/op        fastest
String#gsub(string)   1.22M (817.47ns) (± 5.45%)  384 B/op   2.18× slower
 String#sub/regexp/    1.9M (526.88ns) (± 8.28%)  432 B/op   1.40× slower
String#gsub/regexp/   1.13M (884.29ns) (± 6.07%)  449 B/op   2.35× slower

```

##### `String#sub` vs `String#lchop` [code](code/string/sub-vs-lchop.cr)

Keep in mind that String#delete is faster than Sting#sub, but it's greedy! ( Thus remove from this test)

```
crystal code/string/sub-vs-lchop.cr   --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx
String#lchop   29.8M ( 33.56ns) (± 9.20%)   32 B/op        fastest
  String#sub    3.2M (312.77ns) (± 5.80%)  176 B/op   9.32× slower
```

##### `String#sub` vs `String#chomp`  [code](code/string/sub-vs-chomp-vs-delete.cr)


```
crystal code/string/sub-vs-chomp.cr  --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

  String#sub   3.16M ( 316.3ns) (± 2.58%)  176 B/op   8.60× slower
String#chomp   27.2M ( 36.76ns) (± 5.01%)   32 B/op        fastest
```



##### Remove extra spaces (or other contiguous characters) [code](code/string/remove-extra-spaces-or-other-chars.cr)

The code is tested against contiguous spaces but should work for other chars too.

```
crystal code/string/remove-extra-spaces-or-other-chars.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

String#gsub/regex+/  87.68k ( 11.41µs) (± 1.44%)  2976 B/op   1.55× slower
     String#squeeze  135.8k (  7.36µs) (± 1.26%)   608 B/op        fastest
```


--------------------------------

### Hash

##### `Hash#[]` vs `Hash#fetch`  vs `Hash#dig` [code](code/hash/bracket-vs-fetch-vs-dig.cr)

Using symbols as keys is generally faster, and using `.dig` while slightly slower, is definitely more convenient (then `fetch`) and safer(!), especially on a deeply nested hash.
Using Union type for keys `Hash(String | Symbol, String` slows down access on hash.  Use Hash#dig?(:a, :b, :c) if you are not sure if :b or :c are "diggable"

```
crystal code/hash/bracket-vs-fetch-vs-dig.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx
   Hash#[], symbol  63.59M ( 15.73ns) (± 4.75%)  0 B/op   1.10× slower
Hash#fetch, symbol  69.67M ( 14.35ns) (± 2.91%)  0 B/op        fastest
  Hash#dig, symbol  66.98M ( 14.93ns) (± 2.39%)  0 B/op   1.04× slower
   Hash#[], string  56.32M ( 17.75ns) (± 2.92%)  0 B/op   1.24× slower
Hash#fetch, string  59.74M ( 16.74ns) (± 2.93%)  0 B/op   1.17× slower
  Hash#dig, string  56.82M (  17.6ns) (± 2.68%)  0 B/op   1.23× slower
```

##### `Hash#dig` vs `Hash#[]` vs `Hash#fetch` [code](code/hash/bracket-vs-fetch-vs-dig-nested-hash.cr)

`fetch` seems to break on deeply nested hash. Using `dig?` is the preferred method as the one being safer

```
crystal code/hash/bracket-vs-fetch-vs-dig-nested-hash.cr  --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx
 Hash#dig?  12.78M ( 78.23ns) (± 1.99%)  0 B/op   1.01× slower
  Hash#dig  12.72M ( 78.64ns) (± 2.79%)  0 B/op   1.01× slower
   Hash#[]  12.85M ( 77.81ns) (± 1.95%)  0 B/op        fastest
Hash#[] &&   4.54M (220.02ns) (± 2.08%)  0 B/op   2.83× slower
```


##### `Hash#fetch` with argument vs `Hash#fetch` + block [code](code/hash/fetch-vs-fetch-with-block.cr)

There is no difference in Crystal, while in Ruby fetch with non-constant argument is 30% slower

```
crystal code/hash/fetch-vs-fetch-with-block.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx
Hash#fetch + const  73.21M ( 13.66ns) (± 3.06%)  0 B/op        fastest
Hash#fetch + block  72.93M ( 13.71ns) (± 2.67%)  0 B/op   1.00× slower
  Hash#fetch + arg  72.17M ( 13.86ns) (± 3.11%)  0 B/op   1.01× slower
```

##### `Hash#each_key` instead of `Hash#keys.each` [code](code/hash/keys-each-vs-each_key.cr)


```
crystal code/hash/keys-each-vs-each_key.cr  --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

Hash#keys.each   1.79M (559.32ns) (± 4.86%)  416 B/op   1.07× slower
 Hash#each_key   1.92M (521.93ns) (± 7.75%)  338 B/op        fastest
```

#### `Hash#key?` instead of `Hash#keys.include?` [code](code/hash/keys-includes-vs-has_key.cr)

> `Hash#keys.include?` allocates an array of keys and performs an O(n) search; <br>
> `Hash#has_key?` performs an O(1) hash lookup without allocating a new array.

```
 crystal code/hash/keys-includes-vs-has_key.cr   --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx
Hash#keys.includes?   5.87k ( 170.3µs) (± 3.24%)  146272 B/op  6472.68× slower
      Hash#has_key?  38.01M ( 26.31ns) (± 4.81%)       0 B/op          fastest
```

##### `Hash#value?` instead of `Hash#values.include?` [code](code/hash/values-include-vs-value.cr)

> `Hash#values.includes?` allocates an array of values and performs an O(n) search; <br>
> `Hash#has_value?` performs an O(n) search without allocating a new array.

```
crystal code/hash/values-includes-vs-has_value.cr  --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx
Hash#values.includes?   5.73k (174.43µs) (± 3.79%)  146272 B/op  90033.84× slower
      Hash#has_value? 516.16M (  1.94ns) (± 6.66%)       0 B/op           fastest
```

##### `Hash#merge!` vs `Hash#[]=` [code](code/hash/merge-bang-vs-brackets.cr)

```
crystal code/hash/merge-bang-vs-brackets.cr    --release               Mon Feb 25 22:20:32 2019
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx
Hash#merge!  33.69k ( 29.68µs) (± 4.23%)  26415 B/op   3.74× slower
   Hash#[]= 125.96k (  7.94µs) (± 3.21%)   5538 B/op        fastest
```


##### `Hash#merge` vs `Hash#merge!` [code](code/hash/merge-vs-merge-bang.cr)

```
crystal code/hash/merge-vs-merge-bang.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

 Hash#merge   2.38k (420.05µs) (± 3.01%)  304740 B/op  13.86× slower
Hash#merge!  32.99k ( 30.32µs) (± 1.83%)   26415 B/op        fastest
```

##### `{}#merge!(Hash)` vs `Hash#merge({})` vs `Hash#dup#merge!({})` [code](code/hash/merge-bang-vs-merge-vs-dup-merge-bang.cr)

```
crystal code/hash/merge-bang-vs-merge-vs-dup-merge-bang.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx
{}#merge!(Hash) do end  24.35k ( 41.06µs) (± 6.10%)  35758 B/op        fastest
        Hash#merge({})  15.08k ( 66.32µs) (± 8.26%)  59754 B/op   1.61× slower
   Hash#dup#merge!({})  15.11k ( 66.17µs) (± 5.16%)  59763 B/op   1.61× slower
```

##### `Hash#sort_by` vs `Hash#sort` [code](code/hash/hash-key-sort_by-vs-sort.cr)

To sort hash by key. Keep in mind that if you need to  do this, is a code smell of a  wrong data structure. Even in Ruby, `sort` & `sort_by` make implicit calls `.to_a` first.
But remember, in Crystal we have Tuples!, so consider using: Array(Tuple(Symbol, String)) instead?
Having said that, this is probably not a bottleneck in your app :)

```
crystal code/hash/hash-key-sort_by-vs-sort.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx
sort_by + to_h 156.46k (  6.39µs) (± 2.96%)  5159 B/op   1.19× slower
   sort + to_h  185.7k (  5.39µs) (± 4.60%)  4330 B/op        fastest
```


--------------------------------




### Enumerable

##### `Enumerable#each + push` vs `Enumerable#map` [code](code/enumerable/each-push-vs-map.cr)

```
crystal code/enumerable/each-push-vs-map.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

Array#each + push 849.93k (  1.18µs) (± 0.75%)  1712 B/op   2.65× slower
        Array#map   2.25M (443.66ns) (± 7.10%)   480 B/op        fastest
```

##### `Enumerable#each` vs `loop` vs `while` vs `step` vs `upto` vs `times` vs `downto`  [code](code/enumerable/each-vs-loop-vs-while-vs-step-vs-upto-vs-downto-vs-times.cr)
`each` is the fastest way to iterate over an array. But if another approach makes your code clearer - use it.

```
crystal code/enumerable/each-vs-loop-vs-while-vs-step-vs-upto-vs-downto-vs-times.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

  #step   6.07M (164.82ns) (± 2.22%)  0 B/op  65.18× slower
  #upto   8.95M ( 111.7ns) (± 1.91%)  0 B/op  44.17× slower
#downto   8.49M (117.72ns) (± 1.85%)  0 B/op  46.55× slower
 #times  12.92M ( 77.42ns) (± 2.37%)  0 B/op  30.62× slower
  #each 395.48M (  2.53ns) (± 4.25%)  0 B/op        fastest
  while   7.57M (132.03ns) (± 2.05%)  0 B/op  52.21× slower
   loop   6.03M (165.79ns) (± 2.12%)  0 B/op  65.56× slower
```

##### `Enumerable#each_with_index` vs `while` loop [code](code/enumerable/each_with_index-vs-while-loop.cr)

```
crystal code/enumerable/each_with_index-vs-while-loop.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

     While Loop   9.54M (104.83ns) (± 2.32%)  0 B/op  41.38× slower
each_with_index 394.74M (  2.53ns) (± 4.30%)  0 B/op        fastest
```

##### `Enumerable#map`. vs `Enumerable#flat_map` [code](code/enumerable/map-flatten-vs-flat_map.cr)


```
crystal code/enumerable/map-flatten-vs-flat_map.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

Array#map.flatten  99.74k ( 10.03µs) (± 4.40%)  9646 B/op   1.30× slower
   Array#flat_map 129.47k (  7.72µs) (± 3.14%)  7366 B/op        fastest
```

##### `Enumerable#reverse.each` vs `Enumerable#reverse_each` [code](code/enumerable/reverse-each-vs-reverse_each.cr)

`Enumerable#reverse` allocates an extra array.
`Enumerable#reverse_each` yields each value without allocating an extra array. <br>


```
crystal code/enumerable/reverse-each-vs-reverse_each.cr  --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx
Array#reverse.each   2.16M ( 463.7ns) (± 5.72%)  480 B/op  175.64× slower
Array#reverse_each 378.79M (  2.64ns) (± 5.22%)    0 B/op         fastes
```

##### `Enumerable#sort_by.first` vs `Enumerable#min_by` [code](code/enumerable/sort_by-first-vs-min_by.cr)
`Enumerable#sort_by` performs a sort of the enumerable and allocates a
new array the size of the enumerable.  `Enumerable#min_by` doesn't
perform a sort or allocate an array the size of the enumerable.
Similar comparisons hold for `Enumerable#sort_by.last` vs
`Enumerable#max_by`, `Enumerable#sort.first` vs `Enumerable#min`, and
`Enumerable#sort.last` vs `Enumerable#max`.

```
crystal code/enumerable/sort_by-first-vs-min_by.cr --release        Tue Feb 26 00:57:16 2019
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

         Enumerable#min_by 404.49M (  2.47ns) (± 3.90%)     0 B/op          fastest
Enumerable#sort_by...first 360.16k (  2.78µs) (± 4.20%)  1888 B/op  1123.08× slower
```

##### `Enumerable#find` vs `Enumerable#select.first` [code](code/enumerable/select-first-vs-find.cr)

Keeping with Crystal's convention of having more or less 1 obvious way of doing stuff, for example there is no `Enumerable#detect`, like in Ruby.

```
crystal code/enumerable/select-first-vs-find.cr --release    1.3m  Tue Feb 26 00:47:29 2019
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

Enumerable#select.first   6.79M (147.18ns) (± 3.54%)  48 B/op  66.37× slower
        Enumerable#find 450.97M (  2.22ns) (± 5.47%)   0 B/op        fastest
```

##### `Enumerable#select.last` vs `Enumerable#reverse.detect` [code](code/enumerable/select-last-vs-reverse-find.cr)

```
crystal code/enumerable/select-last-vs-reverse-find.cr  --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

Enumerable#reverse.find   2.05M (487.74ns) (± 3.14%)  480 B/op   1.44× slower
 Enumerable#select.last   2.95M (338.92ns) (± 3.59%)  145 B/op        fastest
```

##### `Enumerable#sort` vs `Enumerable#sort_by` [code](code/enumerable/sort-vs-sort_by.cr)

```
crystal code/enumerable/sort-vs-sort_by.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

Enumerable#sort_by (Symbol#to_proc)  104.9k (  9.53µs) (± 2.24%)  3136 B/op   1.58× slower
                 Enumerable#sort_by 104.28k (  9.59µs) (± 2.73%)  3136 B/op   1.59× slower
                    Enumerable#sort 165.91k (  6.03µs) (± 2.02%)  1056 B/op        fastest
```

##### `Enumerable#reduce Block` vs `Enumerable#reduce Proc` [code](code/enumerable/inject-symbol-vs-block.cr)


```
crystal code/enumerable/reduce-proc-vs-block.cr --release
Crystal 0.27.2 (2019-02-05)

LLVM: 6.0.1
Default target: x86_64-apple-macosx

reduce to_proc 389.91M (  2.56ns) (± 5.00%)  0 B/op   1.03× slower
  reduce block  401.7M (  2.49ns) (± 4.65%)  0 B/op        fastest
```

--------------------------------

## License

![CC-BY-SA](CC-BY-SA.png)

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).


## Code License

### CC0 1.0 Universal

To the extent possible under law, @konung has waived all copyright and related or neighboring rights to "fast-crystal".

This work belongs to the community.

