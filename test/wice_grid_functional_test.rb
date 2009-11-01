
require File.dirname(__FILE__) + '/test_helper.rb'

require 'action_controller/test_process'

class TestControllerBase < ActionController::Base
  
  def render_wice_grid_view(name)
    render :file => File.join(File.dirname(__FILE__), "views/#{name}.html.erb")
  end
  
  def rescue_action(e) 
    raise e
  end
  
end

class ProjectsController < TestControllerBase
  
  def index
    @grid = initialize_grid(Project, :order => 'created_at', :order_direction => 'DESC')
    render_wice_grid_view('simple_projects_grid')
  end

  def index2
    @grid = initialize_grid(Project, :include => :person, :order => 'created_at', :order_direction => 'DESC')
    render_wice_grid_view('projects_and_people_grid')
  end

end

# class TasksController < TestControllerBase
#   
#   def index
#     @grid = initialize_grid(Task, :include => [{:project => :person}, :person])
#   end
# 
# end

class WiceGridFunctionalTest < ActionController::TestCase
  
  def setup
    
      @controller = ProjectsController.new
      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new

      ActionController::Routing::Routes.draw do |map|
        map.resources :projects
        map.resources :tasks
      end
      
  end
  
  def test_index_without_parameters
    get :index
    assert_response :success
    assert css_select("table")
  end

  def test_index2_without_parameters
    # 
    # get :index2
    #    assert_response :success
    #assert css_select("table")
  end

end
