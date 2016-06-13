require 'operation'
require 'register'

class Computer
  attr_reader :accumulator, :carry, :input, :output, :operation, :program_counter, :ram, :zero

  alias_method :a, :accumulator
  alias_method :c, :carry
  alias_method :in, :input
  alias_method :out, :output
  alias_method :op, :operation
  alias_method :pc, :program_counter
  alias_method :z, :zero

  def initialize
    @accumulator = Register.new(4)
    @carry = Register.new(1)
    @input = []
    @output = []
    16.times do
      @input << Register.new(4)
      @output << Register.new(4)
    end
    @program_counter = Register.new(12)
    @ram = []
    4096.times{ @ram << Register.new(4) }
    @zero = Register.new(1)
  end
end