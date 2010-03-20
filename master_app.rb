require 'erb'
require 'array'
require 'ruby-debug'

class MasterApp
  def initialize(demo_server)
    @demo_server = demo_server
    @view = ERB.new(File.read('master.erb'))
  end

  def call(env)
    debugger if env['REQUEST_PATH'] =~ /^\/debug/

    roles = @demo_server.roles.inject({}) { |o,(role,nodes)|
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
    return [200, { 'Content-Type' => 'text/html' }, [@view.result(binding)]]
  end
end
