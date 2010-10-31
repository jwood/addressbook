desc 'Run code coverage analysis'
task :rcov => :environment do 
  system 'rcov test/**/*.rb test/**/**/*.rb -x gems -i ^app --rails'
end

