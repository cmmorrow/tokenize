# Tokenize

A command line tool for developing and working with JSON web tokens.

## Requirements

tokenize is written in Elixir and will require Elixir > 1.11.

## Installation

* Start by cloning the repo at https://github.com/cmmorrow/tokenize.
* Run `mix escript.build` from the command line to create the tokenize binary.
* Verify tokenize is installed properly by running `./tokenize` with no arguments.

## Usage

Generate a JWT with an arbitrary private claims payload and default secret of *tokenize*:

```sh
./tokenize '{"some": "data"}'
```

Specify a secret:

```sh
./tokenize --secret mysecret '{"some": "data"}'
```

**Important**: Specifying an HMAC secret from the command line is not considered secure and tokenize should not be used in a production environment. Use tokenize for developing and manually working with JWTs only. Likewise, verifying a signature using a private key (for RSA and EC algorithms) from the command line should be handled with care.

Specify a different algorithm (the default is HMAC 256):

```sh
./tokenize --algorithm HS512 '{"some": "data"}'
```

Provide public claims:

```sh
./tokenize --iss tokenize --aud developers --iat 1625636467
```

Provide public and private claims:

```sh
./tokenize --iss tokenize --aud developers --iat 1625636467 '{"some": "data"}'
```

Verify a token's signature:

```sh
./tokenize --secret mysecret --verify eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJoZWxsbyI6IndvcmxkIn0.YhmYBi-AxvPdMDQwC7jAU8uJuvFk9SUWqP3Ermk2g_Q
```

Create a token from a JSON file:

```sh
cat data.JSON | jq -c | xargs -0 ./tokenize --secret mysecret
```
