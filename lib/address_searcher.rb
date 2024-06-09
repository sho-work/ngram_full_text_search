# frozen_string_literal: true

require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'csv'
end

require_relative './bigram_resolver'
require_relative './transposed_index_builder'
require_relative './index_storage'

# NOTE: エントリポイントとなるmodule
module AddressSearcher
  def self.run(query:)
    bigrams = BigramResolver.resolve(query)
    results = []

    IndexStorage.load_chunks.each do |chunk|
      partial_results = bigrams.map { chunk[_1] || [] }
      common_results = partial_results.reduce do |common, partial_result|
        common & partial_result
      end
      results.concat(common_results) if common_results.any?
    end

    results.empty? ? '検索結果はありません' : results
  end
end

if __FILE__ == $0
  if ARGV.include?('--build') || ARGV.include?('-b')
    TransposedIndexBuilder.build
  elsif ARGV.include?('--search') || ARGV.include?('-s')
    $stdout.puts AddressSearcher.run(query: ARGV[0])
  else
    $stdout.puts <<~EOS
    Usage: 
    【転置インデックスの構築】
    ruby lib/address_searcher.rb < [csv file path] [-b | --build]
    
    【住所の検索】
    ruby lib/address_searcher.rb [search word] [-s | --search]
    EOS
  end
end
