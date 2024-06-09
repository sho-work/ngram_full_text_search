# frozen_string_literal: true

module BigramResolver
  N_GRAM_SIZE = 2

  def self.resolve(full_text)
    # NOTE: 文字列full_textに対して、全ての文字を走査する
    (0...(full_text.length - 1)).map { full_text[_1, N_GRAM_SIZE] }
  end
end
