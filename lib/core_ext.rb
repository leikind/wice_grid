unless Hash.instance_methods.include? 'rec_merge'
  Hash.class_eval do
    
    # a deep merge of two hashes. 
    # That is, if both hashes have the same key and the values are hashes, these two hashes should also be merged.
    # Used for merging two sets of params.
    def rec_merge(other)  #:nodoc:
      res = self.clone
      other.each do |key, other_value|
        value = res[key]
        if value.is_a?(Hash) && other_value.is_a?(Hash)
          res[key] = value.rec_merge other_value
        else
          res[key] = other_value
        end
      end
      res
    end
  end
end

class Hash #:nodoc:
  def deep_clone_yl  #:nodoc:
    cloned = self.clone
    cloned.keys.each do |k|
      if cloned[k].kind_of?(Hash)
        cloned[k] = cloned[k].deep_clone_yl
      end
    end
    cloned
  end

  def self.make_hash(key, value) #:nodoc:
    value.blank? ? {} : {key => value}
  end

  def add_or_append_class_value(klass_value) #:nodoc:
    if self.has_key?('class')
      self[:class] = self['class']
      self.delete('class')
    end
    self[:class] = self.has_key?(:class) ?  "#{self[:class]} #{klass_value}" : klass_value
  end


  def parameter_names_and_values(initial = []) #:nodoc:
    res = []
    recursively_gather_finite_non_hash_values_with_key_path(res, [])
    res.collect do |parameter_struct|
      parameter_struct[0] = initial + parameter_struct[0]
      [parameter_struct[0].to_parameter_name, parameter_struct[1]]
    end
  end

  protected

  def recursively_gather_finite_non_hash_values_with_key_path(res, stack = []) #:nodoc:
    self.each do |key, value|
      if value.kind_of?(Hash)
        value.recursively_gather_finite_non_hash_values_with_key_path(res, stack + [key])
      else
        res << [stack + [key], value]
      end
    end
  end

end

module ActionView #:nodoc:
  module Helpers #:nodoc:
    module TagHelper #:nodoc:
      public :tag_options
    end
  end
end


module Enumerable #:nodoc:
  def all_items_are_of_class(klass)  #:nodoc:
    return false if self.empty?
    self.inject(true){|memo, o| (o.is_a? klass) && memo}
  end
end

class Object #:nodoc:

  def deep_send(*messages)  #:nodoc:
    obj = self
    messages.each do |message|
      if obj.respond_to? message
        obj = obj.send(message)
      else
        return nil
      end
      # return obj if obj.nil?
    end
    return obj
  end
end


class Array  #:nodoc:
  def to_parameter_name #:nodoc:
    self[0].to_s + (self[1..-1] || []).collect{|k| '[' + k.to_s + ']'}.join('')
  end
end
