RSpec.describe Indieweb::Authorship do
  let(:page) { 'h-entry-author-is-name' }
  let(:url) { "http://author.example.com/#{page}" }
  let(:html) { html_for(page) }
  let(:expected_data) do
    {
      'url' => nil,
      'name' => 'Author Name',
      'photo' => nil
    }
  end

  before do
    allow(Net::HTTP).to receive(:get).with(URI(url)) { html }
  end

  context 'when given just a URL' do
    it { expect(described_class.identify(url)).to eq expected_data }
  end

  context 'when given both a URL and HTML' do
    it { expect(described_class.identify(url, html)).to eq expected_data }
  end
end
