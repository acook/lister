require "spec"
require "../../src/support/themer"

macro capture(program)
  {%
    filename = "#{__DIR__}/../../tmp/capture_stdout.cr"
    system("echo #{program} > #{filename}")
  %}
  {{
    run(filename).stringify
  }}
  {%
    system("rm #{filename}")
  %}
end

macro capture_stderr(program)
  {%
    filename = "#{__DIR__}/../../tmp/capture_stderr.cr"
    system("echo #{program} > #{filename}")
  %}
  {{
    system("crystal run #{filename} 2>&1 > /dev/null").stringify
  }}
  {%
    system("rm #{filename}")
  %}
end
