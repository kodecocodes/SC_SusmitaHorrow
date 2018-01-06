# Uncomment this line to define a global platform for your project
platform :ios, "9.0"

inhibit_all_warnings!
use_frameworks!

target :Nearby do
	pod 'Alamofire', '~> 4.0'
	pod 'ReachabilitySwift', '~> 3'
	pod 'Marshal', '~> 1.2'
end

# Do not change the following. This is a workaround for FRAMEWORK_SEARCH_PATHS not containing ${inherited}.
# This is required so the project FRAMEWORK_SEARCH_PATHS are correctly passed onto its targets.
# (Otherwise carthage dependencies won't be found when compiled for other than Debug and Release)
post_install do |installer_representation|
	Dir.glob("#{Dir.pwd}/Pods/**/Pods*.xcconfig") do |xcconfig_file|
		xcconfig = File.read(xcconfig_file)
		if xcconfig.include? "FRAMEWORK_SEARCH_PATHS"
			puts "Adding ${inherited} to FRAMEWORK_SEARCH_PATHS in file #{xcconfig_file}..."
			xcconfig.gsub!(/^FRAMEWORK_SEARCH_PATHS *= *(.*?) *(?:(?:\${inherited})|(?:\$\(inherited\))) *([^\n]*)$/m, "FRAMEWORK_SEARCH_PATHS = ${inherited} \\1 \\2")
			File.open(xcconfig_file, "w") { |file| file << xcconfig }
		end
	end
end
