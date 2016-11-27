desc "Disply summary of services"
task :monit do
  invoke "monit:summary"
end
namespace :monit do
  %w[status summary].each do |command|
    desc "Display #{command} of all monit services"
    task command do
      on roles(:all) do |host|
        puts capture(:sudo, :monit, command)
      end
    end
  end
end
