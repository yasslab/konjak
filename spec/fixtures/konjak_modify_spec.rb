require 'spec_helper'

describe Konjak do
  let(:sample_tmx) { File.read('spec/fixtures/sample.tmx') }

  let(:tmx) { Konjak.parse(sample_tmx) }

  subject { tmx.to_xml }

  context 'not modified' do
    it { is_expected.to equal_xml(sample_tmx) }
  end

  context 'modified' do
    context 'element attribute' do
      before do
        tmx.header.change_id = 'john doe'
      end

      it { is_expected.not_to equal_xml(sample_tmx) }

      specify do
        expect(Konjak.parse(subject).header.change_id).to eq 'john doe'
      end
    end

    context 'segment text' do
      before do
        tu = tmx.body.translation_units.first
        tu.variant('EN').segment.content = 'hello world'
      end

      it { is_expected.not_to equal_xml(sample_tmx) }

      specify do
        tu = Konjak.parse(subject).body.translation_units.first
        expect(tu.variant('EN').segment.text).to eq 'hello world'
      end
    end
  end
end
