# frozen_string_literal: true

module TransposedIndexBuilder
  class IndexBuildError < StandardError; end
  # NOTE: メモリ消費量を考慮して、大雑把に設定したのでホストマシンの状況に合わせて変更する必要がある。
  CHUNK_SIZE = 1_000

  class << self
    def build(reader: $stdin)
      raise IndexBuildError, '標準入力を与えてください' if $stdin.tty?

      CSV.new(reader, headers: true).each_slice(CHUNK_SIZE).with_index do |rows, index|
        transposed_index = build_transposed_index(rows)
        IndexStorage.save_chunk(chunk: transposed_index, index: index)
      end
    end

    private

    def build_transposed_index(rows)
      transposed_index = {}
      rows.each do |csv_row|
        address = build_address_text(csv_row)
        BigramResolver.resolve(address).each do |bigram|
          transposed_index[bigram] ||= []
          transposed_index[bigram] << csv_row['郵便番号'] + ' ' + address
        end
      end
      transposed_index
    end

    def build_address_text(row)
      "#{row['都道府県']}#{row['市区町村']}#{row['町域']}#{row['京都通り名']}#{row['字丁⽬']}#{row['事業所名']}#{row['事業所住所']}"
    end
  end
end
