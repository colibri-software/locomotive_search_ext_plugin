require "activesearch/proxy"

module ActiveSearch
  class Proxy
    include Enumerable

    def initialize(text, conditions, options = {}, &implementation)
      @text           = text
      @conditions     = conditions
      @options        = options
      @implementation = implementation
    end

    def each(&block)
      @implementation.call(@text, @conditions).each do |result|
        block.call(Result.new(result, @text, @options), generate_score(result))
      end
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
