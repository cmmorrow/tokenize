defmodule TokenizeTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Tokenize

  @usage """
  Usage: tokenize [Options] [ARGS]

  A command line tool for generating JSON web tokens.

  ARGS - An optional JSON string to use as private claims in the payload.

  Options:
    --algorithm     The signing algorithm to use. Must be a valid HMAC, RSA, or
                    ECDSA algorithm name.

    --secret        An optional signing secret to use.
    --iss           Token issuer.
    --jti           Unique token Id.
    --sub           Token subject.
    --aud           Intended token audience.
    --iat           Issued at time.
    --exp           Expiration time.
    --nbf           Not before time.
  """

  test "arg with no options" do
    ref = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJoZWxsbyI6IndvcmxkIn0.uN7ep9KvXB5KIRTpxpK9-vDAtReo5P27Yo0SSqGY9hE"
    assert Tokenize.main(["{\"hello\": \"world\"}"]) == ref
    assert Tokenize.main(["--verify", ref]) == "signature valid!"
  end

  test "no arg with iss option" do
    ref = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3N1ZXIiOiJ0b2tlbml6ZSJ9.6SoFZ1G2wj3Hq_2_l78ddL9-T5v9FgRrFSndbqghOm8"
    assert Tokenize.main(["--iss", "tokenize"]) == ref
    assert Tokenize.main(["--verify", ref]) == "signature valid!"
  end

  test "arg with secret" do
    ref = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJoZWxsbyI6IndvcmxkIn0.YhmYBi-AxvPdMDQwC7jAU8uJuvFk9SUWqP3Ermk2g_Q"
    assert Tokenize.main(["--secret", "hello", "{\"hello\": \"world\"}"]) == ref
    assert Tokenize.main(["--secret", "hello", "--verify", ref]) == "signature valid!"
  end

  test "arg with algorithm" do
    ref = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJoZWxsbyI6IndvcmxkIn0.3Y5MBjccebhBQHZSHBAOXwkha6cL1VoDIz-QfTMnb8diygGr0283NgcKPg0auNYqDtykPyEqDErhRLaWIWr5Bw"
    assert Tokenize.main(["--algorithm", "HS512", "{\"hello\": \"world\"}"]) == ref
    assert Tokenize.main(["--algorithm", "HS512", "--verify", ref]) == "signature valid!"
  end

  test "invalid option" do
    ArgumentError |> assert_raise(fn -> Tokenize.main(["--blah"]) end)
  end

  test "invalid arg" do
    Jason.DecodeError |> assert_raise(fn -> Tokenize.main(["{blah"]) end)
  end

  test "invalid algorithm" do
    Joken.Error |> assert_raise(fn -> Tokenize.main(["--algorithm", "blah", "{\"hello\": \"world\"}"]) end)
  end

  test "no arg or options" do
    assert capture_io(fn -> Tokenize.main([]) end) == "#{@usage}\n"
  end
end
