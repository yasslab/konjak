require 'spec_helper'

describe Konjak do
  let(:sample_tmx) { File.read('spec/fixtures/sample.tmx') }

  subject { Konjak.parse(sample_tmx) }

  it { is_expected.to be_kind_of Konjak::Tmx }

  its(:version) { is_expected.to eq '1.4' }

  describe 'header' do
    subject { super().header }

    it { is_expected.to be_instance_of Konjak::Header }

    its(:creation_tool)         { is_expected.to eq 'XYZTool' }
    its(:creation_tool_version) { is_expected.to eq '1.01-023' }
    its(:data_type)             { is_expected.to eq 'PlainText' }
    its(:seg_type)              { is_expected.to eq 'sentence' }
    its(:admin_lang)            { is_expected.to eq 'en-us' }
    its(:src_lang)              { is_expected.to eq 'EN' }
    its(:o_tmf)                 { is_expected.to eq 'ABCTransMem' }
    its(:creation_date)         { is_expected.to eq '20020101T163812Z' }
    its(:creation_id)           { is_expected.to eq 'ThomasJ' }
    its(:change_date)           { is_expected.to eq '20020413T023401Z' }
    its(:change_id)             { is_expected.to eq 'Amity' }
    its(:o_encoding)            { is_expected.to eq 'iso-8859-1' }

    describe 'notes' do
      subject { super().notes }

      its(:size) { is_expected.to eq 1 }
      it { is_expected.to be_all {|n| n.instance_of? Konjak::Note } }

      describe '.first' do
        subject { super().first }

        its(:xml_lang) { is_expected.to eq 'en' }
        its(:o_encoding) { is_expected.to eq 'iso-8859-1' }
        its(:text) { is_expected.to be_instance_of Konjak::Text }

        describe 'text' do
          subject { super().text }

          its(:to_s) { is_expected.to eq 'This is a note at document level.' }
        end
      end
    end

    describe 'user_defined_encodings' do
      subject { super().user_defined_encodings }

      its(:size) { is_expected.to eq 1 }
      it { is_expected.to be_all {|n| n.instance_of? Konjak::UserDefinedEncoding } }

      describe '.first' do
        subject { super().first }

        its(:name) { is_expected.to eq 'MacRoman' }
        its(:base) { is_expected.to eq 'Macintosh' }

        describe '.map' do
          subject { super().maps }

          its(:size) { is_expected.to eq 1 }
          it { is_expected.to be_all {|n| n.instance_of? Konjak::Map } }

          describe '.first' do
            subject { super().first }

            its(:unicode)      { is_expected.to eq '#xF8FF' }
            its(:code)         { is_expected.to eq '#xF0' }
            its(:entity)       { is_expected.to eq 'Apple_logo' }
            its(:substitution) { is_expected.to eq '[Apple]' }
          end
        end
      end
    end

    describe 'properties' do
      subject { super().properties }

      its(:size) { is_expected.to eq 1 }
      it { is_expected.to be_all {|n| n.instance_of? Konjak::Property } }

      describe '.first' do
        subject { super().first }

        its(:xml_lang)   { is_expected.to eq 'en' }
        its(:o_encoding) { is_expected.to eq 'iso-8859-1' }
        its(:type)       { is_expected.to eq 'RTFPreamble' }
        its(:text)       { is_expected.to be_instance_of Konjak::Text }

        describe '.text' do
          subject { super().text }

          its(:to_s) { is_expected.to eq '{\rtf1\ansi\tag etc...{\fonttbl}' }
        end
      end
    end
  end

  describe 'body' do
    subject { super().body }

    it { is_expected.to be_instance_of Konjak::Body }

    describe 'translation_units' do
      subject { super().translation_units }

      its(:size) { is_expected.to eq 2 }
      it { is_expected.to be_all {|tu| tu.instance_of? Konjak::TranslationUnit } }

      describe 'translation unit 0001' do
        subject { super().detect {|tu| tu.tuid == '0001' } }

        its(:tuid)            { is_expected.to eq '0001' }
        its(:data_type)       { is_expected.to eq 'Text' }
        its(:usage_count)     { is_expected.to eq '2' }
        its(:last_usage_date) { is_expected.to eq '19970314T023401Z' }

        its('variants.size') { is_expected.to eq 2 }
        its(:variants) { is_expected.to be_all {|tuv| tuv.instance_of? Konjak::TranslationUnitVariant  } }

        describe '.variants.last' do
          subject { super().variants.last }

          its(:xml_lang)      { is_expected.to eq 'FR-CA' }
          its(:creation_date) { is_expected.to eq '19970309T021145Z' }
          its(:creation_id)   { is_expected.to eq 'BobW' }
          its(:change_date)   { is_expected.to eq '19970314T023401Z' }
          its(:change_id)     { is_expected.to eq 'ManonD' }

          its(:notes) { is_expected.to be_all {|note| note.instance_of? Konjak::Note } }
          its(:notes) { is_expected.to be_empty }
          its(:properties) { is_expected.to be_all {|prop| prop.instance_of? Konjak::Property } }
          its('properties.size') { is_expected.to eq 1 }
          its(:segment) { is_expected.to be_instance_of Konjak::Segment }

          describe '.segment' do
            subject { super().segment }

            its(:text) { is_expected.to be_instance_of Konjak::Text }

            describe '.text' do
              subject { super().text }

              its(:to_s) { is_expected.to eq "donn\u00E9es (avec un caract\u00E8re non standard: \uF8FF)." }
            end
          end
        end
      end
      describe 'translation unit 0002' do
        subject { super().detect {|tu| tu.tuid == '0002' } }

        its(:src_lang) { is_expected.to eq '*all*' }
      end
    end
  end

  describe 'gtt' do
    let(:xml) { File.read('spec/fixtures/gtt.tmx') }

    subject { tmx.body.translation_units.detect {|tu| tu.variants.detect {|v| v.segment.text.to_s == "\n\n& it's also example." } } }

    context 'gtt: true' do
      let(:tmx) { Konjak.parse(xml, gtt: true) }

      it { is_expected.to be_truthy }
    end

    context 'gtt: false' do
      let(:tmx) { Konjak.parse(xml, gtt: false) }

      it { is_expected.to be_falsey}
    end
  end
end
