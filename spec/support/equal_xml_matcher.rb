require 'rspec/expectations'

RSpec::Matchers.define :equal_xml do |expected|
  match do |actual|
    Nokogiri::XML(expected).to_s == Nokogiri::XML(actual).to_s
  end

  failure_message do |actual|
    actual_xml = Nokogiri::XML(actual).to_s
    expected_xml = Nokogiri::XML(expected).to_s

    "#{actual_xml}\n\nis not equal\n\n#{expected_xml}"
  end
end
