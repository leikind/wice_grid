# encoding: utf-8
class LocalizationController < ApplicationController
  before_filter :init_locale

  def init_locale
    if params[:lang]
      session[:lang] = params[:lang]
    end

    session[:lang] = :nl unless session[:lang]

    I18n.locale = session[:lang]
  end

  def index
    @tasks_grid = initialize_grid(Task,
      include: [:priority, :status, :project, :assigned_users],
      order: 'statuses.name',
      custom_order: {
        'tasks.priority_id' => 'priorities.name',
        'tasks.status_id' => 'statuses.position',
        'tasks.project_id' => 'projects.name'
      }
    )
  end
end
