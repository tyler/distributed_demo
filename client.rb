$: << './lib'

require 'dist'
require 'encoding'
require 'messages'
require 'rubygems'
require 'rack'

module Dist
  class Client
    include Encoding

    def initialize(address)
      leave_a_will

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
      Thread.new { Rack::Handler::Mongrel.run App.new, :Port => 9501 }

      while true
        receive_message Messages::REQUEST_HEARTBEAT
        @socket << Messages::HEARTBEAT
      end
    rescue UnexpectedMessage
      puts 'Disconnected.'
    end

    private

    def leave_a_will
      graceful_death = lambda { @socket.close }
      %w[INT TERM].each { |code| Signal.trap(code, &graceful_death) }
    end

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
  Thread.abort_on_exception = true
  Dist::Client.new(ARGV[0])
end
