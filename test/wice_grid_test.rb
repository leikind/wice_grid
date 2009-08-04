
require File.dirname(__FILE__) + '/test_helper.rb'
require 'action_controller/test_process'

class WiceGridTest < Test::Unit::TestCase
  
  # 
  def setup
     @controller = ActionController::Base.new
  end
  
  def test_grid_parameter_must_be_a_grid
    
    assert_raise(Wice::WiceGridArgumentError) {
      Wice::WiceGrid.new(nil, @controller)
    }

    assert_raise(Wice::WiceGridArgumentError) {
      Wice::WiceGrid.new("MyModel", @controller)
    }

    assert_raise(Wice::WiceGridArgumentError) {
      Wice::WiceGrid.new(String, @controller)
    }
    
  end

  
  
  

end
