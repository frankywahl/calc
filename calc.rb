require 'bigdecimal'

module Calc
  module_function

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

  # same as above but returns an enumerator, *not* an array, tokenization is done
  # "a little bit at time" whenever the caller calls `next` on the enumerator
  def tokenize_lazy(char_enumerator)
    Enumerator.new do |y|
      num_buffer = ''
      char_enumerator.each do |c|
        tokens, num_buffer = tokenize_step([[], num_buffer], c)
        tokens.each { |t| y.yield(t) }
      end
      tokens, = tokenize_step([[], num_buffer])
      tokens.each { |t| y.yield(t) }
    end
  end

  def space?(str)
    ' ' == str
  end

  # acc, chr -> acc
  # acc is a pair of token list and num buffer
  def tokenize_step(*args)
    if args.size <= 2
      send("tokenize_step_#{args.size}", *args)
    else
      raise ArgumentError("wrong number of args (#{args.size}), takes 0, 1 or 2")
    end
  end

  def tokenize_step_0
    [[], '']
  end

  def tokenize_step_1((token_list, num_buffer))
    token_list << parse_token(num_buffer) unless num_buffer.empty?
    [token_list, '']
  end

  def tokenize_step_2((token_list, num_buffer), chr)
    if NUMERIC.include?(chr)
      num_buffer += chr
    else
      token_list << parse_token(num_buffer) unless num_buffer.empty?
      token_list << parse_token(chr)
      num_buffer = ''
    end
    [token_list, num_buffer]
  end

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
end
