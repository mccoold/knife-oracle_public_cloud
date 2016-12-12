Gem::Specification.new do |s|
  s.name = 'knife-oracle_public_cloud'
  s.version = '0.1.7'
  s.authors = ['Daryn McCool']
  s.date = Date.today.to_s
  s.description = 'knife plug-in for Oracle Cloud, IaaS (Bare Metal and Nimbula), and PaaS cloud assets'
  s.email = 'mdaryn@hotmail.com'
  s.files += Dir['lib/**/*.rb']
  s.homepage = 'http://github.com/mccoold/knife-oracle_public_cloud/blob/master/README.md'
  s.require_paths = ['lib']
  s.rubygems_version = %q{1.6.2}
  s.summary = 'knife plug-in for Oracle Cloud, IaaS (Bare Metal and Nimbula), and PaaS'
  s.required_ruby_version = '>= 1.8'
  s.license = 'Apache-2.0'
  s.add_dependency 'oracle_public_cloud_client', '>= 0.5.0'
  s.add_dependency 'OPC', '>= 0.4.0'
end
