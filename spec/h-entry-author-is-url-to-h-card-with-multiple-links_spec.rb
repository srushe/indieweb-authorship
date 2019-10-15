RSpec.describe Indieweb::Authorship do
  let(:page) { 'h-entry-author-is-url-to-h-card-with-multiple-links' }
  let(:url) { "http://author.example.com/#{page}" }
  let(:html) { html_for(page) }
  let(:linked_url) { URI('http://author.example.com/about-with-multiple-urls') }
  let(:expected_data) do
    {
      'url' => 'http://author.example.com/about-with-multiple-urls',
      'name' => 'Author Full Name',
      'photo' => 'http://author.example.com/photo.jpg'
    }
  end

  before do
    allow(Net::HTTP).to receive(:get).with(URI(url)) { html }
    allow(Net::HTTP).to receive(:get).with(linked_url) { html_for('about-rel-me') }
  end

  context 'when given just a URL' do
    it { expect(described_class.identify(url)).to eq expected_data }
  end

  context 'when given both a URL and HTML' do
    it { expect(described_class.identify(url, html)).to eq expected_data }
  end

end
