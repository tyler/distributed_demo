require 'rubygems'
require 'dist'
require 'encoding'
require 'messages'
require 'set'
require 'rack'
require 'master_app'
require 'ruby-debug'
require 'tcp_socket'

module Dist
  class Server
    include Encoding

    def initialize(port)
      @server = TCPServer.new(port)
      @roles = Dir[File.join(File.dirname(__FILE__), 'roles', '*')].map { |p| p.split('/').last }.inject({}) { |o,f| o[f] = Set.new; o }
    end

    attr_reader :roles

    def listen
      puts 'Listening...'

      while (tcp_session = @server.accept)
        Thread.new do
          puts "Client connected: #{tcp_session.peeraddr.inspect}"

          begin
            receive_message tcp_session, Messages::REQUEST_ROLE
            
            role = next_role
            
            tcp_session << Messages::SEND_ROLE_CONFIRM
            send_string tcp_session, role
            
            receive_message tcp_session, Messages::CONFIRM_ROLE
            confirmed_role = receive_string(tcp_session)
            
            if confirmed_role == role
              puts 'Role confirmation complete. Putting client into production.'
              @roles[role] << tcp_session
            else
              puts 'Role client sent back did not match role server sent... disconnecting client.'
              tcp_session.close
            end
          rescue UnexpectedMessage
            puts 'Unexpected message... disconnecting client.'
            tcp_session.close
          end

          p @roles
        end
      end
    end

    def next_role
      @roles.keys.min { |a,b| @roles[a].size <=> @roles[b].size }
    end

    def receive_message(session, expected_message=nil)
      message = session.recvfrom(1).first
      raise UnexpectedMessage if expected_message && expected_message != message
    end
      
    def receive_string(session)
      length = session.recvfrom(2).first.unpack('n')[0]
      return '' if length < 1
      return session.recvfrom(length).first
    end
  end
end

if __FILE__ == $0
  Thread.abort_on_exception = true
  server = Dist::Server.new(ARGV[0].to_i)
  Thread.new { server.listen }
  Rack::Handler::Thin.run MasterApp.new(server), :Port => 9505
end
