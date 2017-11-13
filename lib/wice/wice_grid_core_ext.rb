module Wice
  module WgHash #:nodoc:
    class << self #:nodoc:
      # if there's a hash of hashes, the original structure and the
      # returned structure should not contain any shared deep hashes
      def deep_clone(hash)  #:nodoc:
        cloned = hash.clone
        cloned.keys.each do |k|
          if cloned[k].is_a?(Hash)
            cloned[k] = Wice::WgHash.deep_clone cloned[k]
          end
        end
        cloned
      end

      # Used to modify options submitted to view helpers. If there is no :klass option,
      # it will be added, if there is, the css class name will be appended to the existing
      # class name(s)
      def add_or_append_class_value!(hash, klass_value, prepend = false) #:nodoc:
        if hash.key?('class')
          hash[:class] = hash['class']
          hash.delete('class')
        end

        hash[:class] = if hash.key?(:class)
          if prepend
            "#{klass_value} #{hash[:class]}"
          else
            "#{hash[:class]} #{klass_value}"
          end
        else
          klass_value
        end

        hash
      end

      # Used mostly for submitting options to view helpers, that is, like this:
      #   content_tag(:th, col_link, Wice::WgHash.make_hash(:class, css_class))
      # In some it is important that if the value is empty, no option
      # is submitted at all. Thus, there's a check for an empty value
      def make_hash(key, value) #:nodoc:
        value.blank? ? {} : { key => value }
      end

      # A deep merge of two hashes.
      # That is, if both hashes have the same key and the values are hashes, these two hashes should also be merged.
      # Used for merging two sets of params.
      def rec_merge(hash, other)  #:nodoc:
        res = hash.clone
        other.each do |key, other_value|
          value = res[key]
          if value.is_a?(Hash) && other_value.is_a?(Hash)
            res[key] = rec_merge value, other_value
          else
            res[key] = other_value
          end
        end
        res
      end

      # Used to transform a traditional params hash
      # into an array of two element arrays where element zero is a parameter name as it appears in HTTP requests,
      # and the first element is the value:
      # { a: { b: 3, c: 4, d: { e: 5 }} }.parameter_names_and_values #=>  [["a[d][e]", 5], ["a[b]", 3], ["a[c]", 4]]
      # The parameter is an optional array of parameter names to prepend:
      # { a: { b: 3, c: 4, d: { e: 5 }} }.parameter_names_and_values(['foo', 'baz']) #=>
      #                         [["foo[baz][a][d][e]", 5], ["foo[baz][a][b]", 3], ["foo[baz][a][c]", 4]]
      def parameter_names_and_values(hash, initial = []) #:nodoc:
        res = []
        recursively_gather_finite_non_hash_values_with_key_path(hash, res, [])
        res.collect do |parameter_struct|
          parameter_struct[0] = initial + parameter_struct[0]
          [Wice::WgArray.to_parameter_name(parameter_struct[0]), parameter_struct[1]]
        end
      end

      protected

      def recursively_gather_finite_non_hash_values_with_key_path(hash, res, stack = []) #:nodoc:
        hash.each do |key, value|
          if value.is_a?(Hash)
            recursively_gather_finite_non_hash_values_with_key_path(value, res, stack + [key])
          else
            res << [stack + [key], value]
          end
        end
      end
    end
  end

  module WgEnumerable #:nodoc:
    # Used to check the validity of :custom_filter parameter of column
    def self.all_items_are_of_class(enumerable, klass)  #:nodoc:
      return false if enumerable.empty?
      enumerable.inject(true) { |memo, o| (o.is_a? klass) && memo }
    end
  end

  module WgArray #:nodoc:
    # Only used by Hash#parameter_names_and_values
    # Transforms ['foo', 'bar', 'baz'] to 'foo[bar][baz]'
    def self.to_parameter_name(array) #:nodoc:
      array[0].to_s + (array[1..-1] || []).collect { |k| '[' + k.to_s + ']' }.join('')
    end
  end
end

# tag_options is a Rails views private method that takes a hash op options for
# an HTM hash and produces a string ready to be added to the tag.
# Here we are changing its visibility in order to be able to use it.
module ActionView #:nodoc:
  module Helpers #:nodoc:
    module TagHelper #:nodoc:
      def public_tag_options(options, escape = true) #:nodoc:
        if respond_to? :tag_options
          tag_options(options, escape)
        else
          tag_builder.tag_options(options, escape)
        end
      end
    end
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
    obj
  end
end

class Object #:nodoc:
  include WGObjectExtensions
end
