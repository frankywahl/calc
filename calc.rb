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

# run_tests = ENV.has_key? 'run_tests'
# run_tests and require 'minitest/autorun'

# calculate_examples = []
