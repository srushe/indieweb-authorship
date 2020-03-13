RSpec.describe Indieweb::Authorship do
  let(:page) { 'h-entry-has-h-card-with-no-photo' }
  let(:url) { "http://author.example.com/#{page}" }
  let(:html) { html_for(page) }
  let(:linked_url) { 'http://author.example.com/about' }
  let(:expected_data) do
    {
      'url' => 'http://author.example.com/about',
      'name' => 'Author',
      'photo' => nil
    }
  end

  before do
    allow(Net::HTTP).to receive(:get).with(URI(url)) { html }
    allow(Net::HTTP).to receive(:get).with(linked_url) { html_for('about') }
  end

  context 'when given just a URL' do
    it { expect(described_class.identify(url)).to eq expected_data }
  end

  context 'when given both a URL and HTML' do
    it { expect(described_class.identify(url, html)).to eq expected_data }
  end
end
