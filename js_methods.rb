# frozen_string_literal: true

module Enumerable
  def my_each
    return to_enum(__method__) unless block_given?

    @i = 0
    while @i < to_a.size
      yield to_a[@i] if block_given?
      @i += 1
    end
    self
  end

  def my_each_with_index
    block_given? ? my_each { |e| yield e, @i } : to_enum(__method__)
  end

  def my_select
    return to_enum(__method__) unless block_given?

    temp_arr = []
    my_each { |e| temp_arr << e if yield e }
    temp_arr
  end

  def my_all?(*vrs)
    if block_given?
      my_each { |e| return false unless yield e }
    elsif vrs[0].is_a?(Class)
      my_each { |e| return false unless e.is_a?(vrs[0]) }
    elsif vrs[0].is_a?(Regexp) || vrs[0].is_a?(Numeric) || vrs[0].is_a?(String)
      vrs[0].is_a?(Regexp) ? my_each { |e| return false if e !~ vrs[0] } : my_each { |e| return false if e != vrs[0] }
    else
      my_each { |e| return false unless e }
    end
    true
  end

  def my_none?(*vrs)
    if block_given?
      my_each { |e| return false if yield e }
    elsif vrs[0].is_a?(Class)
      my_each { |e| return false if e.is_a?(vrs[0]) }
    elsif vrs[0].is_a?(Regexp) || vrs[0].is_a?(Numeric) || vrs[0].is_a?(String)
      vrs[0].is_a?(Regexp) ? my_each { |e| return false if e =~ vrs[0] } : my_each { |e| return false if e == vrs[0] }
    else
      my_each { |e| return false if e }
    end
    true
  end

  def my_any?(*vrs)
    if block_given?
      my_each { |e| return true if yield e }
    elsif vrs[0].is_a?(Class)
      my_each { |e| return true if e.is_a?(vrs[0]) }
    elsif vrs[0].is_a?(Regexp) || vrs[0].is_a?(Numeric) || vrs[0].is_a?(String)
      vrs[0].is_a?(Regexp) ? my_each { |e| return true if e =~ vrs[0] } : my_each { |e| return true if e == vrs[0] }
    else
      my_each { |e| return true if e }
    end
    false
  end

  def my_count(*chr)
    cnt = 0
    char = *chr
    if block_given?
      my_each { |e| cnt += 1 if yield e }
      cnt
    elsif !char.empty?
      my_each { |e| cnt += 1 if e == char[0] }
      cnt
    else
      length
    end
  end

  def my_map
    arr = []
    if block_given?
      my_each { |e| arr << (yield e) }
      arr
    else
      to_enum(__method__)
    end
  end

  def my_inject(*init)
    init, sym = *init
    init.is_a?(Integer) ? acc = init : sym = init
    if block_given? || !sym.empty?
      my_each do |e|
        acc = e and next if acc.nil?
        acc = if block_given?
                yield acc, e
              else
                acc.send(sym, e)
              end
      end
    else
      to_enum(__method__)
    end
    acc
  end

  def my_map_bproc(&bproc)
    arr = []
    my_each { |e| arr << bproc.call(e) }
    arr
  end
end

def multiply_els(arr)
  arr.my_inject(:*)
end

my_hash = { 'a' => 1, 'b' => 2, 'c': 3, 'd': 4 }
my_n_array = [1, 2, 3, 4]

my_hash = { 'a' => 1, 'b' => 2, 'c': 3, 'd': 4 }
aproc = proc { |e| e.even? }
bproc = proc { |e| e.length == 2 }
cproc = proc { |a, b| a + b }
p '======================================'
p '======== My_INJECT method tests ========'
p '----- my_inject method w/Array & Block / Symbol -----'
puts "#{my_n_array.inject { |a, b| a * b }}, #{my_n_array.inject(:+)}"
puts "#{my_n_array.my_inject { |a, b| a * b }}, #{my_n_array.my_inject(:+)}"
p '----- my_inject method w/Array & Symbol w/arg -----'
puts "#{my_n_array.inject(1, :*)}, #{my_n_array.inject(100, :/)}"
puts "#{my_n_array.my_inject(1, :*)}, #{my_n_array.my_inject(100, :/)}"
p '----- my_inject method w/Array & Block w/arg -----'
puts my_n_array.inject(3) { |a, b| a * b }
puts my_n_array.my_inject(3) { |a, b| a * b }
p '----- my_inject method w/Hashes -----'
print my_hash.inject { |a, b| a + b }; puts
print my_hash.my_inject { |a, b| a + b }; puts
p '--- test 2 ---'
print my_hash.inject(:+); puts
print my_hash.my_inject(:+); puts
p '--- test 3 ---'
print my_hash.inject(&cproc); puts
print my_hash.my_inject(&cproc); puts
p '----- my_inject method w/Ranges -----'
puts "#{(1..3).inject(:+)}, #{(1..3).inject(3) { |a, b| a * b }}, #{(1..3).inject(3) { |a, b| a * (b+1) }}"
puts "#{(1..3).my_inject(:+)}, #{(1..3).my_inject(3) { |a, b| a * b }}, #{(1..3).my_inject(3) { |a, b| a * (b+1) }}"
p '======================================'

p multiply_els(1..6)
