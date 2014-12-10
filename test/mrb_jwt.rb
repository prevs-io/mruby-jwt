##  
## JWT Test
##

encoded = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzb21lIjoicGF5bG9hZCJ9.Joh1R2dYzkRvDkqv3sygm5YyK8Gi4ShZqbhK2gxcs2U"

assert("JWT.encode") do
  t = JWT.encode({"some" => "payload"}, "secret")

  assert_equal(encoded, t)
end

assert("JWT.decode") do
  t = JWT.decode(encoded, "secret")
  assert_equal("payload", t.first["some"])
end

