
after "deploy:update_code", "oki:copy_config_files"

set :config_files, ['database.yml', 'thin.yml']

desc "Copy config files'"
namespace :oki do
  task :"copy_config_files" do
    config_files.each do |file|
      run "cp #{shared_path}/config/#{file} #{release_path}/config/#{file}"
    end
  end
end

desc "Upload config files'"
namespace :oki do
  task :"upload_config_files" do
    config_files.each do |file|
      run "test -d #{shared_path}/config || mkdir #{shared_path}/config"
      put(File.read("config/#{file}"), "#{shared_path}/config/#{file}", :mode => 0644)
    end
  end
end
