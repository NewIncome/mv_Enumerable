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

my_n_array = [1, 2, 3, 4]
my_hash = { 'a' => 1, 'b' => 2, 'c': 3, 'd': 4 }
aproc = proc { |e| e.even? }
bproc = proc { |e| e.length == 2 }
cproc = proc { |a, b| a + b }
p '======================================'
p '======== My_MAP method tests ========'
p '----- my_map method w/Array & argument -----'
p [2, 3, 2].map
p [2, 3, 2].my_map
p [2, 3, 2].map { |e| e * e }
p [2, 3, 2].my_map { |e| e * e }
p [2, 3, 2].map { 'cat' }
p [2, 3, 2].my_map { 'cat' }
p [2, 3, 2].map { |e| e.even? }
p [2, 3, 2].my_map { |e| e.even? }
p '----- my_map method w/Hash -----'
p my_hash.map { |e| e + e }
p my_hash.my_map { |e| e + e }
p my_hash.map { |e| e + ['I'] }
p my_hash.my_map { |e| e + ['I'] }
p '----- my_map method w/Range -----'
p (1..4).map { |e| e + e }
p (1..4).my_map { |e| e + e }
p (1..4).map { |e| e * e }
p (1..4).my_map { |e| e * e }
p (1..4).map { 'cat' }
p (1..4).my_map { 'cat' }
p '----- my_map method w/Proc -----'         # working perfectly with a PROC
p "#{[2, 3, 2].map(&aproc)}, #{[2, 3, 2].map(&:odd?)}"   # <-=======
p "#{[2, 3, 2].my_map(&aproc)}, #{[2, 3, 2].my_map(&:odd?)}"   # <-=======
p '----- my_map method w/Proc & Block -----'

p '======================================'
