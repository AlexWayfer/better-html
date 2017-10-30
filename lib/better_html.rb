require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/class/attribute_accessors'

module BetterHtml
  class Config
    # regex to validate "foo" in "<foo>"
    cattr_accessor :partial_tag_name_pattern
    self.partial_tag_name_pattern = /\A[a-z0-9\-\:]+\z/

    # regex to validate "bar" in "<foo bar=1>"
    cattr_accessor :partial_attribute_name_pattern
    self.partial_attribute_name_pattern = /\A[a-zA-Z0-9\-\:]+\z/

    # true if "<foo bar='1'>" is valid syntax
    cattr_accessor :allow_single_quoted_attributes
    self.allow_single_quoted_attributes = false

    # true if "<foo bar=1>" is valid syntax
    cattr_accessor :allow_unquoted_attributes
    self.allow_unquoted_attributes = false

    # all methods that return "javascript-safe" strings
    cattr_accessor :javascript_safe_methods
    self.javascript_safe_methods = ['to_json']

    # name of all html attributes that may contain javascript
    cattr_accessor :javascript_attribute_names
    self.javascript_attribute_names = [/\Aon/i]

    cattr_accessor :template_exclusion_filter_block

    def self.template_exclusion_filter(&block)
      self.template_exclusion_filter_block = block
    end

    cattr_accessor :lodash_safe_javascript_expression
    self.lodash_safe_javascript_expression = [/\AJSON\.stringify\(/]
  end

  def self.config
    @config ||= Config.new
    yield @config if block_given?
    @config
  end
end

require 'better_html/version'
require 'better_html/helpers'
require 'better_html/errors'
require 'better_html/html_attributes'
require 'better_html/node_iterator'
require 'better_html/tree'

require 'better_html/railtie' if defined?(Rails)
