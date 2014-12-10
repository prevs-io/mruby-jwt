MRuby::Build.new do |conf|
  toolchain :gcc
  conf.gembox 'default'
  conf.gem '../mruby-jwt'

  conf.gem :git => 'https://github.com/iij/mruby-io.git'
  conf.gem :git => 'https://github.com/iij/mruby-pack.git'
  conf.gem :github => 'mattn/mruby-onig-regexp'
  conf.gem :github => 'iij/mruby-digest'
  conf.gem :github => 'iij/mruby-iijson'
end
