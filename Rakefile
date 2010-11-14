require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => :redoc

desc "Generate Docs"
Rake::RDocTask.new("doc") { |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'Reve API Documentation'
  rdoc.options << '--line-numbers' << '--inline-source' << '--all'
  rdoc.rdoc_files.include('./ChangeLog')
  rdoc.rdoc_files.include('./README.rdoc')
  rdoc.rdoc_files.include('*.rb')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('test/**/*')
}

if File.exists?('.git')
  begin
    require 'jeweler'
    Jeweler::Tasks.new do |s|
      s.name = "reve"
      s.rubyforge_project = "reve"
      s.author = "Lisa Seelye"
      s.email = "lisa@thedoh.com"
      s.homepage = "http://github.com/lisa/reve"
      s.platform = Gem::Platform::RUBY
      s.summary = "Reve is a Ruby library to interface with the Eve Online API"
      s.files = FileList["Rakefile","VERSION","LICENSE", "lib/**/*.rb","reve.rb","tester.rb","init.rb"].to_a
      s.require_path = "lib"
      s.test_files = FileList["test/test_reve.rb","test/xml/**/*.xml"].to_a
      s.has_rdoc = true
      s.extra_rdoc_files = ["ChangeLog"]
      s.add_dependency("hpricot",">= 0.6")
    end
  rescue LoadError
    puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
  end
end

