# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{distributed_demo}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Tyler McMullen}]
  s.date = %q{2010-03-25}
  s.description = %q{Demo for my talk at the Scottish Ruby Conference: Distributed Systems with Rack.}
  s.executables = [%q{distributed_demo}, %q{distributed_demo_server}]
  s.files = [%q{bin/distributed_demo}, %q{bin/distributed_demo_server}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Distributed systems demo}

  s.add_dependency 'mongrel'
  s.add_dependency 'rack'
  s.add_dependency 'net-mdns'

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
