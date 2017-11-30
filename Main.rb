require 'sinatra'
require 'sinatra/cookies'
require 'mongoid'
require 'i18n'
require 'require_all'
require_all 'biz'

I18n.default_locale = :en

Mongoid.load!('./mongoid.yml', :development)