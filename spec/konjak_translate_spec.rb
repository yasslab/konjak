require 'spec_helper'

describe Konjak do

  let(:sample_tmx) { File.read('spec/fixtures/sample.tmx') }
  let(:doc) { <<DOC }
this is data (with a non-standard character: ).
this is data (with a non-standard character: ).
DOC

  subject { Konjak.translate(doc, sample_tmx, 'EN', 'FR-CA') }

  it { is_expected.to eq <<EXPECT }
this is données (avec un caractère non standard: ).
this is données (avec un caractère non standard: ).
EXPECT

end
