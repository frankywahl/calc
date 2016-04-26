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


tokenize_step_examples = [
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

calculate_examples.each do |eg|
  describe "#calculate" do
    it eg.inspect do
      assert_equal eg[:expect], calculate(eg[:given])
    end
  end
end
