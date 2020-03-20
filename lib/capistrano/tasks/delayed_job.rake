namespace :delayed_job do
  def delayed_job_roles
    fetch(:delayed_job_server_role, :app)
  end
 
  desc 'Start the delayed_job process'
  task :start do
    on roles(delayed_job_roles) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rails, :'jobs:work'
        end
      end
    end
  end
end