require "locomotive/search_ext/plugin/version"
require "locomotive/search_ext/plugin/assign"
require "locomotive/search_ext/plugin/custom_type"
require "activesearch/proxy_score"

module Locomotive
  module SearchExt
    class Plugin
      include Locomotive::Plugin

      def self.default_plugin_id
        'search_ext'
      end

      def self.liquid_tags
        {
          :assign => Assign,
          :custom_type => CustomType
        }
      end
    end
  end
end
