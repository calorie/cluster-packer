Gem::Specification.new do |s|
  s.name = "cluster"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["YuuShigetani"]
  s.date = "2014-06-14"
  s.description = "cluster"
  s.email = "s2g4t1n2@gmail.com"
  s.executables = ["cluster"]
  s.files = [
    ".rspec",
    "bin/cluster",
    "cluster.gemspec"
  ]
  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.homepage = "http://github.com/calorie/cluster"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "cluster"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thor>, [">= 0"])
      s.add_runtime_dependency(%q<happymapper>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
    else
      s.add_dependency(%q<thor>, [">= 0"])
      s.add_dependency(%q<happymapper>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
    end
  else
    s.add_dependency(%q<thor>, [">= 0"])
    s.add_dependency(%q<happymapper>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
  end
end

