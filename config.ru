require 'sinatra'
require 'grape'
require_relative 'email-listicle'
run EmailListicle::V1::API
