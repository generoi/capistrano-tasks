require "#{File.dirname(__FILE__)}/../ssh"

desc "Open a SSH session to remote"
task :ssh do
  on roles(:all) do |host|
    cmd = SSH.new(host, fetch(:ssh_options), '/bin/bash').to_s
    info cmd
    exec cmd
  end
end

