# More or less complete

require 'test/unit'
require File.dirname(__FILE__) + '/test_helper.rb'

class WiceGridCoreExtTest < Test::Unit::TestCase
  
  #
  # Hash
  #

  def test_rec_merge
    
    # required for will_paginate
    # read this - http://err.lighthouseapp.com/projects/466/tickets/197-using-param_name-something-page-leads-to-invalid-behavior
    
    a_hash = {34 => 12,  :key1 => 87,  :key2 => {:f => 67} }
    b_hash = {34 => 'x', :key3 => 987, :key2 => {:key4 => {:key5 => 0} } }
    
    assert_equal({:key3 => 987, 34 => "x", :key1 => 87, :key2 => {:key4 => {:key5 => 0}, :f => 67}} , a_hash.rec_merge(b_hash))

    a_hash = {34 => 12,  :key1 => 87}
    b_hash = {34 => 12}
    
    assert_equal({34 => 12,  :key1 => 87} , a_hash.rec_merge(b_hash))

    a_hash = {34 => { :f => :moo},  :key1 => 87}
    b_hash = {34 => { :k => [1,2, { :z => :baz }]},  :key1 => 87}
    
    assert_equal({34 => {  :f => :moo,  :k => [1,2, { :z => :baz}]},  :key1 => 87} , a_hash.rec_merge(b_hash))

  end
  
  def test_hash_make_hash
    
    assert_equal({}, Hash.make_hash(:key, nil))
    assert_equal({}, Hash.make_hash(:key, ''))

    assert_equal({:key => "value"}, Hash.make_hash(:key, "value"))
    
  end
  
  def test_hash_deep_clone_yl
    
    a = {}
    b = a.deep_clone_yl
    assert_equal    a, b 
    assert_not_same a, b
    
    a = {'a' => 'b'}
    b = a.deep_clone_yl
    assert_equal    a, b 
    assert_not_same a, b

    a = {'a' => 'b', 'c' => {'d' => 'e'}}
    b = a.deep_clone_yl
    assert_equal    a, b
    assert_equal    a['c'], b['c']
    assert_not_same a, b
    assert_not_same a['c'], b['c']
    
  end
  
  def test_hash_add_or_append_class_value_on_empty_hash
    
    h = {}
    
    h.add_or_append_class_value!('foo')
    assert_equal({:class => 'foo'}, h)

    res = h.add_or_append_class_value!('bar')
    assert_equal({:class => 'foo bar'}, h)
    
    assert_equal(res, h)
        
  end
  
  def test_hash_add_or_append_class_value_key_normalization
    
    h = {'class' => 'foo'}

    h.add_or_append_class_value!('bar')
    assert_equal({:class => 'foo bar'}, h)
  
  end
  
  def test_hash_parameter_names_and_values
    
    assert_equal([], {}.parameter_names_and_values)
    assert_equal([], {}.parameter_names_and_values(%w(foo)))


    assert_equal([['a', 'b']], {'a' => 'b'}.parameter_names_and_values)
    assert_equal([['a', 'b'], ['c[d]', 'e']], {'a' => 'b', 'c' => {'d' => 'e'}}.parameter_names_and_values)
    
    assert_equal([['foo[a]', 'b']], {'a' => 'b'}.parameter_names_and_values(%w(foo)))
    assert_equal([['foo[a]', 'b'], ['foo[c][d]', 'e']], {'a' => 'b', 'c' => {'d' => 'e'}}.parameter_names_and_values(%w(foo)))
    
    assert_equal(
      [["a[d][e]", 5], ["a[b]", 3], ["a[c]", 4]].sort, 
      { :a => { :b => 3, :c => 4, :d => { :e => 5 }} }.parameter_names_and_values.sort
    )

    assert_equal(
      [["foo[baz][a][d][e]", 5], ["foo[baz][a][b]", 3], ["foo[baz][a][c]", 4]].sort, 
      { :a => { :b => 3, :c => 4, :d => { :e => 5 }} }.parameter_names_and_values(['foo', 'baz']).sort
    )

  end

  #
  # Enumerable
  # 

  def test_enumerable_all_items_are_of_class
    
    assert([].respond_to?(:all_items_are_of_class))
    assert({}.respond_to?(:all_items_are_of_class))
    
    assert_equal false, [].all_items_are_of_class(Object)
    
    assert_equal true, [1, 2, 3].all_items_are_of_class(Numeric)
    assert_equal true, %(one two three).all_items_are_of_class(String)

    assert_equal false, [1, 2, "apple"].all_items_are_of_class(String)
    assert_equal false, [1, 2, nil].all_items_are_of_class(String)
    assert_equal false, [1, 2.5].all_items_are_of_class(String)

    assert_equal true, [1, 2, "apple"].all_items_are_of_class(Object)
    
  end
  
  #
  # Object
  #
  
  def test_object_deep_send
    
    wrapper = Struct.new(:hop)
    
    z = wrapper.new(123)
    y = wrapper.new(z)
    x = wrapper.new(y)
    
    assert_equal x, x.deep_send
    assert_equal y, x.deep_send(:hop)
    assert_equal z, x.deep_send(:hop, :hop)
    assert_equal 123, x.deep_send(:hop, :hop, :hop)
    
    assert_nil x.deep_send(:non_existing_method)
    assert_nil x.deep_send(:hop, :non_existing_method)
    
  end
  
  
  #
  # Array
  #
  
  def test_array_to_parameter_name
    
    assert_equal '', [].to_parameter_name
    assert_equal 'foo', %w(foo).to_parameter_name
    assert_equal 'foo[bar]', %w(foo bar).to_parameter_name
    assert_equal 'foo[bar][baz]', %w(foo bar baz).to_parameter_name
    
  end
  
  #
  # ActionView
  #
  
  include ActionView::Helpers::TagHelper
  
  def test_action_view_tag_options_visibility
    assert_nothing_raised {
      tag_options({})
    }
    assert_equal(%! class="foo" style="baz"!, tag_options({:class => 'foo', :style => 'baz'}))
  end
  

end
