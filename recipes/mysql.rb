# odczytac z nazwe bazy z konfiga, zrobic backup
# nastepnie sciaganac go na naszego kompa, 
# zakladamy oczywiscie ze nasz komupter jest niezniszczalny i backupy beda na nim bezpieczne.

# http://weblog.jamisbuck.org/2008/5/2/capistrano-2-3-0
# http://blog.caboo.se/articles/2006/12/28/a-better-capistrano-backup

set :backup_ext, "dump.#{Time.new.strftime('%Y-%m-%d_%H:%M:%S')}.sql.bz2"

namespace :mysql do

  desc 'Backup production database'
  task :backup do
    filename = "#{application}.#{backup_ext}"
    text = capture "cat #{deploy_to}/current/config/database.yml"
    yaml = YAML::load(ERB.new(text).result)
    yaml = yaml['production'].respond_to?(:to_hash) ? yaml['production'] : yaml[yaml['production']]
    username, password, database = yaml['username'], yaml['password'], yaml['database']

    on_rollback { run "rm #{filename}" }
    run "mysqldump -u #{username} -p #{database} | bzip2 -c > #{filename}" do |ch, stream, out|
      ch.send_data "#{password}\n" if out =~ /^Enter password:/
    end

    %x([ -d backups ] || mkdir backups)
    download filename, "backups/#{filename}", :via => :scp
    run "rm #{filename}"
  end

  desc 'Synchronize production database with local database'
  task :sync do
     print "Syncing... "
     filename = "#{application}.#{backup_ext}"
     yaml = YAML::load(ERB.new(%x(cat config/database.yml)).result) 
     yaml = yaml['development'].respond_to?(:to_hash) ? yaml['development'] : yaml[yaml['development']]

     username, password, database = yaml['username'], yaml['password'], yaml['database']
     %x(bzip2 -c -d backups/#{filename} | mysql -u #{username} #{password.nil? ? " " : "-p".password} #{database})
     puts "Done"
  end
  before "mysql:sync", "mysql:backup"


end
