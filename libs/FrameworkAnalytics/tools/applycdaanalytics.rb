#!/usr/bin/ruby

#go to the right folder
if m = Dir.pwd.match(/FrameworkAnalytics\/tools$/)
#  p "moving up!"
  Dir.chdir("../../..")
end

#config goes here:
exclusionfiles=["cdaAnalytics", "cdaAnalyticsFlurryTracker", "cdaAnalyticsGoogleTracker"]
filestomatch = File.join("**", "*.{h,m,mm}")
files = Dir.glob(filestomatch)
files=files-["libs/FrameworkAnalytics/cdaAnalytics.h"]-["libs/FrameworkAnalytics/cdaAnalytics.m"]-["libs/FrameworkAnalyticsGoogleWrapper/cdaAnalyticsGoogleTracker.h"]-["libs/FrameworkAnalyticsGoogleWrapper/cdaAnalyticsGoogleTracker.m"]-["libs/FrameworkAnalyticsFlurryWrapper/cdaAnalyticsFlurryTracker.h"]-["libs/FrameworkAnalyticsFlurryWrapper/cdaAnalyticsFlurryTracker.m"]

cwd = Dir.pwd
filepaths=[]
files.each do |file|
  addfile = true
  exclusionfiles.each do |exclude|
    if m = file.match(/#{exclude}/)
      addfile = false
    end
  end
  if addfile == true
    filepaths << File.join(cwd,file)
  end
end

totallines = 0
modifiedFiles = 0
errorCount = 0

def parseFile(filepath)
  contents=""
  filecontent=[]
  flurrylines=[]
  dictionarylines=[]
  cat=[]
  event=[]
  label=[]
  dict=[]
  linenumber=0
  flurryliteralCount=0
  errors = 0
  returnVals=[]
  
  f = File.open(filepath, "r") 
  f.each_line do |line|
    require 'iconv' unless String.method_defined?(:encode)
    if String.method_defined?(:encode)
      line.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
      line.encode!('UTF-8', 'UTF-16')
    else
      ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
      line = ic.iconv(line)
    end
    
    inlinedict = false;
    e = ""
    l = ""
    c = ""
    if m = line.match(/\[FlurryAnalytics logEvent:(@\".*\")(\s*timed:YES)*\];/)
      flurryliteralCount+=1
      line.gsub!(/\[FlurryAnalytics logEvent:(@\".*\")(\s*timed:YES)*\];/, "[[cdaAnalytics sharedInstance] trackEvent:#{$1.strip()}#{$2}];")
      p "#{filepath}:#{linenumber+1} => #{line}"
    elsif m = line.match(/\[FlurryAnalytics logEvent:(@\".*\")\s*withParameters:\s*(\w+)\s*\];/)
      print("matched dictionary:#{$2} event:#{$1}\n")
      dict << $1
      flurryliteralCount+=1
      dictionarylines << linenumber
      p "#{filepath}:#{linenumber+1} => #{line}"
    elsif m = line.match(/\[FlurryAnalytics logEvent:(.+)\s+withParameters:\s*\[NSDictionary dictionaryWithObjectsAndKeys:(.+),\s*nil\]\];/)
      print("matched raw event cat: #{$1}\n")
      x= $1.strip()
      c = x;
      inlinedict = true
    end
    
    if inlinedict 
      matchError = false
      if m = line.match(/dictionaryWithObjectsAndKeys:(.+),\s*nil\]\];/)
        print("matched event action+label: #{$1}\n")
        a = $1.split(',')
        l = a[a.length-1].strip()
        x = ""
        #if there are more than 2 comma seperated values we take the last one as the label and join all the ones before back as the action!
        if a.length > 2
          (0..a.length-2).each do |i|
            if i > 0
              x += ','
            end
            x += a[i]
          end
        else
          x = a[0]
        end
        e = x.strip()
      else
        matchError = true
        p "\nERROR: parse error at line: #{linenumber+1}\n"
        errors+=1
      end
      
      if !matchError
        unless c.eql?("") && e.eql?("") && l.eql?("")
          cat << c
          event << e
          label << l
          flurrylines << linenumber
        end
      end
    end
    
    filecontent << line
    linenumber+=1
  end
  f.close
  
  #removeing the old analytics code and replacing with new
  ci = 0
  flurrylines.each do |c|
    filecontent[c].gsub!(/\[FlurryAnalytics logEvent:.+/, "[[cdaAnalytics sharedInstance] trackEvent:#{event[ci]} inCategory:#{cat[ci]} withLabel:#{label[ci]} andValue:-1];")
    if m = filecontent[c+1].match(/NSError \*error;/)
      p "ga found!! removing..."
      (1..9).each do |i|
        filecontent[c+i] = ""
      end
    end
    p "#{filepath}:#{c+1} => #{filecontent[c]}"
    ci += 1
  end
  
  ci = 0
  dictionarylines.each do |c|
    if m = filecontent[c-1].match(/NSDictionary\s*\*\w+\s*=\s*\[NSDictionary\s*dictionaryWithObjectsAndKeys:\[NSString stringWithFormat:@\"(.+)\", (.+)\], @\".+\", nil\];/)
      a = $1.split(',')
      if a.length > 2
        p "\nERROR: dictionary parse error at line: #{c+1} => #{filecontent[c-1]}\n"
        errors+=1
      else
        x = $1.strip()
        y = $2.strip()
        p "found dictionary!!! #{filecontent[c-1]}"
        p x
        p y
        filecontent[c].gsub!(/\[FlurryAnalytics logEvent:(@\".*\")\s*withParameters:\s*(\w+)\s*\];/, "[[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:#{dict[ci].chop()}#{x}\", #{y}]];")
        p "#{filepath}:#{c+1} => #{filecontent[c]}"
        filecontent[c-1] = ""
      end
    else
      p "did not find dictionary!!! => #{filecontent[c-1]}!"      
    end
    ci += 1
  end
  
  
  if flurrylines.length + flurryliteralCount > 0
    filecontent.each do |line|
       contents += line;
    end
    unless ARGV[0].eql?("apply")
      print "dry run on: #{filepath}\n"
    else
      f = File.open(filepath, "w+") 
      f.puts contents
      f.close
      print "real run on: #{filepath}"
    end
  end
  returnVals << flurrylines.length + flurryliteralCount
  returnVals << errors
  return returnVals
end

filepaths.each do |file|
  p "parsing file #{file} ..."
  vals = parseFile(file)
  if vals[0] > 0
    totallines += vals[0]
    modifiedFiles += 1
  end
  errorCount += vals[1]
  p "done parsing #{file}"
end
p "total lines replaced: #{totallines}"
p "total lines with parse errors: #{errorCount}"
p "number of files modified: #{modifiedFiles}"

