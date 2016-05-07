# rubocop:disable all
require 'minitest/autorun'
require_relative 'calc'
require 'pry'

# -- tests: tokenize

parse_token_examples = [
  { given: "1", expect: 1 },
  { given: "1.5", expect: 1.5 },
  { given: "+", expect: :+ },
  { given: "(", expect: :"(" }
]

tokenize_step_examples = [
  # todo: test for arity 0
  # todo: test for arity 1
  # todo: negative number tokens
  {given: [[[], ""], "1"], expect: [[], "1"] },
  {given: [[[], "1"], "1"], expect: [[], "11"] },
  {given: [[[], "1"], "+"], expect: [[1, :+], ""] },
  {given: [[[], "1"], "-"], expect: [[1, :-], ""] },
  {given: [[[], "1"], "."], expect: [[], "1."] },
  {given: [[[], "1"], "."], expect: [[], "1."] },
  {given: [[[], "1."], "5"], expect: [[],"1.5"] },
  {given: [[[3], "1."], "5"], expect: [[3],"1.5"] },
  {given: [[[3, :+], "1"], ")"], expect: [[3, :+, 1, :")"],""] }, # This will never happen, but ensure tokenize_step is independent of calculate
]

# separate parsing from calculations

tokenize_examples = [
  { given: "0", expect: [0] },
  { given: "1 + 1", expect: [1, :+, 1] },
  # todo: negative number tokens
  { given: "1+-1", expect: [1, :+, -1] },
  { given: "1 - 1", expect: [1, :-, 1] },
  { given: "1 + (1 + 1)", expect: [1, :+, :'(', 1, :+, 1, :')'] }
]

calculate_step_examples = [
  # push, because input is an operand (and our stack doesn't have an operand and operator as last two elements)
  { given: [[], 1], expect: [1]},
  # push, because input is an operator
  { given: [[1], :+], expect: [1, :+]},
  # push, because input is an open paren
  { given: [[1, :+], :"("], expect: [1, :+, :"("]},
  # push, because input is an operand (and our stack doesn't have an operand and operator as last two elements)
  { given: [[1, :+, :"("], 2], expect: [1, :+, :"(", 2]},
  # push, because input is an operator
  { given: [[1, :+, :"(", 2], :-], expect: [1, :+, :"(", 2, :-]},
  # evaluate, because input is an operand and our stack has an operand and operator as last two elements
  { given: [[1, :+, :"(", 2, :-], 3], expect: [1, :+, :"(", -1]},
  # pop both operand and open paren, discard open paren and then recur with operand as input
  { given: [[1, :+, :"(", -1], :")"], expect: [0]}
]


parse_token_examples.each do |eg|
  describe "#parse_token" do
    it eg.inspect do
      assert_equal eg[:expect], parse_token(eg[:given])
    end
  end
end

tokenize_step_examples.each do |eg|
  describe "#tokenize_step" do
    it eg.inspect do
      assert_equal eg[:expect], tokenize_step(*eg[:given])
    end
  end
end

tokenize_examples.each do |eg|
  describe "#tokenize" do
    it eg.inspect do
      assert_equal eg[:expect], tokenize(eg[:given])
    end
  end
end

# -- tests: calculate (original implemenation)

calculate_examples = [
  { :given => "0", :expect => 0 },
  { :given => "1+1", :expect => 2 },
  { :given => "1+1+1", :expect => 3 },
  { :given => "1-1", :expect => 0 },
  { :given => "10000000000000000 + 1", :expect => 10000000000000001 },
  { :given => "(1 - 2) - 2", :expect => -3 },
  { :given => "2 - (1 - 2)", :expect => 3 },
  { :given => "(1 - (1 - 2)) - 2", :expect => 0 },
  { :given => "(1 + 1) + (1 + 1)", :expect => 4 },
  { :given => "(1) + (1 + 1)", :expect => 3 },
  { :given => "(1 - 3) - (2 + 3)", :expect => -7 },
  { :given => "(1) + (1)", :expect => 2 },
  { :given => "((1))", :expect => 1 },
  { :given => "(1 + (2 + (3)))", :expect => 6 },
  { :given => "(1 + (1 - (1 + 1)))", :expect => 0 },
  { :given => "(1 + (1 - (1 + 1)))", :expect => 0 },
  # { :given => "-1-1", :expect => -2 },
  # { :given => "-1-1-1", :expect => -3 },
  # { :given => "-1+(-1)", :expect => -2 },
  # { :given => "-1+-1", :expect => -2 },
  # { :given => "1+-1", :expect => 0 },
  # { :given => "-1--1", :expect => 0 }, TODO: fix this later
  # { :given => "1+1.1", :expect => 2.1 }, TODO: fix this
]

calculate_examples.each do |eg|
  describe "#calculate" do
    it eg.inspect do
      assert_equal eg[:expect], calculate(eg[:given])
    end
  end
end

calculate_step_examples.each do |eg|
  describe "#calculate_step" do
    it eg.inspect do
      assert_equal eg[:expect], calculate_step(*eg[:given])
    end
  end
end
