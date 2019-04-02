#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

require 'yaml'
require 'json'

KEYS = %w[apiVersion kind metadata spec].freeze

def manifest?(data)
  if data.is_a?(Hash)
    KEYS.all? do |key|
      data.key?(key)
    end
  elsif data.is_a?(Array)
    data.all? do |item|
      manifest?(item)
    end
  else
    false
  end
end

ARGV.each do |file|
  begin # rubocop:disable Style/RedundantBegin
    case file
    when /\.json$/
      $stdout.puts(file) if manifest?(JSON.parse(File.read(file)))
    when /\.ya?ml$/
      $stdout.puts(file) if manifest?(YAML.load_stream(File.read(file)))
    end
  rescue JSON::ParserError, Psych::SyntaxError => ex
    $stderr.puts("#{file} did not parse correctly: #{ex}")
  rescue Psych::DisallowedClass => ex
    $stderr.puts("#{file} #{ex}. Try wrapping values in quotes.")
  end
end
