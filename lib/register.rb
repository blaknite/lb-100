##
# Represntation of a data register
#
# Can be of any number of bits.
# Only accepts integers whose binary representation is less or equal the register's bit length.
class Register < Array
  attr_reader :bits

  def initialize(bits, value = 0)
    @bits = bits
    set(value)
  end

  def set(new_value)
    fail 'value is not an integer' unless new_value.is_a?(Integer)
    replace(new_value.to_s(2).chars.last(bits).map(&:to_i))
    unshift(0) until length >= bits
  end

  def incr
    set(self.get + 1)
  end

  def decr
    set(self.get - 1)
  end

  def get
    join.to_i(2)
  end

  alias_method :to_int, :get
  alias_method :to_i, :get

  def to_s(base = 10)
    get.to_s(base)
  end

  def to_hex
    '0x' + to_s(16).rjust(bits / 4, "0")
  end

  def to_bin
    to_s(2).rjust(bits, "0")
  end
end
