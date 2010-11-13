#!/usr/bin/ruby
require 'reve'

# Create an instance of the API
api = Reve::API.new

fids = [ 797400947 ] # converting from these IDs
fnames = [ 'CCP Garthagk' ] # converting from these names

ids = api.character_name({ :ids => fids })
names = api.character_id({ :names => fnames })

puts 'names to IDs output'
puts names.inspect

puts 'IDs to names output'
puts ids.inspect