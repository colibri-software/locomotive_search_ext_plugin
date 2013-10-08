module SearchHbPlugin
  class Assign < ::Liquid::Tag

    Syntax = /(#{::Liquid::VariableSignature}+)\s*to\s*(#{::Liquid::VariableSignature}+)/

      def initialize(tag_name, markup, tokens, context)
        if markup =~ Syntax
          @results = $1
          @target = $2
          @options = {}
          markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/"|'/, '') }
        else
          raise ::Liquid::SyntaxError.new("Syntax Error in 'search_assign' - Valid syntax: search_assign results to variable")
        end

        super
      end

    def render(context)
      @site = context.registers[:site]
      @result = context[@results]
      result_data = nil

      if @result['content_type_slug']
        # its a model entry
        model = @site.content_types.where(slug: @result['content_type_slug']).first
        model_item = model.entries.where(_slug: @result['_slug']).first.to_liquid
        result_data = model_item

      else
        # it is a page
        page = @site.pages.where(:slug => @result['slug']).to_a.first.to_liquid
        result_data = page
      end
      context[@target.to_s] = result_data
      ""
    end
  end
end

