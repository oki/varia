
my_servers = %w(
    md6.org 
    magnus.x-men.pl
)

role :server do
    my_servers
end

desc "Upload configs: vim, irb, rails"
task :upload_configs do
    home,file = ENV['HOME'], "config-pack.tar.bz2"
    puts %x(cd #{home}; tar jcf #{file} .vimrc .vim .irbrc .railsrc)
    upload "#{home}/#{file}", file
    run "tar jxf #{file}; rm #{file}"
    %x(rm #{home}/#{file})
end
