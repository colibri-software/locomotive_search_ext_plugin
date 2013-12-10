module SearchHbPlugin
  class WolfvilleAssign < ::Liquid::Tag
    Syntax = /(#{::Liquid::VariableSignature}+)\s*to\s*(#{::Liquid::VariableSignature}+)/

      def initialize(tag_name, markup, tokens, context)
        if markup =~ Syntax
          @results = $1
          @target = $2

          @options = {}
          markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/"|'/, '')  }
        else
          raise ::Liquid::SyntaxError.new("Syntax Error in 'search_wolfville_assign' - Valid syntax:")
        end

        super
      end

    def render(context)
      @site = context.registers[:site]
      @result = context[@results][0]
      model_entry = {}

      if @result['content_type_slug']
        # its a model entry
        model_entry['content_type_slug'] = @result['content_type_slug']
        model = @site.content_types.where(slug: @result['content_type_slug']).first
        model_item = model.entries.where(_slug: @result['_slug']).first.to_liquid

        temppage = @site.pages.where(target_klass_name: model.entries.first._type).first
        if temppage
          # it is used as a templatized page
          model_entry['fullpath'] = temppage.parent.fullpath + "/" + model_item._slug
        else
          pages = @site.pages.select do |p|
            p.raw_template.include?("contents.#{model.slug}")
          end
          model_entry['fullpath'] = pages.first.fullpath
        end
        if model_item.respond_to?(:name)
          model_entry['name'] = true
        elsif model_item.respond_to?(:title)
          model_entry['name'] = false
        else
          rules = model_item['custom_fields_recipe']['rules']
          rule_name = rules.select { |r| r['type'] == 'string'  }.first
          model_entry['name'] = model_item[rule_name['name']]
        end
        if model_item.respond_to?(:description)
          model_entry['description'] = model_item.description
        else
          rules = model_item['custom_fields_recipe']['rules']
          rule_name = rules.select { |r| r['type'] == 'text'  }.first
          model_entry['description'] = model_item[rule_name['name']]
        end
        model_entry['info'] = model_item
      else
        # it is a page
        page = @site.pages.where(:slug => @result['slug']).to_a.first
        editable_field =  page.editable_elements.where(slug: 'description below title').first
        description = ""
        if !editable_field.nil? and page.templatized == false
          description = editable_field.content
        elsif page.templatized == false
          element = page.editable_elements.where(_type: 'Locomotive::EditableLongText').first
          description = element.content if element
        else
          model_entry['templatized'] = true
        end

        model_entry['info'] = page
        model_entry['description'] = description
      end
      context[@target] = model_entry
      ""
    end
  end
end
