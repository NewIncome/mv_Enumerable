# frozen_string_literal: true
# rubocop:disable Style/LineLength, Style/StringLiterals, Style/CaseEquality

module Enumerable
  def my_each
    for e in self
      yield e
    end
  end
end

{"a":1, "b":2, "c":3, "d":4}.my_each { |e| puts e  }

# rubocop:enable Style/LineLength, Style/StringLiterals, Style/CaseEquality
# //cop  <-- configuration option
