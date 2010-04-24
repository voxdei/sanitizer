module Sanitizer
  
  class << self

    def included base
      base.extend ClassMethods
    end
  
  end
  
  module ClassMethods
    
    # simple sanitizer
    # in your class you would for example say
    #
    #   sanitize :content, /<[^>]*script[^>]*>/
    #
    # this would create a sanatized_content method which would remove everything found matching the regex
    #
    def sanitize_this(attribute, regex)
      attribute = attribute.to_sym
      
      method_name = ("sanitized_" + attribute.to_s).to_sym
      send :define_method, method_name do
        send(attribute).gsub(regex, "")
      end
    end
    
    alias_method :sanitize_my, :sanitize_this
    alias_method :sanitize_the, :sanitize_this
    
  end
end

# loading it up
Object.send(:include, Sanitizer)