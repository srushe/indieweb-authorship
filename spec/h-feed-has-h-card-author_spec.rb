RSpec.describe Indieweb::Authorship do
  let(:page) { 'h-feed-has-h-card-author' }
  let(:url) { "http://author.example.com/#{page}" }
  let(:html) { html_for(page) }
  let(:linked_url) { 'http://author.example.com/about' }
  let(:expected_data) do
    {
      'url' => 'http://author.example.com/about',
      'name' => 'Author',
      'photo' => 'http://author.example.com/photo.jpg'
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
