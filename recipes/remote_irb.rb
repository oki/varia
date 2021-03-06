# http://snippets.dzone.com/posts/show/2485
desc "remotely console" 
task :console, :roles => :app do
    input = ''
    run "cd #{current_path} && ./script/console #{ENV['RAILS_ENV']}" do |channel, stream, data|
        next if data.chomp == input.chomp || data.chomp == ''
        print data
        channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
    end
end
