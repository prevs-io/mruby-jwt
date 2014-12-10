MRuby::Gem::Specification.new('mruby-jwt') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Naoki AINOYA'
  spec.add_dependency 'mruby-pack'
  spec.add_dependency 'mruby-onig-regexp'
  spec.add_dependency 'mruby-iijson'
  spec.add_dependency 'mruby-digest'
end
