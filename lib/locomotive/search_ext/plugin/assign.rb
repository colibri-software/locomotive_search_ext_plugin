module Locomotive
  module SearchExt
    class Assign < ::Liquid::Tag
      include ActionView::Helpers::SanitizeHelper
      Syntax = /(#{::Liquid::VariableSignature}+)\s*to\s*(#{::Liquid::VariableSignature}+):\s*(#{::Liquid::VariableSignature}+)/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @results = $1
            @target = $2
            @description = "#{@target}_description"
            @flag = $3
            @options = {}
            markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/"|'/, '') }
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'search_assign' - Valid syntax: search_assign results to variable: pagetag")
          end

          super
        end

      def render(context)
        @site = context.registers[:site]
        @result = context[@results][0]
        result_data = false

        if @result['content_type_slug']
          # its a model entry
          model = @site.content_types.where(slug: @result['content_type_slug']).first
          model_item = model.entries.find(@result['original_id']).to_liquid
          result_data = model_item if model_item
          context[@flag.to_s] = model.name
          context[@description.to_s] = @result
        else
          # it is a page
          page = @site.pages.find(@result['original_id']).to_liquid
          result_data = page if page
          context[@flag.to_s] = false

          res =  @result['highlighted']['searchable_content']

          context[@description] = strip_tags(res)
        end
        context[@target.to_s] = result_data
        Rails.logger.error(result_data)
        ""
      end
    end
  end
end

