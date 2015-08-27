# encoding: utf-8
module Wice
  class << self
    @@model_validated = false

    def assoc_list_to_hash(assocs)
      head = assocs[0]
      tail = assocs[1..-1]

      if tail.blank?
        head
      elsif tail.size == 1
        {head => tail[0]}
      else
        {head => assoc_list_to_hash(tail)}
      end
    end

    def build_includes(existing_includes, new_assocs) #:nodoc:
      new_includes = if new_assocs.blank?
        existing_includes
      else
        existing_includes = if existing_includes.is_a?(Symbol)
          [existing_includes]
        elsif existing_includes.nil?
          []
        else
          existing_includes
        end

        assocs_as_hash = assoc_list_to_hash(new_assocs)
        build_includes_int(existing_includes, assocs_as_hash)
      end

      if new_includes.is_a?(Array) && new_includes.size == 1
        new_includes[0]
      else
        new_includes
      end
    end

    def build_includes_int(includes, assocs) #:nodoc:
      if includes.is_a?(Array)
        build_includes_includes_is_array(includes, assocs)
      elsif includes.is_a?(Hash)
        build_includes_includes_is_hash(includes, assocs)
      end
    end

    # TODO: refactor
    def build_includes_includes_is_hash(includes, assocs) #:nodoc:

      includes_key   = includes.keys[0]
      includes_value = includes.values[0]

      if assocs.is_a?(Hash)
        assocs_key   = assocs.keys[0]
        assocs_value = assocs.values[0]

        if includes_value.is_a?(Symbol) && includes_value == assocs_key
          {includes_key => assocs}
        elsif includes_value.is_a?(Hash)
          if includes_value.keys[0] == assocs_key
            if includes_value.values[0] == assocs_value
              {includes_key => assocs}
            else
              {includes_key => [includes_value.values[0], assocs_value]}
            end
          end
        end
      elsif includes_value == assocs
        {includes_key => assocs}
      else
        includes
      end
    end

    def build_includes_includes_is_array(includes, assocs) #:nodoc:

      hash_keys = includes
                  .each_with_index
                  .to_a
                  .select{ |e, _idx| e.is_a?(Hash)}
                  .map{ |hash, idx| [ hash.keys[0], idx ] }
                  .to_h

      key_to_search, finished = if assocs.is_a?(Hash)
        [assocs.keys[0], false]
      else
        [assocs, true]
      end

      if idx = includes.index(key_to_search)
        if finished #  [:a, :b, :c]  vs  :a
          includes
        else        #  [:a, :b, :c]  vs  {:a => x}
          includes[idx] = assocs
          includes
        end

      elsif hash_keys.key?(key_to_search)
        if finished # [{a: :x}, :b, :c, :d, :e] vs :a
          includes
        else
          hash_idx = hash_keys[key_to_search]
          assocs_value = assocs[key_to_search]
          includes[hash_idx] = build_includes_int(includes[hash_idx], assocs_value)
          includes
        end

      else  # [:a, :b, :c]  vs  :x
            # [:a, :b, :c]  vs  {:x => y}
        includes + [assocs]
      end

    end

    # checks whether the class is a valid storage for saved queries
    def validate_query_model(query_store_model)  #:nodoc:
      unless query_store_model.respond_to?(:list)
        fail ::Wice::WiceGridArgumentError.new("Model for saving queries #{query_store_model.class.name} is invalid - there is no class method #list defined")
      end
      arit = query_store_model.method(:list).arity
      unless arit == 2
        fail ::Wice::WiceGridArgumentError.new("Method list in the model for saving queries #{query_store_model.class.name} has wrong arity - it should be 2 instead of #{arit}")
      end
      @@model_validated = true
    end

    # Retrieves and constantizes (if needed ) the Query Store model
    def get_query_store_model #:nodoc:
      query_store_model = Wice::ConfigurationProvider.value_for(:QUERY_STORE_MODEL)
      query_store_model = query_store_model.constantize if query_store_model.is_a? String
      fail ::Wice::WiceGridArgumentError.new('Defaults::QUERY_STORE_MODEL must be an ActiveRecord class or a string which can be constantized to an ActiveRecord class') unless query_store_model.is_a? Class
      validate_query_model(query_store_model) unless @@model_validated
      query_store_model
    end

    def get_string_matching_operators(model)   #:nodoc:
      if defined?(Wice::Defaults::STRING_MATCHING_OPERATORS) && (ops = Wice::ConfigurationProvider.value_for(:STRING_MATCHING_OPERATORS)) &&
         ops.is_a?(Hash) && (str_matching_operator = ops[model.connection.class.to_s])
        str_matching_operator
      else
        Wice::ConfigurationProvider.value_for(:STRING_MATCHING_OPERATOR)
      end
    end

    def deprecated_call(old_name, new_name, opts) #:nodoc:
      if opts[old_name] && !opts[new_name]
        opts[new_name] = opts[old_name]
        opts.delete(old_name)
        STDERR.puts "WiceGrid: Parameter :#{old_name} is deprecated, use :#{new_name} instead!"
      end
    end

    def log(message) #:nodoc:
      ActiveRecord::Base.logger.info('WiceGrid: ' + message)
    end
  end

  module NlMessage #:nodoc:
    class << self
      def [](key) #:nodoc:
        I18n.t(key, scope: 'wice_grid')
      end
    end
  end

  module ConfigurationProvider #:nodoc:
    class << self
      def value_for(key, strict: true) #:nodoc:
        if Wice::Defaults.const_defined?(key)
          Wice::Defaults.const_get(key)
        else
          if strict
            fail WiceGridMissingConfigurationConstantException.new("Could not find constant #{key} in the configuration file!" \
                ' It is possible that the version of WiceGrid you are using is newer than the installed configuration file in config/initializers. ' \
                "Constant Wice::Defaults::#{key} is missing  and you need to add it manually to wice_grid_config.rb or run the generator task=:\n" \
                '   rails g wice_grid:install')
          end # else nil
        end
      end
    end
  end

  module Defaults  #:nodoc:
  end

  module ExceptionsMixin  #:nodoc:
    def initialize(str)  #:nodoc:
      super('WiceGrid: ' + str)
    end
  end
  class WiceGridArgumentError < ArgumentError #:nodoc:
    include ExceptionsMixin
  end
  class WiceGridException < Exception #:nodoc:
    include ExceptionsMixin
  end
  class WiceGridMissingConfigurationConstantException < Exception #:nodoc:
    include ExceptionsMixin
  end
end
