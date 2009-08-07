# More or less complete

require File.dirname(__FILE__) + '/test_helper.rb'
require 'action_controller/test_process'

class WiceGridMiscTest < Test::Unit::TestCase
  
  def test_string_conditions_to_array_cond
    assert_equal ["1 = 1"], Wice.string_conditions_to_array_cond("1 = 1")
    assert_equal ["1 = 1"], Wice.string_conditions_to_array_cond(["1 = 1"])
  end
  
  def test_unite_conditions    
    assert_equal "foo IS NULL", Wice.unite_conditions("foo IS NULL", nil)
    assert_equal "foo IS NULL", Wice.unite_conditions(nil, "foo IS NULL")
    
    assert_equal "foo IS NULL", Wice.unite_conditions("foo IS NULL", [])
    assert_equal "foo IS NULL", Wice.unite_conditions('', "foo IS NULL")
    
    assert_raise(Wice::WiceGridException) { Wice.unite_conditions('', {})}
    
    assert_equal ["foo IS NULL and bar > 5"], Wice.unite_conditions("foo IS NULL", "bar > 5")
    assert_equal ["foo IS NULL and bar > ?", 5], Wice.unite_conditions("foo IS NULL", ["bar > ?", 5])
    
    assert_equal ['name = ? and age > ?', 'yuri', 30], Wice.unite_conditions(['name = ?', 'yuri'], ['age > ?', 30])
    
    assert_equal ['name is not null and age > ?',  30], Wice.unite_conditions('name is not null', ['age > ?', 30])
  end
  
  def test_get_query_store_model
    assert_equal(SavedQuery, Wice.get_query_store_model)
  end

  class InvalidQueryStorageModel
  end
  class InvalidQueryStorageModel2
    def self.list
    end
  end
  class InvalidQueryStorageModel3
    def self.list(a,b,c)
    end
  end
  class ValidQueryStorageModel
    def self.list(a,b)
    end
  end

  def test_validate_query_model
    assert_raise(Wice::WiceGridArgumentError){Wice.validate_query_model(InvalidQueryStorageModel)}
    assert_raise(Wice::WiceGridArgumentError){Wice.validate_query_model(InvalidQueryStorageModel2)}
    assert_raise(Wice::WiceGridArgumentError){Wice.validate_query_model(InvalidQueryStorageModel3)}
    assert_nothing_raised{Wice.validate_query_model(ValidQueryStorageModel)}
    assert_equal(true, Wice.validate_query_model(ValidQueryStorageModel))
  end

  def test_deprecated_call
    opts = {:foo => :baz, :old_name => 23}
    Wice.deprecated_call(:old_name, :new_name, opts)
    assert_equal({:foo => :baz, :new_name => 23} , opts)
  end
end