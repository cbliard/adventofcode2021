# frozen_string_literal: true

require "benchmark"
require "rspec"
require "timeout"

PART_1_EXAMPLE_SOLUTION = 37
PART_2_EXAMPLE_SOLUTION = 168
TIMEOUT_SECONDS = 5

RSpec.describe "Day 7" do
  let(:sample_input) do
    <<~INPUT
      16,1,2,0,4,2,7,1,2,14
    INPUT
  end

  it "has sample input ready" do
    expect(sample_input).not_to match(/copy_sample_input_here/)
  end

  describe "solve_part1" do
    subject { solve_part1(sample_input).to_s }

    it { is_expected.to eq(PART_1_EXAMPLE_SOLUTION.to_s) }
  end

  if PART_2_EXAMPLE_SOLUTION
    describe "solve_part2" do
      subject { solve_part2(sample_input).to_s }

      it { is_expected.to eq(PART_2_EXAMPLE_SOLUTION.to_s) }
    end
  end
end

class Solver
  attr_reader :positions

  def initialize(positions, expensive_fuel: false)
    @costs = {}
    @positions = positions
    @expensive_fuel = expensive_fuel
  end

  def extra_fuel(distance)
    distance * (distance + 1) / 2
  end

  def cost(pos)
    @costs[pos] ||= positions
      .map { (pos - _1).abs }
      .map { @expensive_fuel ? extra_fuel(_1) : _1 }
      .sum
  end

  def optimum(from = positions.min, to = positions.max)
    mid = (from + to) / 2
    if cost(mid) > cost(mid + 1)
      optimum(mid + 1, to)
    elsif cost(mid) > cost(mid - 1)
      optimum(from, mid - 1)
    else
      cost(mid)
    end
  end
end

def solve_part1(input = nil)
  with(input) do |io|
    positions = io.readlines.first.split(",").map(&:to_i)
    solver = Solver.new(positions)
    solver.optimum
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    positions = io.readlines.first.split(",").map(&:to_i)
    solver = Solver.new(positions, expensive_fuel: true)
    solver.optimum
  end
end

def with(input)
  if input.nil?
    File.open(File.join(__dir__, "input.txt")) { |io| yield io }
  elsif input.is_a?(String)
    yield StringIO.new(input)
  else
    yield input
  end
end

def run_rspec
  RSpec.configure do |c|
    c.fail_fast = true
    c.formatter = "documentation"
    c.around(:each) do |example|
      Timeout.timeout(TIMEOUT_SECONDS) {
        example.run
      }
    end
  end
  rspec_result = RSpec::Core::Runner.run([])
  exit rspec_result if rspec_result != 0
end

def run_challenge
  [
    [1, PART_1_EXAMPLE_SOLUTION, :solve_part1],
    [2, PART_2_EXAMPLE_SOLUTION, :solve_part2]
  ].each do |part, part_implemented, solver|
    next unless part_implemented

    puts
    puts "==== PART #{part} ===="
    realtime = Benchmark.realtime do
      Timeout.timeout(TIMEOUT_SECONDS * 1000) do
        puts "answer: #{send(solver)}"
      end
    end
    puts "took: #{"%0.2f" % realtime}ms"
  end
end

if $0 == __FILE__
  run_rspec
  run_challenge
end
