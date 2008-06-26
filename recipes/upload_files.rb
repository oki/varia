
desc "Upload file to shared directory"
namespace :oki do
  task :upload_file do
    basename_file = File.basename(file)
    dir_name = "#{shared_path}/#{File.dirname(file)}"
    puts "*** Uploading #{file} to #{shared_path}/#{basename_file}"
    run "test -d #{dir_name} || mkdir -p #{dir_name}"
    put(File.read(file), "#{shared_path}/#{file}", :mode => 0644)
  end
end
