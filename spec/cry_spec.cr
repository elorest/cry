require "./spec_helper"

describe Cry do
  it "should evaluate command" do
    expected_result = %("Hello World"\n)
    Cry::Command.run([%("Hello World")])
    logs = `ls tmp/*_console_result.log`.strip.split(/\s/).sort
    File.read(logs.last?.to_s).should eq expected_result
  end

  it "executes a .cr file from the first command-line argument" do
    File.write "amber_exec_spec_test.cr", "puts([:a] + [:b])"
    Cry::Command.run(["amber_exec_spec_test.cr", "-e", "tail"])
    logs = `ls tmp/*_console_result.log`.strip.split(/\s/).sort
    File.read(logs.last?.to_s).should eq "[:a, :b]\n"
    File.delete("amber_exec_spec_test.cr")
  end

  it "opens editor and executes .cr file on close" do
    Cry::Command.run(["-e", "echo 'puts 1000' > "])
    logs = `ls tmp/*_console_result.log`.strip.split(/\s/).sort
    File.read(logs.last?.to_s).should eq "1000\n"
  end

  it "copies previous run into new file for editing and runs it returning results" do
    Cry::Command.run(["1337"])
    Cry::Command.run(["-e", "tail", "-b", "1"])
    logs = `ls tmp/*_console_result.log`.strip.split(/\s/).sort
    File.read(logs.last?.to_s).should eq "1337\n"
  end
end
