
require File.dirname(__FILE__) + '/test_helper.rb'
require 'action_controller/test_process'

class ObjectWithoutStringRepresentation
  undef_method :to_s
end

class WiceGridTest < Test::Unit::TestCase
  
  # 
  def setup
     @controller = ActionController::Base.new
     @controller.params = {}
  end
  
  def test_grid_parameter_must_be_a_grid
    assert_raise(Wice::WiceGridArgumentError) { Wice::WiceGrid.new(nil, @controller) }
    assert_raise(Wice::WiceGridArgumentError) { Wice::WiceGrid.new("MyModel", @controller) }
    assert_raise(Wice::WiceGridArgumentError) { Wice::WiceGrid.new(String, @controller) }
  end

  def test_after_parameter_validation
    assert_raise(Wice::WiceGridArgumentError) { Wice::WiceGrid.new(Person, @controller, :after => "do something") }
    assert_raise(Wice::WiceGridArgumentError) { Wice::WiceGrid.new(Person, @controller, :after => 12) }
    assert_nothing_raised { Wice::WiceGrid.new(Person, @controller, :after => lambda { } ) }
    assert_nothing_raised { Wice::WiceGrid.new(Person, @controller, :after => :symbol) }
  end
  
  def test_grid_name_parameter_validation
    object_without_to_s = ObjectWithoutStringRepresentation.new
    assert !object_without_to_s.respond_to?(:to_s)
    assert_raise(Wice::WiceGridArgumentError) { Wice::WiceGrid.new(Person, @controller, :name => object_without_to_s) }
    # assert_raise(Wice::WiceGridArgumentError) { Wice::WiceGrid.new(Person, @controller, :name => "1nvalid") }
    # assert_raise(Wice::WiceGridArgumentError) { Wice::WiceGrid.new(Person, @controller, :name => "échec") }
    assert_nothing_raised { Wice::WiceGrid.new(Person, @controller, :name => "valid") }
    assert_nothing_raised { Wice::WiceGrid.new(Person, @controller, :name => :valid) }
  end

end

class WiceMiscTest < Test::Unit::TestCase
  
  def test_string_conditions_to_array_cond
    assert_equal ["1 = 1"], Wice.string_conditions_to_array_cond("1 = 1")
    assert_equal ["1 = 1"], Wice.string_conditions_to_array_cond(["1 = 1"])
  end
  
  def test_unite_conditions    
    #assert_equal "foo IS NULL", Wice.unite_conditions("foo IS NULL", nil)
    #assert_equal ["foo IS NULL"], Wice.unite_conditions("foo IS NULL", "")
    assert_equal ["foo IS NULL and bar > 5"], Wice.unite_conditions("foo IS NULL", "bar > 5")
    assert_equal ["foo IS NULL and bar > ?", 5], Wice.unite_conditions("foo IS NULL", ["bar > ?", 5])
  end
  
end