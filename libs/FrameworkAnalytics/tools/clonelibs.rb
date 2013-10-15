#!/usr/bin/ruby

#config goes here:
repos=["FrameworkAnalytics", "FrameworkAnalyticsGoogleWrapper", "FrameworkAnalyticsFlurryWrapper"]
#xsellrepos=["asi-http-request", "FrameworkXSellService"]

def writeIgnoreFile(name)
  f = File.open(name, "w+")
  f.puts ".git\n.gitignore\n.gitattributes"
  f.close
end

def prepare(projectName)
  cwd = Dir.pwd
  unless projectName.eql?("FrameworkAnalytics")
    p `git clone git@github.com:callaway/#{projectName}.git`
  end
  p `svn add #{projectName}`
  Dir.chdir("#{cwd}/#{projectName}") do
    p Dir.pwd
    p `svn revert --depth infinity .git`
    p `svn revert .gitignore`
    p `svn revert .gitattributes`
    writeIgnoreFile("temp")
    p `svn propset svn:ignore -F temp .`
    File.delete("temp")
    if projectName.eql?("FrameworkAnalyticsGoogleWrapper")
      p `svn add libs/libGoogleAnalytics.a`
    elsif projectName.eql?("FrameworkAnalyticsFlurryWrapper")
      p `svn add libs/libFlurryAnalytics.a`
    end
  end
  p Dir.pwd
end

if m = Dir.pwd.match(/FrameworkAnalytics\/tools$/)
#  p `echo moving up!`
  Dir.chdir("../..")
end
repos.each do |project|
  prepare(project)
end
