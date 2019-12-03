# frozen_string_literal: true

module Enumerable
  def my_each
    return to_enum(__method__) unless block_given?

    @i = 0
    while @i < size
      yield to_a[@i] if block_given?
      @i += 1
    end
  end

  def my_each_with_index
    return to_enum(__method__) unless block_given?

    my_each {|e| yield e, @i }
  end

  def my_select
    return to_enum(__method__) unless block_given?

    temp_arr = []
    my_each do |e|
      temp = yield e
      temp_arr << e if temp
    end
    temp_arr
  end

## Clone the Enumerable method:

  def my_all?(*vars)
    my_each { |e| return false unless yield e } if block_given?
    my_each { |e| return false if e == false || !e.nil? } if vars.empty?
    if vars[0].is_a?(Class)
      my_each { |e| return false unless e.is_a?(vars[0]) }
    else
      vars[0].is_a?(Regexp) ? my_each { |e| return false unless e =~ vars[0] } : my_each { |e| return false unless e == vars[0] }
    end
    true
  end

  def my_any?(*vars)
    !my_none?(*vars)
  end

  def my_none?(*vars)
    ans = true
    if block_given?
      my_each { |e| ans = false if yield e }
    elsif !vars.empty?
      if vars[0].is_a?(Class) # 2/4
        my_each { |e| ans = false if e.is_a?(vars[0]) }
      elsif vars[0].is_a?(Regexp) # 3/4
        my_each { |e| ans = false if e =~ vars[0] }
      else
        my_each { |e| ans = false if e == vars[0] } # 4/4
      end
    else
      my_each { |e| ans = false if e != false || e.nil? } # 1/4
    end
    ans
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
p 'my_none simple_w_hash'
p my_hash.none?
p my_hash.my_none?
p 'my_none 4 Class'
p [1, 2, 'b'].none?(Numeric)
p [1, 2, 'b'].my_none?(Numeric)
p 'my_none 4 Regex'
p %w[d 2d d].none?(/r/)
p %w[d 2d d].my_none?(/r/)
p 'my_none 4 Pattern'
p [3, 3, 2].none?(3)
p [3, 3, 2].my_none?(3)

p 'my_count'
puts([2, 3, 2].my_count(2))
puts([2, 3, 2].count(2))
puts([2, 3, 2].my_count { |e| (e % 3).zero? })
puts([2, 3, 2].count { |e| (e % 3).zero? })
puts([2, 3, 2].my_count)
puts([2, 3, 2].count)

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
# p '===================================='
# p '======== MY_ALL method tests ========'
# aproc = proc { |e| p "- #{e}" }
# p '----- my_all 4 e Arrays -----'
# puts "#{[1, 2, 3].all?}, #{[1, nil, 3].all?}, #{[nil, nil, nil].all?}"
# puts "#{[1, 2, 3].my_all?}, #{[1, nil, 3].my_all?}, #{[nil, nil, nil].my_all?}"
# p '----- my_all 4 e Hashes -----'
# puts my_hash.all?
# puts my_hash.my_all?
# p '----- my_all 4 Class -----'
# puts "#{[1, 2, 3].all?(Numeric)}, #{['1', '2', '3'].all?(Numeric)}"
# puts "#{[1, 2, 3].my_all?(Numeric)}, #{['1', '2', '3'].my_all?(Numeric)}"
# p '----- my_all 4 Regex -----'
# puts "#{%w[d 2d d].all?(/d/)}, #{%w[d 2d r].all?(/d/)}"
# puts "#{%w[d 2d d].my_all?(/d/)}, #{%w[d 2d r].my_all?(/d/)}"
# p '----- my_all 4 Pattern -----'
# puts "#{[3, 3, 3].all?(3)}, #{[3, 3, 2].all?(3)}"
# puts "#{[3, 3, 3].my_all?(3)}, #{[3, 3, 2].my_all?(3)}"
# p '----- my_all 4 Proc -----'
# puts "#{[2, 4, 6].all?(&aproc)}, #{[2, 4, 6].all?(&aproc)}"
# puts "#{[2, 4, 6].my_all?(&aproc)}, #{[2, 4, 6].my_all?(&aproc)}"
# p '===================================='

puts
p '===================================='
p '======== MY_EACH method tests ========'
p '----- MY_EACH w/my_array -----'
my_n_array.each { |e| print "elm: #{e + 2}; " }; puts
my_n_array.my_each { |e| print "elm: #{e + 2}; " }; puts
p my_n_array.each
p my_n_array.my_each
(1..4).each { |e| print "e: #{e}; " }; puts
(1..4).my_each { |e| print "e: #{e}; " }; puts
puts
p '----- MY_EACH w/my_hash -----'
my_hash.each { |e| print "elm: #{e}; " }; puts
my_hash.my_each { |e| print "elm: #{e}; " }; puts
p my_hash.each
p my_hash.my_each
puts
p '----- MY_EACH_with_index w/my_array -----'
my_n_array.each_with_index { |e, i| print "e: #{e}, i: #{i};  " }; puts
my_n_array.my_each_with_index { |e, i| print "e: #{e}, i: #{i};  " }; puts
p my_n_array.each_with_index
p my_n_array.my_each_with_index
puts
p '----- MY_EACH_with_index w/my_hash -----'
my_hash.each_with_index { |e, i| print "e: #{e}, i: #{i};  " }; puts
my_hash.my_each_with_index { |e, i| print "e: #{e}, i: #{i};  " }; puts
p my_hash.each_with_index
p my_hash.my_each_with_index
p '===================================='
