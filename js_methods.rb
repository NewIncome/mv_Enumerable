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

  def my_map(&zproc)
    arr = []
    if block_given? && zproc.is_a?(Proc)
      my_each { |e| arr << zproc.call(e) }
      arr
    elsif block_given?
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
        acc = block_given? ? (yield acc, e) : acc.send(sym, e)
      end
    else
      to_enum(__method__)
    end
    acc
  end
end

def multiply_els(arr)
  arr.my_inject(:*)
end
