if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'konjak'

# spec/fixtures/sample.tmx from http://www.ttt.org/oscarstandards/tmx/#AppSample
