require "spec"
require "../../src/support/themer"

macro capture(program)
  {%
    filename = "#{__DIR__}/../../tmp/capture_stdout.cr"
    system("echo -e #{program} > #{filename}")
  %}
  {{
    run(filename).stringify
  }}
  {%
    system("rm #{filename}")
  %}
end

{% if env("CIRCLECI") %}
class UselessCircleCIShim
  def should(*args)
    true
  end
end
{% end %}

macro capture_stderr(program)
  {% if env("CIRCLECI") %}
  puts "CircleCI breaks functionality this tests requires"
  UselessCircleCIShim.new
  {% else %}

  {%
    filename = "#{__DIR__}/../../tmp/capture_stderr.cr"
    system("echo -e #{program.gsub(/\\n/, "\n")} > #{filename}")
  %}
  {{
    system("crystal run #{filename} 2>&1 > /dev/null").stringify
  }}
  {%
    system("rm #{filename}")
  %}
  {% end %}
end
