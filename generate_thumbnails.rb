#!/usr/bin/env ruby

require 'rubygems'
require 'RMagick'
include Magick

Dir.chdir(Dir.getwd + '/public/images/tour/')

existing_thumbs = Dir["thumb-*.jpg"]
existing_thumbs.each do |thumb|
  puts "Deleting #{thumb}"
  File.delete(thumb)
end

images = Dir["*.jpg"]
images.each do |image|
  img = Magick::ImageList.new(image)
  thumb = img.scale(250, 150)
  puts "Writing thumb: thumb-#{image}"
  thumb.write "thumb-#{image}"
end
