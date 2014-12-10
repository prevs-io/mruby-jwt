#
# JSON Web Token implementation
#
# Should be up to date with the latest spec:
# http://self-issued.info/docs/draft-jones-json-web-token-06.html
#
# This implementation is from https://github.com/progrium/ruby-jwt .
# Copyright (c) 2011 Jeff Lindsay
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

module JWT
  class DecodeError < StandardError; end
  class ExpiredSignature < StandardError; end

  module Json
    def decode_json(encoded)
      JSON.parse(encoded)
      rescue Exception
      raise DecodeError.new("Invalid segment encoding")
    end

    def encode_json(raw)
      JSON.generate(raw)
    end

    module_function :decode_json, :encode_json
  end

  def sign(algorithm, msg, key)
    if ["HS256", "HS384", "HS512"].include?(algorithm)
      sign_hmac(algorithm, msg, key)
    else
      raise NotImplementedError.new("Unsupported signing method")
    end
  end

  def sign_hmac(algorithm, msg, key)
    Digest::HMAC.digest(msg, key, Digest::SHA256)
  end

  def base64url_decode(str)
    str += "=" * (4 - str.length%4)
    str.gsub(/-/, "+").gsub(/_/, "/").unpack('m').first
  end

  def base64url_encode(str)
    [str].pack('m').gsub(/\+/, "-").gsub(/\//, "_").gsub(/[\n=]/, "")
  end

  def encoded_header(algorithm="HS256", header_fields={})
    header = {"typ" => "JWT", "alg" => algorithm}.merge(header_fields)
    base64url_encode(JWT::Json.encode_json(header))
  end

  def encoded_payload(payload)
    base64url_encode(JWT::Json.encode_json(payload))
  end

  def encoded_signature(signing_input, key, algorithm)
    if algorithm == "none"
      ""
    else
      signature = sign(algorithm, signing_input, key)
      base64url_encode(signature)
    end
  end

  def encode(payload, key, algorithm="HS256", header_fields={})
    algorithm ||= "none"
    segments = []
    segments << encoded_header(algorithm, header_fields)
    segments << encoded_payload(payload)
    segments << encoded_signature(segments.join("."), key, algorithm)
    segments.join(".")
  end

  def raw_segments(jwt, verify=true)
    segments = jwt.split(".")
    required_num_segments = verify ? [3] : [2,3]
    raise DecodeError.new("Not enough or too many segments") unless required_num_segments.include? segments.length
    segments
  end

  def decode_header_and_payload(header_segment, payload_segment)
    header = JWT::Json.decode_json(base64url_decode(header_segment))
    payload = JWT::Json.decode_json(base64url_decode(payload_segment))
    [header, payload]
  end

  def decoded_segments(jwt, verify=true)
    header_segment, payload_segment, crypto_segment = raw_segments(jwt, verify)
    header, payload = decode_header_and_payload(header_segment, payload_segment)
    signature = base64url_decode(crypto_segment.to_s) if verify
    signing_input = [header_segment, payload_segment].join(".")
    [header, payload, signature, signing_input]
  end

  def decode(jwt, key=nil, verify=true, options={}, &keyfinder)
    raise DecodeError.new("Nil JSON web token") unless jwt

    header, payload, signature, signing_input = decoded_segments(jwt, verify)
    #Apache.errlogger Apache::APLOG_NOTICE, "splited: #{header}, #{payload}, #{signature}, #{signing_input}"
    raise DecodeError.new("Not enough or too many segments") unless header && payload
    
    default_options = {
      :verify_expiration => true,
      :leeway => 0
    }
    options = default_options.merge(options)
    
    if verify
      algo, key = signature_algorithm_and_key(header, key, &keyfinder)
      verify_signature(algo, key, signing_input, signature)
    end
    if options[:verify_expiration] && payload.include?('exp')
      raise ExpiredSignature.new("Signature has expired") unless payload['exp'] > (Time.now.to_i - options[:leeway])
    end
    return payload,header
  end

  def signature_algorithm_and_key(header, key, &keyfinder)
    if keyfinder
      key = keyfinder.call(header)
    end
    [header['alg'], key]
  end

  def verify_signature(algo, key, signing_input, signature)
    begin
      if ["HS256", "HS384", "HS512"].include?(algo)
        raise DecodeError.new("Signature verification failed") unless secure_compare(signature, sign_hmac(algo, signing_input, key))
      else
        raise DecodeError.new("Algorithm not supported")
      end
    rescue Exception
      raise DecodeError.new("Signature verification failed")
    end
  end

  # From devise
  # constant-time comparison algorithm to prevent timing attacks
  def secure_compare(a, b)
    return false if a.nil? || b.nil? || a.empty? || b.empty? || a.bytesize != b.bytesize
    l = a.unpack "C#{a.bytesize}"

    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end

  module_function :sign
  module_function :sign_hmac
  module_function :base64url_decode
  module_function :base64url_encode
  module_function :encoded_header
  module_function :encoded_payload
  module_function :encoded_signature
  module_function :encode
  module_function :raw_segments
  module_function :decode_header_and_payload
  module_function :decoded_segments
  module_function :decode
  module_function :signature_algorithm_and_key
  module_function :verify_signature
  module_function :secure_compare
end
