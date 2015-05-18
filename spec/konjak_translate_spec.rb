require 'spec_helper'

describe Konjak do

  let(:sample_tmx) { File.read('spec/fixtures/sample.tmx') }
  let(:doc) { <<DOC }
this is data (with a non-standard character: ).
this is data (with a non-standard character: ).
DOC

  subject { Konjak.translate(doc, sample_tmx, 'EN', 'FR-CA').join }

  it { is_expected.to eq <<EXPECT }
this is données (avec un caractère non standard: ).
this is données (avec un caractère non standard: ).
EXPECT

  context 'when passed Tmx' do
    subject { Konjak.translate(doc, Konjak.parse(sample_tmx), 'EN', 'FR-CA').join }

    it { is_expected.to eq <<EXPECT }
this is données (avec un caractère non standard: ).
this is données (avec un caractère non standard: ).
EXPECT
  end

  context 'when format is GTT' do
    let(:gtt_tmx) { Konjak.parse(File.read('spec/fixtures/gtt.tmx')) }

    let(:doc) { <<GTT_HTML }
This is <a href="http://example.com">example</a>.
And This is <b>example</b>. Yey.
And This is example.
GTT_HTML

    subject { Konjak.translate(doc, gtt_tmx, 'en', 'ja', format: :gtt_html).join }

    it { is_expected.to eq <<EXPECT }
これは、 <a href="http://example.com">例</a> 。
And これは、 <b>例</b> 。 Yey.
And This is example.
EXPECT
  end
end
