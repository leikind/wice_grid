module Wice

  class << self

    @@model_validated = false
    
    
    # checks whether the class is a valid storage for saved queries
    def validate_query_model(query_store_model)  #:nodoc:
      unless query_store_model.respond_to?(:list)
        raise ::Wice::WiceGridArgumentError.new("Model for saving queries #{query_store_model.class.name} is invalid - there is no class method #list defined")
      end
      arit = query_store_model.method(:list).arity
      unless arit == 2
        raise ::Wice::WiceGridArgumentError.new("Method list in the model for saving queries #{query_store_model.class.name} has wrong arity - it should be 2 instead of #{arit}")
      end
      @@model_validated = true
    end

    # Retrieves and constantizes (if needed ) the Query Store model
    def get_query_store_model #:nodoc:

      query_store_model = ::Wice::Defaults::QUERY_STORE_MODEL
      query_store_model = query_store_model.constantize if query_store_model.is_a? String
      raise ::Wice::WiceGridArgumentError.new("Defaults::QUERY_STORE_MODEL must be an ActiveRecord class or a string which can be constantized to an ActiveRecord class") unless query_store_model.kind_of? Class
      validate_query_model(query_store_model) unless @@model_validated
      query_store_model
    end

    def deprecated_call(old_name, new_name, opts) #:nodoc:
      if opts[old_name] && ! opts[new_name]
        opts[new_name] = opts[old_name]
        opts.delete(old_name)
        STDERR.puts "WiceGrid: Parameter :#{old_name} is deprecated, use :#{new_name} instead!"
      end
    end

    # used for processing of parameters to ActiveRecord: transforms a string into a single item array,
    # or if the parameter is an array, does nothing
    def string_conditions_to_array_cond(o)  #:nodoc:
      o.kind_of?(Array) ? o : [o]
    end

    # unites two conditions into one
    # unite_conditions(['name = ?', 'yuri'], ['age > ?', 30]) #=> ['name = ? and age > ?', 'yuri', 30]
    # or
    # unite_conditions('name is not null', ['age > ?', 30]) #=> ['name is not null and age > ?',  30]    
    def unite_conditions(c1, c2)  #:nodoc:
      raise WiceGridException.new('invalid call to unite_conditions') if c1.blank? && c2.blank?
      return c1 if c2.blank?
      return c2 if c1.blank?
      c1 = string_conditions_to_array_cond(c1)
      c2 = string_conditions_to_array_cond(c2)
      c1[0] += ' and ' + c2[0]
      c1 += c2[1..-1]
      c1
    end

    def log(message) #:nodoc:
      ActiveRecord::Base.logger.info('WiceGrid: ' + message)
    end
  end

  module Defaults  #:nodoc:
  end
  
  module ExceptionsMixin  #:nodoc:
    def initialize(str)  #:nodoc:
      super("WiceGrid: " + str)
    end    
  end
  class WiceGridArgumentError < ArgumentError #:nodoc:
    include ExceptionsMixin
  end
  class WiceGridException < Exception #:nodoc:
    include ExceptionsMixin
  end
end