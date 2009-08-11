
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
    assert_nothing_raised { Wice::WiceGrid.new(Person, @controller, :name => "1nvalid") }
    # we are strict about grid names
    assert_raise(Wice::WiceGridArgumentError) { Wice::WiceGrid.new(Person, @controller, :name => "céhec") }
    assert_nothing_raised { Wice::WiceGrid.new(Person, @controller, :name => "valid") }
    assert_nothing_raised { Wice::WiceGrid.new(Person, @controller, :name => :valid) }
  end

end

