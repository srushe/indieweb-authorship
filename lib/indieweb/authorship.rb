# frozen_string_literal: true

require 'indieweb/authorship/version'
require 'microformats'
require 'net/http'

module Indieweb
  module Authorship
    def self.identify(url, html = nil)
      collection = microformats_from(html: html, url: url)

      # 1. start with a particular h-entry to determine authorship for, and
      #    no author. if no h-entry, then there's no post to find authorship
      #    for, abort.
      h_entry = hentry_from(collection['items'])
      return if h_entry.nil?

      # 3. if the h-entry has an author property, use that
      if h_entry['properties'].key?('author')
        author_data = h_entry['properties']['author']
      end

      # 4. otherwise if the h-entry has a parent h-feed with author property
      #    use that - TODO
      if author_data.nil?
        author_data = h_feed_author_for(h_entry, items: collection['items'])
      end

      # 5. if an author property was found
      unless author_data.nil?
        hcard = author_data.find { |entry| hcard?(entry) }

        # 5.1. if it has an h-card, use it, exit.
        if !hcard.nil?
          return hcard_data_for(
            URI.join(url, hcard['properties']['url'][0]).to_s,
            hcard['properties']['name'][0],
            URI.join(url, hcard['properties']['photo'][0]).to_s
          )

        # 5.2. otherwise if author property is an http(s) URL, let the
        #      author-page have that URL
        elsif author_data[0].start_with?('http://', 'https://')
          return find_author_from(url: author_data[0],
                                  original_page_items: collection['items'])

        # 5.3. otherwise use the author property as the author name, exit
        else
          return hcard_data_for(nil, author_data[0], nil)
        end
      end

      # 6. if there is no author-page and the h-entry's page is a permalink
      #    page, then
      # 6.1. if the page has a rel-author link, let the author-page's URL
      #      be the href of the rel-author link

      # 7. if there is an author-page URL
      return unless collection['rels'].key?('author')

      find_author_from(url: collection['rels']['author'][0],
                       original_page_items: collection['items'])
    end

    def self.microformats_from(html: nil, url:)
      html ||= Net::HTTP.get(URI(url))
      ::Microformats.parse(html, base: url)
    end
    private_class_method :microformats_from

    def self.hcard?(data)
      data.is_a?(Hash) && data.key?('type') &&
        data['type'].is_a?(Array) && data['type'].include?('h-card')
    end
    private_class_method :hcard?

    def self.hentry_from(source)
      h_entry = source.find { |item| item['type'][0] == 'h-entry' }
      return h_entry unless h_entry.nil?
      source.each do |item|
        if item['type'][0] == 'h-feed' && item.key?('children') && item['children'][0]['type'][0] == 'h-entry'
          return item['children'][0]
        end
      end

      nil
    end
    private_class_method :hentry_from

    def self.hcards_from(source)
      source.select { |entry| hcard?(entry) }
    end
    private_class_method :hcards_from

    def self.h_feed_author_for(h_entry, items:)
      h_feed = items.find do |item|
        item['type'][0] == 'h-feed' && item['children'].include?(h_entry)
      end
      return if h_feed.nil?

      h_feed['properties']['author']
    end
    private_class_method :h_feed_author_for

    def self.hcard_data_for(url, name, photo)
      {
        'url' => url,
        'name' => name,
        'photo' => photo
      }
    end
    private_class_method :hcard_data_for

    def self.find_author_from(url:, original_page_items:)
      # 7.1. get the author-page from that URL and parse it for microformats2
      collection = microformats_from(url: url)

      hcards = hcards_from(collection['items'])

      # 7.2, 7.3, and 7.4
      hcard_matching_url_uid_and_author_page(hcards, url) ||
        hcard_matching_rel_me_link(hcards, url, collection['rels']) ||
        hcard_matching_url_and_author_page_url(original_page_items, url)
    end
    private_class_method :find_author_from

    # 7.2. if author-page has 1+ h-card with url == uid == author-page's
    #      URL, then use first such h-card, exit.
    def self.cards_with_matching_url_and_uid(hcards)
      hcards = hcards.collect { |card| card['properties'] }
      hcards.select do |card|
        card.key?('url') && card.key?('uid') &&
          card['url'] == card['uid']
      end
    end
    private_class_method :cards_with_matching_url_and_uid

    def self.hcard_matching_url_uid_and_author_page(hcards = [], author_page)
      return if hcards.empty? || author_page.nil?

      cards_with_matching_url_and_uid = cards_with_matching_url_and_uid(hcards)
      hcard = cards_with_matching_url_and_uid.find do |card|
        card['url'].include?(author_page)
      end
      return if hcard.nil?

      hcard_data_for(author_page, hcard['name'][0], hcard['photo'][0])
    end
    private_class_method :hcard_matching_url_uid_and_author_page

    # 7.3. else if author-page has 1+ h-card with url property which
    #      matches the href of a rel-me link on the author-page (perhaps
    #      the same hyperlink element as the u-url, though not required
    #      to be), use first such h-card, exit.
    def self.card_with_matching_rel_me_link(hcards, rels_me)
      return if rels_me.nil?

      hcards.find do |card|
        !(card['properties']['url'] & rels_me).empty?
      end
    end
    private_class_method :card_with_matching_rel_me_link

    def self.hcard_matching_rel_me_link(hcards, url, rels = {})
      hcard = card_with_matching_rel_me_link(hcards, rels['me'])
      return if hcard.nil?

      hcard_data_for(url,
                     hcard['properties']['name'][0],
                     hcard['properties']['photo'][0])
    end
    private_class_method :hcard_matching_rel_me_link

    # 7.4. if the h-entry's page has 1+ h-card with url == author-page URL,
    #      use first such h-card, exit.
    def self.hcard_matching_url_and_author_page_url(items, url)
      hcard = hcards_from(items).find do |card|
        card['properties']['url'].include?(url)
      end

      hcard_data_for(url,
                     hcard['properties']['name'][0],
                     hcard['properties']['photo'][0])
    end
  end
end
