require 'rubocop/rake_task'

desc 'RuboCop compliancy checks'
RuboCop::RakeTask.new(:rubocop)
