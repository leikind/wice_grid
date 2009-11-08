module WGHashExtensions  #:nodoc:

  def self.included(base)  #:nodoc:
    base.extend(ClassMethods)
  end


  # if there's a hash of hashes, the original structure and the
  # returned structure should not contain any shared deep hashes
  def deep_clone_yl  #:nodoc:
    cloned = self.clone
    cloned.keys.each do |k|
      if cloned[k].kind_of?(Hash)
        cloned[k] = cloned[k].deep_clone_yl
      end
    end
    cloned
  end

  # Used to modify options submitted to view helpers. If there is no :klass option,
  # it will be added, if there is, the css class name will be appended to the existing
  # class name(s)
  def add_or_append_class_value!(klass_value, prepend = false) #:nodoc:
    if self.has_key?('class')
      self[:class] = self['class']
      self.delete('class')
    end

    self[:class] = if self.has_key?(:class)
      if prepend
        "#{klass_value} #{self[:class]}"
      else
        "#{self[:class]} #{klass_value}"
      end
    else
      klass_value
    end

    return self
  end


  # Used to transform a traditional params hash
  # into an array of two element arrays where element zero is a parameter name as it appears in HTTP requests,
  # and the first element is the value:
  # { :a => { :b => 3, :c => 4, :d => { :e => 5 }} }.parameter_names_and_values #=>  [["a[d][e]", 5], ["a[b]", 3], ["a[c]", 4]]
  # The parameter is an optional array of parameter names to prepend:
  # { :a => { :b => 3, :c => 4, :d => { :e => 5 }} }.parameter_names_and_values(['foo', 'baz']) #=>
  #                         [["foo[baz][a][d][e]", 5], ["foo[baz][a][b]", 3], ["foo[baz][a][c]", 4]]
  def parameter_names_and_values(initial = []) #:nodoc:
    res = []
    recursively_gather_finite_non_hash_values_with_key_path(res, [])
    res.collect do |parameter_struct|
      parameter_struct[0] = initial + parameter_struct[0]
      [parameter_struct[0].to_parameter_name, parameter_struct[1]]
    end
  end


  # A deep merge of two hashes.
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


  module ClassMethods  #:nodoc:

    # Used mostly for submitting options to view helpers, that is, like this:
    #   content_tag(:th, col_link, Hash.make_hash(:class, css_class))
    # In some it is important that if the value is empty, no option
    # is submitted at all. Thus, there's a check for an empty value
    def make_hash(key, value) #:nodoc:
      value.blank? ? {} : {key => value}
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


class Hash #:nodoc:
  include WGHashExtensions
end

# tag_options is a Rails views private method that takes a hash op options for
# an HTM hash and produces a string ready to be added to the tag.
# Here we are changing its visibility in order to be able to use it.
module ActionView #:nodoc:
  module Helpers #:nodoc:
    module TagHelper #:nodoc:
      public :tag_options
    end
  end
end



module Enumerable #:nodoc:

  # Used to check the validity of :custom_filter parameter of column
  def all_items_are_of_class(klass)  #:nodoc:
    return false if self.empty?
    self.inject(true){|memo, o| (o.is_a? klass) && memo}
  end

end

module WGObjectExtensions #:nodoc:

  # takes a list of messages, sends message 1 to self, then message 2 is sent to the result of the first message, ans so on
  # returns nil as soon as the current receiver does not respond to such a message
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

class Object #:nodoc:
  include WGObjectExtensions
end

module WGArrayExtensions  #:nodoc:
  # Only used by Hash#parameter_names_and_values
  # Transforms ['foo', 'bar', 'baz'] to 'foo[bar][baz]'
  def to_parameter_name #:nodoc:
    self[0].to_s + (self[1..-1] || []).collect{|k| '[' + k.to_s + ']'}.join('')
  end
end

class Array  #:nodoc:
  include WGArrayExtensions
end