# frozen_string_literal: true

module IndexStorage
  class IndexNotFoundError < StandardError; end
  STORAGE_FILE_PATH = File.expand_path('./transposed_indexs').freeze

  class << self
    def save_chunk(chunk:, index:)
      file_path = File.join(STORAGE_FILE_PATH, index.to_s)
      File.open(file_path, 'wb') do |file|
        Marshal.dump(chunk, file)
      end
    end

    def load_chunks
      unless File.exist?(File.join(STORAGE_FILE_PATH, '0'))
        raise IndexNotFoundError, '転置インデックスが存在しません'
      end

      Enumerator.new do |y|
        chunk_index = 0
        loop do
          file_path = File.join(STORAGE_FILE_PATH, chunk_index.to_s)
          break unless File.exist?(file_path)
  
          chunk = load_chunk(file_path)
          y.yield(chunk)
          chunk_index += 1
        end
      end
    end

    private

    def load_chunk(file_path)
      File.open(file_path, 'rb') { Marshal.load(_1) }
    end
  end
end
