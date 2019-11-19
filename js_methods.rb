# frozen_string_literal: true

# rubocop:disable Style/StringLiterals

module Enumerable
  def my_each
    for e in self
      yield e if block_given?
    end
  end

  def my_each_with_index
    i = 0
    for e in self
      yield e, i if block_given?
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
    acc = init if init.is_a?(Integer)
    if !sym.nil? || init.is_a?(Symbol)
      sym = init if sym.nil? # to exchange values in case of 1 param.
      my_each do |e|
        acc = e && next if acc.nil? # to not sum 2times 1st value
        acc += e if sym == :+
        acc -= e if sym == :-
        acc *= e if sym == :*
        acc /= e if sym == :/
      end
      acc
    elsif block_given?
      my_each do |e|
        acc = e && next if acc.nil? # to not sum 2times 1st value
        acc = yield acc, e unless acc.nil?
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

def self.multiply_els(arr)
  arr.my_inject(:*)
end

my_hash = { "a" => 1, "b" => 2, "c": 3, "d": 4 }
my_lt_array = %w[a b c d e]
my_n_array = [1, 2, 3, 4]
# { "a": 1, "b": 2, "c": 3, "d": 4 }.my_each { |k, v| puts "key: #{k}, val: #{v}" }
# puts "true? #{e}, temp: #{temp}, acc: #{temp_arr}"
my_hash.each_with_index { |k, v| p "key: #{k}, val: #{v}" }
my_hash.my_each_with_index { |k, v| p "key: #{k}, val: #{v}" }

puts [1, 2, 3, 4, 5].my_select { |n| n % 2 != 0 }

puts [2, 4, 6].my_all? { |n| n % 2 == 0 }

puts [2, 4, 6].my_any? { |n| n % 2 != 0 }

puts [2, 4, 6].my_none? { |n| n % 2 != 0 }

puts [2, 3, 2].my_count(2)

p my_n_array.each { |e| e + 1 }
p my_n_array.my_each { |e| e + 1 }
p "map method"
p my_n_array.map { |e| e * 2 }
p my_n_array.my_map { |e| e * 2 }
p my_n_array.map
p my_n_array.my_map
p my_n_array.inject { |a, b| a * b }
p (my_n_array.my_inject { |a, b| a * b })
p my_n_array.inject(2, :+)
p my_n_array.my_inject(2, :p)
my_n_array.my_inject { |a, b| a * b }

p multiply_els([2, 4, 5])
bproc = proc { |e| p "Test: #{e}" }
[1, 2, ""].my_map_bproc(&bproc)
[1, 2, ""].my_map_bproc { |e| p "Test: #{e}" }
[1, 2, ""].my_map(&bproc)
[1, 2, ""].my_map { |e| p "Test: #{e}" }
[1, 2, ""].map(&bproc)
[1, 2, ""].map { |e| p "Test: #{e}" }
# .send   , checkITout
p my_hash.key(2)
# rubocop:enable Style/StringLiterals
# //cop  <-- configuration option
