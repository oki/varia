#!/usr/local/bin/ruby -w

require 'tempfile'
require 'vim_snippet'

tmp = Tempfile.new('snippet')
system("vim #{tmp.path}") # edytujemy w vimie zawartosc snipeta

snippet = IO.read(tmp.path) # odczutujemy zapisany snipecik
print "Snippet name: "
snippet_name = gets.chomp! # podajemy nazwe

puts VimSnippet.new(:name => snippet_name, :code => snippet).out
