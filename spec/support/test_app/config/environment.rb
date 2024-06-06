# encoding: utf-8
# Load the rails application
require_relative 'application'

# Initialize the rails application
Rails.application.initialize!

# fix for bootstrap-sass that uses depricated Regexp
indices = []
strings = []
precompile = Rails.application.config.assets.precompile
precompile.each_with_index do |string_or_regexp, index|
  if string_or_regexp.is_a? Regexp
    indices << index
    match = string_or_regexp.source.match /(.*)\\\.\(\?:(.*?)\??\)\$$/
    match[2].split('|').each do |ext|
      strings << "#{match[1]}.#{ext}"
    end
  end
end
indices.reverse.each do |index|
  precompile.delete_at index
end
strings.each do |string|
  precompile << string
end
