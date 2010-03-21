require 'erb'
require 'array'
require 'ruby-debug'
require 'sinatra/base'

class MasterApp < Sinatra::Base
  def initialize(demo_server)
    @demo_server = demo_server
  end

  get '/disconnect' do
    @demo_server.disconnect_ip params[:ip]
    redirect '/status'
  end

  get '/status' do
    erb :status
  end

  get '/debug' do
    debugger
  end

  get '/' do
    @roles = @demo_server.roles.inject({}) { |o,(role,nodes)|
      node = nil
      while !node && nodes.size > 0
        node = nodes.to_a.rand
        if node.closed?
          nodes.delete(node)
          node = nil
        end
      end
      o[role] = node && node.remote_ip
      o
    }

    erb :master
  end
end
