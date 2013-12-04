require "activesearch/proxy"

module ActiveSearch
  class Proxy

    def each(&block)
      @implementation.call(@text, @conditions).each { |result| block.call(Result.new(result), generate_score(result))  }
    end

    protected

    def generate_score(result)
      score = 0
      result._keywords.each do |key|
        score += 1 if text_words.include?(key)
      end
      score
    end

    def text_words
      @text_words ||= @text.scan(/\w+|\n/)
    end
  end
end
