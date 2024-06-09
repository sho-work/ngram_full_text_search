# frozen_string_literal: true

require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'csv'
end

module BigramResolver
  N_GRAM_SIZE = 2

  def self.resolve(full_text)
    # NOTE: 文字列full_textに対して、全ての文字を走査する
    (0...(full_text.length - 1)).map { full_text[_1, N_GRAM_SIZE] }
  end
end

module IndexStorage
  STORAGE_FILE_PATH = '../tmp/hash_table'.freeze

  class << self
    def save
      File.open(STORAGE_FILE_PATH, 'wb') do |file|
        Marshal.dump(TransposedIndexBuilder.build, file)
      end
    end

    def load
      File.open(STORAGE_FILE_PATH, 'rb') do |file|
        Marshal.load(file)
      end
    end
  end
end

module TransposedIndexBuilder
  class << self
    def build(reader: $stdin)
      transposed_index = {}
      CSV.new(reader, headers: true).each_with_index do |csv_row, index|
        address = build_address_text(csv_row)
        BigramResolver.resolve(address).each do |bigram|
          transposed_index[bigram] ||= []
          transposed_index[bigram] << csv_row['郵便番号'] + ' ' + address
        end
      end
      transposed_index
    end

    private

    def build_address_text(row)
      "#{row['都道府県']}#{row['市区町村']}#{row['町域']}#{row['京都通り名']}#{row['字丁⽬']}#{row['事業所名']}#{row['事業所住所']}"
    end
  end
end

def search_address(transposed_index:, query:)
  bigrams = BigramResolver.resolve(query)
  results = bigrams.map { transposed_index[_1] || [] }
  # NOTE: queryをBigramにしたときの、全てのBigramあたりの検索結果に対して、積集合をとる。
  common_results = results.reduce do |common, addresses|
    common & addresses
  end
  common_results.empty? ? '検索結果はありません' : common_results
end

if __FILE__ == $0
  IndexStorage.save
  $stdout.puts search_address(transposed_index: IndexStorage.load, query: ARGV[0])
end