# mruby-jwt [![Build Status](https://travis-ci.org/ainoya/mruby-jwt.svg)](https://travis-ci.org/ainoya/mruby-jwt)

A mruby implementation of [JSON Web Token draft 06](http://self-issued.info/docs/draft-jones-json-web-token-06.html).

## Install by mrbgems 

- add conf.gem line to `build_config.rb` 

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :git => 'https://github.com/ainoya/mruby-jwt.git'
end
```

## Usage

    JWT.encode({"some" => "payload"}, "secret")

Note the resulting JWT will not be encrypted, but verifiable with a secret key.

    JWT.decode("someJWTstring", "secret")

If the secret is wrong, it will raise a `JWT::DecodeError` telling you as such. You can still get at the payload by setting the verify argument to false.

    JWT.decode("someJWTstring", nil, false)

## Caveats

- encryption only supports SHA256 algorithm
- this module is written in only mruby; not c implementation yet.

## License

Under the MIT License:
- see LICENSE file

## Reference

- [progrium/ruby-jwt](https://github.com/progrium/ruby-jwt)
    - mruby-jwt is the modified version from `progium/ruby-jwt` for working in mruby environment.


