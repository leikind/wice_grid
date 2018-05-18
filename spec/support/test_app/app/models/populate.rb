# encoding: utf-8
module Populate
  def self.me
    [Priority, ProjectRole, Status, Company, Version, User, UserProjectParticipation, Project, Task].map(&:delete_all)

    %w(Urgent High Normal Low Anecdotic).each_with_index do |priority_name, i|
      Priority.create!(position: i, name: priority_name)
    end

    %w(Manager Customer Developer QualityAssurance).each_with_index do |role_name, i|
      ProjectRole.create!(name: role_name, can_close_tasks: i < 2)
    end

    %w(New Assigned Started Resolved Duplicate Cancelled Postponed Closed Verified).each_with_index do |status_name, i|
      Status.create!(name: status_name, position: i)
    end

    ['MNU', 'SkyNet', 'Coders Unlimited', 'Shift-Command-4 Limited'].each do |company_name|
      Company.create!(name: company_name)
    end

    companies = Company.all.index_by(&:name)
    version_statuses = %w(development testing production)

    { 'Ultimate Website' => { customer: 'MNU', supplier: 'Coders Unlimited', versions: ['1.0', '1.1', '1.2', '2.0', '3.0'] },
      'Super Game' => { customer: 'MNU', supplier: 'Shift-Command-4 Limited', versions: ['1.0', '88.1', '99.0'] },
      'Divine Firmware' => { customer: 'SkyNet', supplier: 'Coders Unlimited', versions: ['6.0', '7.1', '8.0'] } }.each do |project, data|
      project = Project.create!(name: project, customer: companies[data[:customer]], supplier: companies[data[:supplier]])

      data[:versions].each do|version|
        Version.create!(name: version, project: project, status: version_statuses[rand(3)])
      end
    end

    projects = Project.includes(:users).all
    project_roles = ProjectRole.all

    ['Wikus van de Merwe', 'Grey Bradnam', 'Christopher Johnson', 'Piet Smit', 'Fundiswa Mhlanga', 'Tania van de Merwe',
     'Obesandjo', 'Dirk Michaels', 'Ross Pienaar', 'Koobus Venter', 'Dirk Michaels', 'Sarah Livingstone'].each do |user|
       user = User.create!(name: user)

       (rand(3) + 1).times do
         UserProjectParticipation.create(
           user: user,
           project: projects.sample,
           project_role: project_roles.sample
         )
       end
    end

    projects = Project.includes([:users, :versions]).all
    statuses = Status.all
    priorities = Priority.all

    500.times do
      task_name = Faker::Lorem.words(rand(3) + 1).join(' ')

      project  = projects.sample

      assigned_users = Set.new

      rand(4).times do
        assigned_users << project.users.sample
      end

      a = Task.create!(
        title: task_name,
        description: Faker::Lorem.sentence,
        project: project,
        created_by: project.users.sample,
        status: statuses.sample,
        priority: (rand(4) == 0 ? nil : priorities.sample),
        assigned_users: assigned_users.to_a,
        relevant_version: (rand(2) == 0 ? nil : project.versions.sample),
        expected_version: (rand(2) == 0 ? nil : project.versions.sample),
        estimated_time: rand(20) + 1,
        due_date: Date.current.advance(days: (rand(300) + 100)),
        created_at: (rand(100) + 100).days.ago,
        updated_at: rand(100).days.ago,
        archived: rand(10) == 0
      )
    end
  end
end
