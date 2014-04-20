require 'spec_helper'

describe Konjak do
  let(:sample_doc) { File.read(__FILE__).split('__END__').last }

  subject { Konjak.parse(sample_doc) }

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

    describe '#notes' do
      subject { super().notes }

      its(:size) { is_expected.to eq 1 }
      it { is_expected.to be_all {|n| n.instance_of? Konjak::Note } }
    end
  end

  describe 'body' do
    subject { super().body }

    it { is_expected.to be_instance_of Konjak::Body }
  end
end

# sample document from http://www.ttt.org/oscarstandards/tmx/#AppSample
__END__
<?xml version="1.0"?>
<!-- Example of TMX document -->
<tmx version="1.4">
<header
creationtool="XYZTool"
creationtoolversion="1.01-023"
datatype="PlainText"
segtype="sentence"
adminlang="en-us"
srclang="EN"
o-tmf="ABCTransMem"
creationdate="20020101T163812Z"
creationid="ThomasJ"
changedate="20020413T023401Z"
changeid="Amity"
o-encoding="iso-8859-1"
>
<note>This is a note at document level.</note>
<prop type="RTFPreamble">{\rtf1\ansi\tag etc...{\fonttbl}</prop>
<ude name="MacRoman" base="Macintosh">
 <map unicode="#xF8FF" code="#xF0" ent="Apple_logo" subst="[Apple]"/>
</ude>
</header>
<body>
<tu
 tuid="0001"
 datatype="Text"
 usagecount="2"
 lastusagedate="19970314T023401Z"
>
 <note>Text of a note at the TU level.</note>
 <prop type="x-Domain">Computing</prop>
 <prop type="x-Project">P&#x00E6;gasus</prop>
 <tuv
  xml:lang="EN"
  creationdate="19970212T153400Z"
  creationid="BobW"
 >
  <seg>data (with a non-standard character: &#xF8FF;).</seg>
 </tuv>
 <tuv
  xml:lang="FR-CA"
  creationdate="19970309T021145Z"
  creationid="BobW"
  changedate="19970314T023401Z"
  changeid="ManonD"
 >
  <prop type="Origin">MT</prop>
  <seg>donn&#xE9;es (avec un caract&#xE8;re non standard: &#xF8FF;).</seg>
 </tuv>
</tu>
<tu
 tuid="0002"
 srclang="*all*"
>
 <prop type="Domain">Cooking</prop>
 <tuv xml:lang="EN">
  <seg>menu</seg>
 </tuv>
 <tuv xml:lang="FR-CA">
  <seg>menu</seg>
 </tuv>
 <tuv xml:lang="FR-FR">
  <seg>menu</seg>
 </tuv>
</tu>
</body>
</tmx>
