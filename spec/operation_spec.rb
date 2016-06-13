require 'computer'
require 'operation'

RSpec.describe Operation do
  describe 'from_instruction' do
    it 'initializes an operation from an opcode' do
      computer = Computer.new
      operation = Operation.from_opcode(0x0, computer)

      expect(operation).to be_a(Operation)
    end
  end
end

RSpec.describe Operation::NOP do
  describe 'clock' do
    it 'increments the program counter' do
      computer = Computer.new
      operation = Operation::NOP.new(computer)
      8.times{ operation.clock }

      expect(computer.pc.value).to eq(1)
    end
  end

  describe 'complete?' do
    it 'returns false unless all steps are complete' do
      computer = Computer.new
      operation = Operation::NOP.new(computer)

      expect(operation.complete?).to eq(false)
    end

    it 'returns true when all steps are complete' do
      computer = Computer.new
      operation = Operation::NOP.new(computer)
      8.times{ operation.clock }

      expect(operation.complete?).to eq(true)
    end
  end
end

RSpec.describe Operation::JMP do
  it 'changes the value of the program counter' do
    computer = Computer.new
    operation = Operation::JMP.new(computer)

    computer.ram[0x001].value = 0x0
    computer.ram[0x002].value = 0x4
    computer.ram[0x003].value = 0xc

    expect(computer.pc.value).to eq(0x0)

    operation.clock until operation.complete?

    expect(computer.pc.value).to eq(0x04c)
  end
end

RSpec.describe Operation::JC do
  it 'does not change the value of the program counter if carry is 0' do
    computer = Computer.new
    operation = Operation::JC.new(computer)

    computer.ram[0x001].value = 0x0
    computer.ram[0x002].value = 0x4
    computer.ram[0x003].value = 0xc
    computer.c.value = 0

    expect(computer.pc.value).to eq(0x0)

    operation.clock until operation.complete?

    expect(computer.pc.value).to eq(0x004)
  end

  it 'changes the value of the program counter if carry is 1' do
    computer = Computer.new
    operation = Operation::JC.new(computer)

    computer.ram[0x001].value = 0x0
    computer.ram[0x002].value = 0x4
    computer.ram[0x003].value = 0xc
    computer.c.value = 1

    expect(computer.pc.value).to eq(0x0)

    operation.clock until operation.complete?

    expect(computer.pc.value).to eq(0x04c)
  end
end

RSpec.describe Operation::JZ do
  it 'does not change the value of the program counter if zero is 0' do
    computer = Computer.new
    operation = Operation::JZ.new(computer)

    computer.ram[0x001].value = 0x0
    computer.ram[0x002].value = 0x4
    computer.ram[0x003].value = 0xc
    computer.z.value = 0

    expect(computer.pc.value).to eq(0x0)

    operation.clock until operation.complete?

    expect(computer.pc.value).to eq(0x004)
  end

  it 'changes the value of the program counter if zero is 1' do
    computer = Computer.new
    operation = Operation::JZ.new(computer)

    computer.ram[0x001].value = 0x0
    computer.ram[0x002].value = 0x4
    computer.ram[0x003].value = 0xc
    computer.z.value = 1

    expect(computer.pc.value).to eq(0x0)

    operation.clock until operation.complete?

    expect(computer.pc.value).to eq(0x04c)
  end
end

RSpec.describe Operation::LD do
  describe 'perform' do
    it 'changes the value of the accumulator' do
      computer = Computer.new
      operation = Operation::LD.new(computer)

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = 0x4

      expect(computer.a.value).to eq(0x0)

      operation.clock until operation.complete?

      expect(computer.a.value).to eq(0x4)
    end
  end
end

RSpec.describe Operation::LDI do
  describe 'perform' do
    it 'changes the value of the accumulator' do
      computer = Computer.new
      operation = Operation::LDI.new(computer)

      computer.ram[0x001].value = 0x4

      expect(computer.a.value).to eq(0x0)

      operation.clock until operation.complete?

      expect(computer.a.value).to eq(0x4)
    end
  end
end

RSpec.describe Operation::ST do
  describe 'perform' do
    it 'stores the value of the accumulator' do
      computer = Computer.new
      operation = Operation::ST.new(computer)

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.a.value = 0x4

      operation.clock until operation.complete?

      expect(computer.ram[0x04c].value).to eq(0x4)
    end
  end
end

