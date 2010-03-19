require 'erb'

class App
  def initialize
    @view = ERB.new(File.read(File.join(File.dirname(__FILE__), 'view.erb')))
  end

  def call(env)
    return [200, { 'Content-Type' => 'text/html' }, [@view.result(binding)]]
  end
end
