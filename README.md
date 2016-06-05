# Reve

[![Build Status](https://travis-ci.org/lisa/reve.svg?branch=master)](https://travis-ci.org/lisa/reve)

Reve is a library for the Eve Online API written in Ruby.

# Examples

The following are examples using the library.

## Convert player names to character IDs

    require 'reve'
    require 'pp'
    
    api = Reve::API.new
    
    ids = api.character_id( { :names => [ "CCP Garthagk" ] } )
    puts 'Names to IDs output:'
    pp names
    
    # Prints:
    names to IDs output
    [#<Reve::Classes::Character:0x4d98e55c
      @corporation_id=0,
      @corporation_name=nil,
      @id=797400947,
      @name="CCP Garthagk">]

# Contributing

Reve is in "maintenance mode." The author, [Lisa Seelye](https://github.com/lisa), is mostly hands-off and gladly accepts pull requests. 