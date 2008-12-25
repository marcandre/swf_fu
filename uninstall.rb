require 'fileutils'

dest = File.dirname(__FILE__) + "/../../../public"
FileUtils.rm  '#{dest}/javascripts/swfobject.js'
FileUtils.rm  '#{dest}/swfs/expressInstall.swf'
Dir.rmdir '#{dest}/swfs/' rescue "don't worry if directory is not empty"