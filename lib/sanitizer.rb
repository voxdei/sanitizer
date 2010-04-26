module Sanitizer
  
  class << self
    
    def included base
      base.extend ClassMethods
    end
    
  end
  
  module InstanceMethods
    
    def remove_sanitized_methods
      public_methods(false).find_all do |item|
        item =~ /sanitized_.*/
      end.each do |method|
        # now we need to remove them all
        self.class.remove_sanitized_method method.to_sym
      end
      
      # now we need to restore the old methods
      self.class.restore_old_methods
    end
    
  end
  
  module ClassMethods
    
    @@old_methods = {}
    
    # simple sanitizer
    # in your class you would for example say
    #
    #   sanitize :content, /<script[^>]*>|<\/script>/
    #   sanitize :content, /<script[^>]*>|<\/script>/
    #   sanitize :content, /<script[^>]*>|<\/script>/
    #   sanitize :content, /<script[^>]*>|<\/script>/
    #
    #
    #
    # this would create a sanatized_content method which would remove everything found matching the regex
    #
    def sanitize_this(attribute, regex, options={})
      options = {
        :override     => false,  # replace original method
        :substitution => ""     # what is the substitution for the regex
      }.merge(options)
      
      attribute = attribute.to_sym
      
      if options[:override]
        # we are replacing the old version, therefore we need to keep track of the old one
        @@old_methods[attribute] ||= self.instance_method(attribute) # || preventing from losing the former method if we chain this process
        
        send :define_method, attribute do
          # new we call the old method within the new one we created and apply our sanitizing process
          @@old_methods[attribute].bind(self).call.gsub(regex, options[:substitution])
        end
      else
        # we are not replacing the old method, therefore we create a new one
        # called "sanitized_ATTRIBUTE"
        method_name = ("sanitized_" + attribute.to_s).to_sym
        send :define_method, method_name do
          send(attribute).gsub(regex, options[:substitution])
        end
      end
    end
    
    # pick the one you prefer to use this functionnality :-)
    alias_method :sanitize_my, :sanitize_this
    alias_method :sanitize_the, :sanitize_this
    
    def remove_sanitized_method(method)
      remove_method method
    end
    
    def restore_old_methods
      @@old_methods.each_pair do |old_method, method|
        send :define_method, old_method do
          method.bind(self).call
        end
      end
    end
    
  end
  
end

# loading it up
Object.send(:include, Sanitizer)

class Object
  include Sanitizer::InstanceMethods
end
# Done loading it


if __FILE__ == $0
  class Testo
    
    def blop
      result = "Omaga BLOP"
      p "Call inside old method [blop]"
      result
    end
    
    sanitize_this :blop, /BL/, :override => false
    
  end
  
  testo = Testo.new
  p testo.public_methods(false)
  testo.remove_sanitized_methods
  p testo.public_methods(false)
  
  #p testo.public_methods(false).join(', ')
  
  #p testo.blop
  
end