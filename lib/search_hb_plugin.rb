require "search_hb_plugin/version"
require "search_hb_plugin/assign"

module SearchHbPlugin
  class SearchHbPlugin
    include Locomotive::Plugin

    def self.default_plugin_id
      'search'
    end

    def self.liquid_tags
      {
        :assign => Assign
      }
    end
  end
end
