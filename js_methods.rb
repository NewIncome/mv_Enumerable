# frozen_string_literal: true

# rubocop:disable Style/StringLiterals, Style/AndOr, CyclomaticComplexity, PerceivedComplexity, ModuleLength

module Enumerable
  def my_each
    return to_enum(__method__) unless block_given?

    i = 0
    while i < length
      yield to_a[i] if block_given?
      i += 1
    end
  end

  def my_each_with_index
    return to_enum(__method__) unless block_given?

    i = 0
    while i < length
      yield to_a[i], i if block_given?
      i += 1
    end
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

  def my_all?(*vars)
    ans = true
    if block_given?
      my_each { |e| ans = false unless yield e }
    elsif !vars.empty?
      if vars[0].is_a?(Class) # 2/4
        my_each { |e| ans = false unless e.is_a?(vars[0]) }
      elsif vars[0].is_a?(Regexp) # 3/4
        my_each { |e| ans = false unless e =~ vars[0] }
      else
        my_each { |e| ans = false unless e == vars[0] } # 4/4
      end
    else
      my_each { |e| ans = false if e == false || e.nil? } # 1/4
    end
    ans
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
    # why can't use *char directly???
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
        acc = e and next if acc.nil? # to not sum 2times 1st value
        acc = if block_given? # because if and else asign to the same variable
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
p '----- my_each_with_index method -----'
my_hash.each_with_index { |k, v| p "key: #{k}, val: #{v}" }
my_hash.my_each_with_index { |k, v| p "key: #{k}, val: #{v}" }
p 'my_select'
puts([1, 2, 3, 4, 5].my_select(&:odd?))
puts([1, 2, 3, 4, 5].select(&:odd?))
puts([1, 2, 3, 4, 5].my_select)
puts([1, 2, 3, 4, 5].select)
p 'my_all?'
puts([2, 4, 6].my_all?(&:even?))
p 'my_any?'
puts([2, 4, 6].my_any?(&:odd?))
p 'my_none?'
puts([2, 4, 6].my_none?(&:odd?))
p 'my_count'
puts([2, 3, 2].my_count(2))
puts([2, 3, 2].count(2))

my_n_array.each { |e| print "e+2: #{e + 2};" }
my_n_array.my_each { |e| p "e+2: #{e + 2}" }
my_n_array.each
my_n_array.my_each
p '----- map method -----'
p(my_n_array.map { |e| e * 2 })
p(my_n_array.my_map { |e| e * 2 })
p my_n_array.map
p my_n_array.my_map
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
p '----- multiply_els -----'
p multiply_els([2, 4, 5])
p '----- my_map method with Proc -----'
bproc = proc { |e| p "Test: #{e}" }
[1, 2, ""].my_map_bproc(&bproc)
[1, 2, ""].my_map_bproc { |e| p "Test: #{e}" }
[1, 2, ""].my_map(&bproc)
[1, 2, ""].my_map { |e| p "Test: #{e}" }
[1, 2, ""].map(&bproc)
[1, 2, ""].map { |e| p "Test: #{e}" }
# .send   , checkITout
puts '--- .each & my_each with hash ---'
my_hash.each { |k, v| p "#{k}, #{v}" }
my_hash.my_each { |k, v| p "#{k}, #{v}" }
my_hash.each { |k| p k }
my_hash.my_each { |k| p k }
puts '--- .each & my_each with array ---'
my_n_array.each { |k, v| p "#{k}, #{v}" }
my_n_array.my_each { |k, v| p "#{k}, #{v}" }

p my_hash.all?
p my_hash.my_all?
p 'my_all 4 Class'
p [1, 2, 3].all?(Numeric)
p [1, 2, 3].my_all?(Numeric)
p 'my_all 4 Regex'
p %w[d 2d d].all?(/r/)
p %w[d 2d d].my_all?(/r/)
p 'my_all 4 Pattern'
p [3, 3, 2].all?(3)
p [3, 3, 2].my_all?(3)

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

puts
p 'my_any simple_w_hash'
p my_hash.any?
p my_hash.my_any?
p 'my_any 4 Class'
p [1, 2, 'd'].any?(Numeric)
p [1, 2, 'd'].my_any?(Numeric)
p 'my_any 4 Regex'
p %w[d 2d d].any?(/r/)
p %w[d 2d d].my_any?(/r/)
p 'my_any 4 Pattern'
p [3, 3, 2].any?(3)
p [3, 3, 2].my_any?(3)

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
# rubocop:enable Style/StringLiterals, Style/AndOr, CyclomaticComplexity, PerceivedComplexity, ModuleLength
# //cop  <-- configuration option
