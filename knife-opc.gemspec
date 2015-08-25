Gem::Specification.new do |s|
  s.name = 'knife-oracle_public_cloud'
  s.version = '0.0.1'
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ['Daryn McCool']
  s.date = %q{2015-05-28}
  s.description = %q{knife plug-in for Oracle Public Cloud}
  s.email = 'mdaryn@hotmail.com'
  s.files += Dir['lib/**/*.rb']
  s.homepage = %q{http://rubygems.org/gems/}
  s.require_paths = ['lib']
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{OPC_Knife!}
  if s.respond_to? :specification_version then
    s.specification_version = 3
    s.license = 'Apache-2.0'
    # if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    # else
  end
end
