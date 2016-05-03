require 'bigdecimal'

# original implemenation

# rubocop:disable all
# str -> num
def calculate_old(s)
  res, num, sign, stack = 0, 0, 1, [1]
  for i in (s + "+").chars
    if /\d/ =~ i
      num = 10 * num + i.to_i
    elsif "+-".include?(i)
      res += num * sign * stack[-1]
      sign = i=="+" ? 1 : -1
      num = 0
    elsif i == "("
      stack.push(sign * stack[-1])
      sign = 1
    elsif i == ")"
      res += num * sign * stack[-1]
      num = 0
      stack.pop()
    end
  end
  res
end
# rubocop:enable all

# helpers

def reduce(coll, rblk)
  inital_mem = rblk.call # initialize memo
  penultimate_mem = coll.reduce(inital_mem, &rblk) # run every step
  rblk.call penultimate_mem # finalize memo
end

# tokenization concern

def tokenize(str)
  chrs_without_spaces =
    str
    .chars
    .reject(&method(:space?))

  reduce(chrs_without_spaces, method(:tokenize_step))
    .first
end

def space?(str)
  ' ' == str
end

# acc, chr -> acc
# acc is a pair of token list and num buffer
def tokenize_step(*args) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/LineLength
  if args.empty? # initialize memo
    [[], '']
  elsif args.length == 1 # finalize memo
    token_list, num_buffer = args.first
    token_list << parse_token(num_buffer) unless num_buffer.empty?
    [token_list, '']
  else # do step
    (token_list, num_buffer), chr = args
    if NUMERIC.include?(chr)
      num_buffer += chr
    else
      token_list << parse_token(num_buffer) unless num_buffer.empty?
      token_list << parse_token(chr)
      num_buffer = ''
    end
    [token_list, num_buffer]
  end
end

# # lower "complexity"?
# def tokenize_step_0()
# end

NUMERIC = (0..9).map(&:to_s) + ['.']
OPERATORS_AND_PARENS = ['+', '-', '(', ')'].freeze

# str -> token
def parse_token(str)
  if OPERATORS_AND_PARENS.include?(str)
    str.to_sym
  else
    BigDecimal.new(str)
  end
end

def calculate(str)
  tokenized = tokenize(str)
  memo = reduce(tokenized, method(:calculate_step))
  memo.first
end

# - calculation concern

OPERATORS = [:+, :-].freeze

def calculate_step(*args)
  if args.empty?
    []
  elsif args.length == 1
    return args.first
  else
    stack, token = args
    if OPERATORS.include?(token) || token == :'('
      stack << token
    elsif token == :')'
      result = stack.pop
      stack.pop
      calculate_step(stack, result)
    else
      top = stack.last
      if OPERATORS.include?(top)
        operator = stack.pop
        stack << stack.pop.send(operator, token)
      else
        stack << token
      end
    end
  end
end

# - tests

# rubocop:disable all

run_tests = ENV.key? 'run_tests'
run_tests and require 'minitest/autorun'

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

run_tests && parse_token_examples.each do |eg|
  describe "#parse_token" do
    it eg.inspect do
      assert_equal eg[:expect], parse_token(eg[:given])
    end
  end
end

run_tests && tokenize_step_examples.each do |eg|
  describe "#tokenize_step" do
    it eg.inspect do
      assert_equal eg[:expect], tokenize_step(*eg[:given])
    end
  end
end

run_tests && tokenize_examples.each do |eg|
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

run_tests && calculate_examples.each do |eg|
  describe "#calculate" do
    it eg.inspect do
      assert_equal eg[:expect], calculate(eg[:given])
    end
  end
end

run_tests && calculate_step_examples.each do |eg|
  describe "#calculate_step" do
    it eg.inspect do
      assert_equal eg[:expect], calculate_step(*eg[:given])
    end
  end
end
# entry point

p tokenize(ARGV.first) if not run_tests and $PROGRAM_NAME == __FILE__
