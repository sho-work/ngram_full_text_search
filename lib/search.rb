# frozen_string_literal: true

require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'csv'
end

module BigramResolver
  N_GRAM_SIZE = 2

  def self.resolve(full_text)
    # 文字列full_textに対して、全ての文字を走査する
    (0...(full_text.length - 1)).map { full_text[_1, N_GRAM_SIZE] }
  end
end

module TransposedIndexBuilder
  class << self
    def build(reader: $stdin, writer: $stdout)
      transposed_index = {}
      CSV.new(reader, headers: true).each_with_index do |csv_row, index|
        address = build_address_text(csv_row)
        BigramResolver.resolve(address).each do |bigram|
          transposed_index[bigram] ||= []
          transposed_index[bigram] << csv_row['郵便番号'] + ' ' + address
        end
      end
      $stdout.puts transposed_index
    end

    private

    def build_address_text(row)
      "#{row['都道府県']}#{row['市区町村']}#{row['町域']}#{row['京都通り名']}#{row['字丁⽬']}#{row['事業所名']}#{row['事業所住所']}"
    end
  end
end

if __FILE__ == $0
  TransposedIndexBuilder.build
end