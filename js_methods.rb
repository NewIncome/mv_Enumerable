# frozen_string_literal: true

# rubocop:disable Style/LineLength, Style/StringLiterals, Style/CaseEquality

module Enumerable

  def my_each
    for e in self
      yield e if block_given?
    end
  end

end

my_hash = { "a": 1, "b": 2, "c": 3, "d": 4 }
my_array = %w[ a b c d e ]
# { "a": 1, "b": 2, "c": 3, "d": 4 }.my_each { |k, v| puts "key: #{k}, val: #{v}" }
# puts "true? #{e}, temp: #{temp}, acc: #{temp_arr}"
my_array.my_each { |k, v| p "key: #{k}, val: #{v}" }; puts
my_hash.my_each { |k, v| puts "key: #{k}, val: #{v}" }

# rubocop:enable Style/LineLength, Style/StringLiterals, Style/CaseEquality
# //cop  <-- configuration option