RSpec.describe Operation::STC do
  describe 'perform' do
    it 'sets the carry flag to 1' do
      computer = Computer.new
      operation = Operation::STC.new(computer)

      computer.ram[0x001].value = 1

      operation.clock until operation.complete?

      expect(computer.c.value).to eq(1)
    end

    it 'sets the carry flag to 0' do
      computer = Computer.new
      operation = Operation::STC.new(computer)

      computer.c.value = 0
      computer.ram[0x001].value = 0

      operation.clock until operation.complete?

      expect(computer.c.value).to eq(0)
    end
  end
end

RSpec.describe Operation::IN do
  describe 'perform' do
    it 'changes the value of the accumulator' do
      computer = Computer.new
      operation = Operation::IN.new(computer)

      computer.in[0x0].value = 0x4
      computer.ram[0x001].value = 0x0

      expect(computer.a.value).to eq(0x0)

      operation.clock until operation.complete?

      expect(computer.a.value).to eq(0x4)
    end
  end
end

RSpec.describe Operation::OUT do
  describe 'perform' do
    it 'changes the value of the output' do
      computer = Computer.new
      operation = Operation::OUT.new(computer)

      computer.ram[0x001].value = 0x0
      computer.a.value = 0x4

      expect(computer.out[0x0].value).to eq(0x0)

      operation.clock until operation.complete?

      expect(computer.out[0x0].value).to eq(0x4)
    end
  end
end

RSpec.describe Operation::NOR do
  describe 'perform' do
    it 'performs a NOR of the operand and accumulator' do
      computer = Computer.new
      operation = Operation::NOR.new(computer)

      computer.a.value = "0000".to_i(2)

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = "0101".to_i(2)

      operation.clock until operation.complete?

      expect(computer.a.to_bin).to eq("1010")
    end

    it 'sets the zero flag to 1 if the result is 0' do
      computer = Computer.new
      operation = Operation::NOR.new(computer)

      computer.a.value = "1010".to_i(2)

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = "0101".to_i(2)

      operation.clock until operation.complete?

      expect(computer.z.value).to eq(1)
    end

    it 'sets the zero flag to 0 if the result is not 0' do
      computer = Computer.new
      operation = Operation::NOR.new(computer)

      computer.a.value = "0000".to_i(2)

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = "0101".to_i(2)

      operation.clock until operation.complete?

      expect(computer.z.value).to eq(0)
    end

    it 'sets the zero flag to 0' do
      computer = Computer.new
      operation = Operation::ADDI.new(computer)

      computer.c.value = 1

      operation.clock until operation.complete?

      expect(computer.c.value).to eq(0)
    end
  end
end

RSpec.describe Operation::ADD do
  describe 'perform' do
    it 'adds the operand and the accumulator' do
      computer = Computer.new
      operation = Operation::ADD.new(computer)

      computer.a.value = 0x4

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = 0x4

      operation.clock until operation.complete?

      expect(computer.a.value).to eq(0x8)
    end

    it 'sets the carry flag to 0 if the result is smaller than 4 bits' do
      computer = Computer.new
      operation = Operation::ADD.new(computer)

      computer.a.value = 0x4

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = 0x4

      operation.clock until operation.complete?

      expect(computer.c.value).to eq(0)
    end

    it 'sets the carry flag to 1 if the result is larger than 4 bits' do
      computer = Computer.new
      operation = Operation::ADD.new(computer)

      computer.a.value = 0xf

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = 0x4

      operation.clock until operation.complete?

      expect(computer.c.value).to eq(1)
    end

    it 'sets the zero flag to 0 if the result is not 0' do
      computer = Computer.new
      operation = Operation::ADD.new(computer)

      computer.a.value = 0x4

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = 0x4

      operation.clock until operation.complete?

      expect(computer.z.value).to eq(0)
    end

    it 'sets the zero flag to 1 if the result is 0' do
      computer = Computer.new
      operation = Operation::ADD.new(computer)

      computer.a.value = 0xf

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = 0x1

      operation.clock until operation.complete?

      expect(computer.z.value).to eq(1)
    end
  end
end

