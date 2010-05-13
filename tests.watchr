# Run me with:
#
#   $ watchr specs.watchr
#

# --------------------------------------------------
# Environment fiddling, i.e. which ruby/rake binaries to use
# --------------------------------------------------
ruby_bin = (ARGV.find { |e| e =~ /^RUBY_BIN=(.+)$/ } || "ruby").gsub(/^RUBY_BIN=/, '')
rake_bin = (ARGV.find { |e| e =~ /^RAKE_BIN=(.+)$/} || "rake").gsub(/^RAKE_BIN=/, '')

if ARGV.last == "ruby19"
  ruby_bin, rake_bin = "ruby19", "rake19"
elsif ARGV.last == "jruby"
  ruby_bin, rake_bin = "jruby", "jrake"
end

$RUBY_BINARY = ruby_bin

# --------------------------------------------------
# Growl support, if available
# --------------------------------------------------
def run_and_notify(cmd)
  result = `#{cmd}`
  puts result

  if system("growlnotify -v 1>/dev/null")
    platform = `#{$RUBY_BINARY} -e 'puts (RUBY_PLATFORM =~ /java/ ? "jruby-" : "") + RUBY_VERSION'`.chomp
    message = result.split("\n").select { |l| l =~ /\d+ tests, \d+ asser/ }.join("\n").gsub(/\e\[(?:[34][0-7]|[0-9])?m/, '')
    status = (message =~ /[1-9]\d* failures/ or message =~ /[1-9]\d* errors/) ? "FAILURE" : "SUCCESS"
    system "growlnotify -w -n Watchr --image '.#{status.downcase}.png' -m '#{message}' 'vacuum_cleaner:#{platform} #{status}' &"
  end
end

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch( '^lib/vacuum_cleaner/normalizations/active_support.rb' ) { |m| run_and_notify "#{ruby_bin} -Ilib:test test/integration/active_support_*_test.rb" }
watch( '^lib/vacuum_cleaner/(.*)\.rb' )   { |m| run_and_notify "#{ruby_bin} -Ilib:test test/unit/vacuum_cleaner/%s_test.rb" % m[1]                      }
watch( '^lib/vacuum_cleaner\.rb'      )   { |m| run_and_notify "#{rake_bin} -s test:unit"         }
watch( '^test/*/.*_test\.rb'          )   { |m| run_and_notify "#{ruby_bin} -Ilib:test %s" % m[0] }
watch( '^test/test_helper\.rb'        )   { |m| run_and_notify "#{rake_bin} -s test:unit"         }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
# Ctrl-\
Signal.trap('QUIT') do
  puts " --- Running all unit and integration tests ---\n\n"
  run_and_notify "#{rake_bin} -s test:all"
end

# Ctrl-C
Signal.trap('INT') { abort("\n") }
