require "search_hb_plugin/version"
require "search_hb_plugin/assign"
require "search_hb_plugin/wolfville_assign"
require "search_hb_plugin/custom_type"
require "activesearch/proxy_score"

module SearchHbPlugin
  class SearchHbPlugin
    include Locomotive::Plugin

    def self.default_plugin_id
      'search'
    end

    def self.liquid_tags
      {
        :assign => Assign,
        :wolfville_assign => WolfvilleAssign,
        :custom_type => CustomType
      }
    end
  end
end
