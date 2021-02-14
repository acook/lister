require "./spec_helper"

describe Themer do
  subject = Themer

  describe ".reset" do
    it "sets the terminal to normal" do
      subject.reset.to_s.should eq "\e[0m"
    end
  end

  describe ".warn" do
    it "sends output to stderr" do
      output = capture_stderr(
        <<-EOF
          require "../src/support/themer"
          Themer.warn "foobar"
        EOF
      )
      output.should contain "foobar"
    end
  end
end
