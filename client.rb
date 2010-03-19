require 'dist'
require 'encoding'
require 'messages'
require 'rubygems'
require 'rack'

module Dist
  class Client
    include Encoding

    def initialize(address)
      host, port = address.split(':')
      @socket = TCPSocket.new(host, port.to_i)

      @socket << Messages::REQUEST_ROLE

      receive_message Messages::SEND_ROLE_CONFIRM
      role = receive_string

      puts "Your role: #{role.dump}"

      @socket << Messages::CONFIRM_ROLE
      send_string @socket, role

      # spin up rack app
      require "roles/#{role}/app"
      Rack::Handler::Mongrel.run App.new, :Port => 9501
    end

    private

    def receive_message(expected_message=nil)
      message = @socket.recv(1)
      raise UnexpectedMessage if expected_message && expected_message != message
    end

    def receive_string
      length = @socket.recv(2).unpack('n')[0]
      return '' if !length || length < 1
      return @socket.recv(length)      
    end
  end
end

if __FILE__ == $0
  Dist::Client.new(ARGV[0])
end
