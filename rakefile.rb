require 'albacore'
require './packages/packaging'

task :default => [:build]

desc "Build the project as debug"
task :build => 'build:debug'

directory 'dist'

namespace :build do
  
  msbuild :debug do |msb|
    # this doesnt work for me, and it builds fine w/o it. sry if it breaks for you. -josh c
    # to josh c, Please upgrade your Albacore. --tkellogg
    #msb.path_to_command =  File.join(ENV['windir'], 'Microsoft.NET', 'Framework',  'v4.0.30319', 'MSBuild.exe')
    msb.properties :configuration => :Debug
    msb.targets :Clean, :Rebuild
    msb.verbosity = 'quiet'
    msb.solution = "FluentMigrator (2010).sln"
  end
  
  desc "build the release version of the solution"
  msbuild :release do |msb|
    # this doesnt work for me, and it builds fine w/o it. sry if it breaks for you. -josh c
    #msb.path_to_command =  File.join(ENV['windir'], 'Microsoft.NET', 'Framework',  'v4.0.30319', 'MSBuild.exe')
	msb.properties :configuration => :Release, :TargetFrameworkVersion => 'v3.5'
    msb.targets :Clean, :Rebuild
    msb.verbosity = 'quiet'
    msb.solution = "FluentMigrator (2010).sln"
  end
  
  @platforms = ['x86', 'x64']
  @versions = ['v3.5', 'v4.0']
  @platforms.each do |p|
    @versions.each do |v|
      
      directory "dist/console-#{v}-#{p}"
      
      desc "build the console app for target .NET Framework version ${v}"
      task "console-#{v}-#{p}" => [:release, "compile-console-#{v}-#{p}", "dist/console-#{v}-#{p}"] do
        cp_r FileList['src/FluentMigrator.Console/bin/Release/*'], "dist/console-#{v}-#{p}"
      end
      
      msbuild "compile-console-#{v}-#{p}" do |msb|
        msb.properties :configuration => :Release, :TargetFrameworkVersion => v 
        msb.targets :Clean, :Rebuild
        msb.verbosity = 'quiet'
        msb.solution = 'src/FluentMigrator.Console/FluentMigrator.Console.csproj'
      end
      
    end
  end
  
  # FYI: `Array.product` will only work in ruby 1.9
  desc "compile the console runner for all x86/64/4.0/3.5 combinations"
  task :console => @platforms.product(@versions).map {|x| "console-#{x[1]}-#{x[0]}"}
  
end

nunit :test => :build do |nunit|
  nunit.command = "tools/NUnit/nunit-console.exe"
  nunit.assemblies "src/FluentMigrator.Tests/bin/Debug/FluentMigrator.Tests.dll"
end
  
