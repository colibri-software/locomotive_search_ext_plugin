#require 'ruby-prof'

module SearchHbPlugin
  class CustomType < ::Liquid::Tag

    Syntax = /(#{::Liquid::QuotedFragment})\s*on fields\s*(#{::Liquid::QuotedFragment})\s*to\s*(#{::Liquid::QuotedFragment})/

      def initialize(tag_name, markup, tokens, context)
        if markup =~ Syntax
          @content_type_slug = $1
          @fields = $2.split(',')
          @target = $3
        else
          raise ::Liquid::SyntaxError.new("Syntax Error in 'search_custom_type - Valid syntax: search_custom_type 'content_type_slug' on fields 'field_a, field_b' to results")
        end

        #@site = context.registers[:site]
        #content_type = @site.content_type.where(slug: @content_type_slug).first
        #raise ::Liquid::SyntaxError.new("Syntax Error in 'search_custom_type': #{@content_type_slug} is not a content type ") unless content_type
        #real_fields = content_type.entries_custom_fields.collect(&:label)
        #@fields.each do  |field|
        #  unless real_fields.include?(field)
        #    raise ::Liquid::SyntaxError.new("Syntax Error in 'search_custom_type':#{field} is not a field on #{@content_type_slug}")
        #  end
        #end
        super
      end

    def render(context)
      @site = context.registers[:site]
      content_type = @site.content_types.where(slug: @content_type_slug).first
      raise ::Liquid::Error.new("Error in 'search_custom_type': #{@content_type_slug} is not a content type ") unless content_type
      @fields.each do |field|
        unless content_type.entries.first.respond_to?(field)
          raise ::Liquid::Error.new("Error in 'search_custom_type':#{field} is not a field on #{@content_type_slug}")
        end
      end

      #profile = RubyProf.profile do
      search = nil
      search_terms = context.registers[:controller].params[:search]
      if search_terms and !search_terms.empty?
        search = ::ActiveSearch.search(
          search_terms,
          {
          "site_id" => @site.id,
          "content_type_slug" => @content_type_slug,
          }
        )
      else
        search = content_type.entries.all#.map { |e| e.to_liquid }
      end

      @fields.select! do |field|
        param = context.registers[:controller].params[field]
        param && !param.empty?
      end

      final_results = []
      search.each do |result|
        if result.class == Hash
          model_item = content_type.entries.where(_slug: result['_slug']).first.to_liquid
        else
          model_item = result
        end
        if match_fields(context, model_item)
          final_results << model_item.to_liquid
        else
        end
      end

      context[@target.to_s] = final_results
      #end
      # Print a graph profile to text
      #printer = RubyProf::MultiPrinter.new(profile)
      #printer.print(:path => '/home/greeneca/colibri/tmp/profile')

      ""
    end

    private

    def match_fields(context, model_item)
      @fields.each do |field|
        return false unless model_item[field].to_s == context.registers[:controller].params[field]
      end
      true
    end
  end
end

