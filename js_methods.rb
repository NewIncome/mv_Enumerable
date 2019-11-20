  # frozen_string_literal: true

# rubocop:disable Style/StringLiterals, Style/AndOr

module Enumerable
  def my_each
    i = 0
    while i < length
      yield to_a[i] if block_given?
      i += 1
    end
  end

  def my_each_with_index
    i = 0
    while i < length
      yield to_a[i], i if block_given?
      i += 1
    end
  end

  def my_select
    temp_arr = []
    my_each do |e|
      temp = yield e
      temp_arr << e if temp
    end
    temp_arr
  end

  def my_all?
    ans = true
    my_each do |e|
      ans = false unless yield e
    end
    ans
  end

  def my_any?
    ans = false
    my_each do |e|
      ans = true if yield e
    end
    ans
  end

  def my_none?
    ans = true
    my_each do |e|
      ans = false if yield e
    end
    ans
  end

  def my_count(*chr)
    # why can't use *char directly???
    cnt = 0
    char = *chr
    if !char.empty?
      my_each { |e| cnt += 1 if e == char[0] }
      cnt
    else
      length
    end
  end

  def my_map
    arr = []
    if block_given?
      my_each do |e|
        elm = yield e
        arr << elm
      end
      arr
    else
      to_enum
    end
  end

  def my_inject(*init)
    init, sym = *init
    init.is_a?(Integer) ? acc = init : sym = init
    my_each do |e|
      acc = e and next if acc.nil? # to not sum 2times 1st value
      acc = if block_given? # because if and else asign to the same variable
              yield acc, e
            else
              acc.send(sym, e)
            end
    end
    acc
  end

  def my_map_bproc(&bproc)
    arr = []
    my_each do |e|
      arr << bproc.call(e)
    end
    arr
  end
end

def multiply_els(arr)
  arr.my_inject(:*)
end

my_hash = { "a" => 1, "b" => 2, "c": 3, "d": 4 }
my_n_array = [1, 2, 3, 4]
p "----- my_each_with_index method -----"
my_hash.each_with_index { |k, v| p "key: #{k}, val: #{v}" }
my_hash.my_each_with_index { |k, v| p "key: #{k}, val: #{v}" }
puts "my_select"
puts([1, 2, 3, 4, 5].my_select(&:odd?))
puts "my_all?"
puts([2, 4, 6].my_all?(&:even?))
puts "my_any?"
puts([2, 4, 6].my_any?(&:odd?))
puts "my_none?"
puts([2, 4, 6].my_none?(&:odd?))
puts "my_count"
puts([2, 3, 2].my_count(2))

my_n_array.each { |e| print "e+2: #{e + 2};" }
my_n_array.my_each { |e| p "e+2: #{e + 2}" }
p "----- map method -----"
p(my_n_array.map { |e| e * 2 })
p(my_n_array.my_map { |e| e * 2 })
p my_n_array.map
p my_n_array.my_map
p "----- my_inject method with array -----"
p(my_n_array.inject { |a, b| a * b })
p(my_n_array.my_inject { |a, b| a * b })
p "----- my_inject method with Symbol -----"
p my_n_array.inject(1, :*)
p my_n_array.my_inject(1, :*)
p(my_n_array.my_inject(3) { |a, b| a * b })
p my_n_array.inject(:+)
p my_n_array.my_inject(:+)
p "----- multiply_els -----"
p multiply_els([2, 4, 5])
p "----- my_map method with Proc -----"
bproc = proc { |e| p "Test: #{e}" }
[1, 2, ""].my_map_bproc(&bproc)
[1, 2, ""].my_map_bproc { |e| p "Test: #{e}" }
[1, 2, ""].my_map(&bproc)
[1, 2, ""].my_map { |e| p "Test: #{e}" }
[1, 2, ""].map(&bproc)
[1, 2, ""].map { |e| p "Test: #{e}" }
# .send   , checkITout
puts "--- .each & my_each with hash ---"
my_hash.each { |k, v| p "#{k}, #{v}" }
my_hash.my_each { |k, v| p "#{k}, #{v}" }
my_hash.each { |k| p k }
my_hash.my_each { |k| p k }
puts "--- .each & my_each with array ---"
my_n_array.each { |k, v| p "#{k}, #{v}" }
my_n_array.my_each { |k, v| p "#{k}, #{v}" }
# rubocop:enable Style/StringLiterals, Style/AndOr
# //cop  <-- configuration option
p 5.send(:+, 3)
