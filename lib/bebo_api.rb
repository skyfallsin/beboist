require 'bebo_api/base'
require 'bebo_api/method'
require 'bebo_api/bebo_types'

module BeboAPI  
  class MissingParameterError < StandardError; end
  class InvalidParameterTypeError < StandardError; end
end