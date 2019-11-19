# frozen_string_literal: true

# rubocop:disable Style/LineLength, Style/StringLiterals, Style/CaseEquality

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
    self.my_each do |e|
      temp = yield e
      temp_arr << e if temp
    end
    temp_arr
  end

  def my_all?
    ans = true
    self.my_each do |e|
      ans = false unless yield e
    end
    ans
  end

  def my_any?
    ans = false
    self.my_each do |e|
      ans = true if yield e
    end
    ans
  end

  def my_none?
    ans = true
    self.my_each do |e|
      ans = false if yield e
    end
    ans
  end

  def my_count(*chr) # why can't use *char ???
    cnt = 0; char = *chr
    unless char.empty?
      self.my_each { |e| cnt += 1 if e == char[0] }
      cnt
    else
      self.length
    end
  end

  def my_map
    arr = []
    if block_given?
      self.my_each do |e|
        elm = yield e
        arr << elm
      end
      arr
    else
      self.to_enum
    end
  end

  def my_inject(*init)
    init, sym = *init
    acc = init if init.is_a?(Fixnum)
    if !sym.nil? || init.is_a?(Symbol)
      sym = init if sym.nil? # to exchange values in case of 1 param.
      self.my_each do |e|
        acc = e and next if acc.nil? # to not sum 2times 1st value
        acc += e if sym == :+
        acc -= e if sym == :-
        acc *= e if sym == :*
        acc /= e if sym == :/
      end
      acc
    elsif block_given?
      self.my_each do |e|
        acc = e and next if acc.nil? # to not sum 2times 1st value
        acc = yield acc, e unless acc.nil?
      end
    end
    acc
  end

  def my_map_bproc(&bproc)
    arr = []
    self.my_each do |e|
      arr << bproc.call(e)
    end
    arr
  end

end

def self.multiply_els(arr)
  arr.my_inject(:*)
end

my_hash = { "a" => 1, "b" => 2, "c": 3, "d": 4 }
my_l_array = %w[ a b c d e ]
my_n_array = [1, 2, 3, 4]
# { "a": 1, "b": 2, "c": 3, "d": 4 }.my_each { |k, v| puts "key: #{k}, val: #{v}" }
# puts "true? #{e}, temp: #{temp}, acc: #{temp_arr}"
my_hash.each_with_index { |k, v| p "key: #{k}, val: #{v}" }; puts
my_hash.my_each_with_index { |k, v| p "key: #{k}, val: #{v}" }

puts [1, 2, 3, 4, 5].my_select { |n| n % 2 != 0 }

puts [2, 4, 6].my_all? { |n| n % 2 == 0 }

puts [2, 4, 6].my_any? { |n| n % 2 != 0 }

puts [2, 4, 6].my_none? { |n| n % 2 != 0 }

puts [2, 3, 2].my_count(2)

p my_n_array.each { |e| e + 1 }
p my_n_array.my_each { |e| e + 1 }
puts; p "map method"
p my_n_array.map { |e| e * 2 }
p my_n_array.my_map { |e| e * 2 }
p my_n_array.map
p my_n_array.my_map
puts
p my_n_array.inject { |a, b| a * b }
p my_n_array.my_inject { |a, b| a * b }
p my_n_array.inject(2, :+)
p my_n_array.my_inject(2, :+)

p multiply_els([2,4,5])
puts
bproc = Proc.new { |e| p "Test: #{e}" }
[1, 2, ""].my_map_bproc(&bproc)
[1, 2, ""].map { |e| p "Test: #{e}" }
[1, 2, ""].my_map(&bproc)
[1, 2, ""].map(&bproc)
[1, 2, ""].map { |e| p "Test: #{e}" }
# .send   , checkITout

#p my_n_array.my_inject
# rubocop:enable Style/LineLength, Style/StringLiterals, Style/CaseEquality
# //cop  <-- configuration option
