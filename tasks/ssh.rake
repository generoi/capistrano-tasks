desc "Open a SSH session to remote"
task :ssh do
  on roles(:all) do |host|
    user = host.user + "@" if !host.user.nil?
    exec "ssh -t #{user}#{host.hostname} '/bin/bash'"
  end
end

