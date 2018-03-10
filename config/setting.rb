require 'yaml'
require 'erb'
require 'dotenv/load'

$conf = YAML.load(ERB.new(File.read('config/config.yml')).result)
