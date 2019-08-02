require('sinatra')
require('sinatra/reloader')
require('pry')
require('rspec')
require('pg')
also_reload('./lib/**/*.rb')

DB = PG.connect({:dbname => 'volunteer_tracker'})

# this is a single line solution for requiring many files
Dir["./lib/*.rb"].each {|file| require file }