RSpec.describe Operation::ADDI do
  describe 'perform' do
    it 'adds the operand and the accumulator' do
      computer = Computer.new
      operation = Operation::ADDI.new(computer)

      computer.a.value = 0x4
      computer.ram[0x001].value = 0x4

      operation.clock until operation.complete?

      expect(computer.a.value).to eq(0x8)
    end

    it 'sets the carry flag to 0 if the result is smaller than 4 bits' do
      computer = Computer.new
      operation = Operation::ADDI.new(computer)

      computer.a.value = 0x4
      computer.ram[0x001].value = 0x4

      operation.clock until operation.complete?

      expect(computer.c.value).to eq(0)
    end

    it 'sets the carry flag to 1 if the result is larger than 4 bits' do
      computer = Computer.new
      operation = Operation::ADDI.new(computer)

      computer.a.value = 0xf
      computer.ram[0x001].value = 0x4

      operation.clock until operation.complete?

      expect(computer.c.value).to eq(1)
    end

    it 'sets the zero flag to 0 if the result is not 0' do
      computer = Computer.new
      operation = Operation::ADDI.new(computer)

      computer.a.value = 0x4
      computer.ram[0x001].value = 0x4

      operation.clock until operation.complete?

      expect(computer.z.value).to eq(0)
    end

    it 'sets the zero flag to 1 if the result is 0' do
      computer = Computer.new
      operation = Operation::ADDI.new(computer)

      computer.a.value = 0xf
      computer.ram[0x001].value = 0x1

      operation.clock until operation.complete?

      expect(computer.z.value).to eq(1)
    end
  end
end

RSpec.describe Operation::CMP do
  describe 'perform' do
    it 'does not change the accumulator' do
      computer = Computer.new
      operation = Operation::CMP.new(computer)

      computer.a.value = 0x4

      operation.clock until operation.complete?

      expect(computer.a.value).to eq(0x4)
    end

    it 'sets the carry flag to 0 if the result is smaller than 4 bits' do
      computer = Computer.new
      operation = Operation::CMP.new(computer)

      computer.a.value = 0x4

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = 0x4

      operation.clock until operation.complete?

      expect(computer.c.value).to eq(0)
    end

    it 'sets the carry flag to 1 if the result is larger than 4 bits' do
      computer = Computer.new
      operation = Operation::CMP.new(computer)

      computer.a.value = 0x1

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = 0xf

      operation.clock until operation.complete?

      expect(computer.c.value).to eq(1)
    end

    it 'sets the zero flag to 0 if the operand and the accumulator are not equal' do
      computer = Computer.new
      operation = Operation::CMP.new(computer)

      computer.a.value = 0x4

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = 0x2

      operation.clock until operation.complete?

      expect(computer.z.value).to eq(0)
    end

    it 'sets the zero flag to 1 if the operand and the accumulator are equal' do
      computer = Computer.new
      operation = Operation::CMP.new(computer)

      computer.a.value = 0x4

      computer.ram[0x001].value = 0x0
      computer.ram[0x002].value = 0x4
      computer.ram[0x003].value = 0xc

      computer.ram[0x04c].value = 0x4

      operation.clock until operation.complete?

      expect(computer.z.value).to eq(1)
    end
  end
end

RSpec.describe Operation::CMPI do
  describe 'perform' do
    it 'does not change the accumulator' do
      computer = Computer.new
      operation = Operation::CMPI.new(computer)

      computer.a.value = 0x4

      operation.clock until operation.complete?

      expect(computer.a.value).to eq(0x4)
    end

    it 'sets the carry flag to 0 if the result is smaller than 4 bits' do
      computer = Computer.new
      operation = Operation::CMPI.new(computer)

      computer.a.value = 0x4
      computer.ram[0x001].value = 0x4

      operation.clock until operation.complete?

      expect(computer.c.value).to eq(0)
    end

    it 'sets the carry flag to 1 if the result is larger than 4 bits' do
      computer = Computer.new
      operation = Operation::CMPI.new(computer)

      computer.a.value = 0x1
      computer.ram[0x001].value = 0xf

      operation.clock until operation.complete?

      expect(computer.c.value).to eq(1)
    end

    it 'sets the zero flag to 0 if the operand and the accumulator are not equal' do
      computer = Computer.new
      operation = Operation::CMPI.new(computer)

      computer.a.value = 0x4
      computer.ram[0x001].value = 0x8

      operation.clock until operation.complete?

      expect(computer.z.value).to eq(0)
    end

    it 'sets the zero flag to 1 if the operand and the accumulator are equal' do
      computer = Computer.new
      operation = Operation::CMPI.new(computer)

      computer.a.value = 0x4
      computer.ram[0x001].value = 0x4

      operation.clock until operation.complete?

      expect(computer.z.value).to eq(1)
    end
  end
end