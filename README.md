# mruby-jwt

A mruby implementation of [JSON Web Token draft 06](http://self-issued.info/docs/draft-jones-json-web-token-06.html).

## install by mrbgems 

- add conf.gem line to `build_config.rb` 

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :git => 'https://github.com/ainoya/mruby-jwt.git'
end
```

## Caveats

- this module is written in only mruby; not c implementation yet.

## License

under the MIT License:
- see LICENSE file
