require "search_hb_plugin/version"
require "search_hb_plugin/assign"
require "search_hb_plugin/custom_type"

module SearchHbPlugin
  class SearchHbPlugin
    include Locomotive::Plugin

    def self.default_plugin_id
      'search'
    end

    def self.liquid_tags
      {
        :assign => Assign,
        :custom_type => CustomType
      }
    end
  end
end
