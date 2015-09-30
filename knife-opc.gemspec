Gem::Specification.new do |s|
  s.name = 'knife-oracle_public_cloud'
  s.version = '0.0.2'
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ['Daryn McCool']
  s.date = Date.today.to_s
  s.description = %q{knife plug-in for Oracle Public Cloud}
  s.email = 'mdaryn@hotmail.com'
  s.files += Dir['lib/**/*.rb']
  s.homepage = 'https://github.com/mccoold/knife-oracle_public_cloud'
  s.require_paths = ['lib']
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{OPC_Knife!}
  s.required_ruby_version = '>= 1.8'
  s.license = 'Apache-2.0'
  s.add_dependency('OPC', '~> 0.0.2')
  if s.respond_to? :specification_version then
    s.specification_version = 3
  end
end
