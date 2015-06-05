require 'spec_helper'

describe Konjak do
  let(:sample_tmx) { File.read('spec/fixtures/sample.tmx') }

  let(:tmx) { Konjak.parse(sample_tmx) }

  context 'not modified' do
    subject { tmx.to_xml }

    it { is_expected.to equal_xml(sample_tmx) }
  end
end
