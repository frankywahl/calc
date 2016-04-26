require 'bigdecimal'

# original

# str -> num
def calculate(s)
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

# helpers

def reduce(coll, rblk)
  inital_mem = rblk.call
  penultimate_mem = coll.reduce(inital_mem, &rblk)
  rblk.call penultimate_mem # final
end

# tokenization concern

def tokenize(str)
  chrs_without_spaces = str
    .chars
    .reject(&method(:space?))

  reduce(chrs_without_spaces, method(:tokenize_step))
    .first
end

def space?(str)
  " " == str
end

# acc, chr -> acc
# acc: pair_of token_list and num buffer
def tokenize_step(*args)
  if args.length == 0 # initialize memo
    [[], ""]
  elsif args.length == 1 # finalize memo
    (token_list, num_buffer) = args.first
    token_list << parse_token(num_buffer) unless num_buffer.empty?
    [token_list, ""]
  else # do step
    (token_list, num_buffer), chr = args
    if NUMERIC.include?(chr)
      num_buffer += chr
    else
      token_list << parse_token(num_buffer) unless num_buffer.empty?
      token_list << parse_token(chr)
      num_buffer = ""
    end
    [token_list, num_buffer]
  end
end

NUMERIC = (0..9).map(&:to_s) + ['.']
OPERATORS_AND_PARENS = ["+", "-", "(", ")"]

# str -> token
def parse_token(str)
  if OPERATORS_AND_PARENS.include?(str)
    str.to_sym
  else
    BigDecimal.new(str)
  end
end

# tokenization tests

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



# apply an operation
# calculate a step of the total calculation

run_tests = ENV.has_key? 'run_tests'
run_tests and require 'minitest/autorun'

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
  { :given => "-1-1", :expect => -2 },
  { :given => "-1-1-1", :expect => -3 },
  { :given => "-1+(-1)", :expect => -2 },
  { :given => "-1+-1", :expect => -2 },
  { :given => "1+-1", :expect => 0 },
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
