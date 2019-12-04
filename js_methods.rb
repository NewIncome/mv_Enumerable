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
      my_each do |e|
        elm = yield e
        arr << elm
      end
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

puts
p '----- my_inject method with array -----'
p(my_n_array.inject { |a, b| a * b })
p(my_n_array.my_inject { |a, b| a * b })
p '----- my_inject method with Symbol -----'
p my_n_array.inject(1, :*)
p my_n_array.my_inject(1, :*)
p(my_n_array.inject(3) { |a, b| a * b })
p(my_n_array.my_inject(3) { |a, b| a * b })
p my_n_array.inject(:+)
p my_n_array.my_inject(:+)

my_hash = { 'a' => 1, 'b' => 2, 'c': 3, 'd': 4 }
aproc = proc { |e| e.even? }
bproc = proc { |e| e.length == 2 }
p '======================================'
p '======== My_COUNT method tests ========'
p '----- my_count method w/Array & argument -----'
puts [2, 3, 2].count(2)
puts [2, 3, 2].my_count(2)
p '----- my_count method w/Array & block / proc -----'
puts "#{[2, 3, 2].count { |e| (e % 3).zero? }}, #{[2, 3, 2].count(&aproc)}"
puts "#{[2, 3, 2].my_count { |e| (e % 3).zero? }}, #{[2, 3, 2].my_count(&aproc)}"
p '----- my_count method w/Array & no block no arg -----'
puts "#{[2, 3, 2].count}, #{[2, false, nil].count}, #{[false, nil, false].count}, #{[].count}"
puts "#{[2, 3, 2].my_count}, #{[2, false, nil].my_count}, #{[false, nil, false].my_count}, #{[].my_count}"
p '----- my_count method w/Hash & argument / no arg / arg-proc -----'
puts "#{my_hash.count('a')}, #{my_hash.count}, #{my_hash.count(&bproc)}"
puts "#{my_hash.my_count('a')}, #{my_hash.my_count}, #{my_hash.my_count(&bproc)}"
p '----- my_count method w/Hash & block / arg -----'
puts "#{my_hash.count {|e| e.is_a?(Array) }}, #{my_hash.count(["a", 1])}"
puts "#{my_hash.my_count {|e| e.is_a?(Array) }}, #{my_hash.my_count(["a", 1])}"
p '----- my_count method w/Ranges num -----'
puts "#{(1..9).count(2)}, #{(1..9).count(&:odd?)}, #{(1..9).count(&aproc)}, #{(1..9).count { |e| e.zero? }}"
puts "#{(1..9).my_count(2)}, #{(1..9).my_count(&:odd?)}, #{(1..9).my_count(&aproc)}, #{(1..9).my_count { |e| e.zero? }}"
p '----- my_count method w/Ranges str -----'
puts "#{('A'..'E').count(2)}, #{('A'..'E').count('B')}, #{('A'..'E').count(&bproc)}, #{('A'..'E').count { |e| e.is_a?(String) }}"
puts "#{('A'..'E').my_count(2)}, #{('A'..'E').my_count('B')}, #{('A'..'E').my_count(&bproc)}, #{('A'..'E').my_count { |e| e.is_a?(String) }}"
p '======================================'
