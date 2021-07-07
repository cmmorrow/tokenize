defmodule Tokenize do
  @moduledoc """
  Documentation for `Tokenize`.
  """

  @default_algorithm "HS256"

  @default_secret "tokenize"

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

  defp generate_token(payload, secret, algorithm, registered_claims) do
    token_config =
      Map.merge(registered_claims, payload)
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})

    signer = Joken.Signer.create(algorithm, secret)

    [header, body, signature] =
      case Joken.generate_and_sign(%{}, token_config, signer) do
        {:ok, token, _} -> String.split(token, ".")
        {:error, err} -> ["Error: #{err}", "", ""]
      end

    [:red, header, :white, ".", :yellow, body, :white, ".", :cyan, signature]
    |> IO.ANSI.format(true)
    |> IO.puts()
    "#{header}.#{body}.#{signature}"
  end

  defp verify_token(token, secret, algorithm) do
    signer = Joken.Signer.create(algorithm, secret)
    result = case Joken.verify(token, signer) do
      {:ok, _} -> "signature valid!"
      {:error, reason} -> reason
    end
    IO.puts(result)
    result
  end

  @doc """
  Parses command line arguments and attempts to generate the resulting JWT.
  Prints the tokenize usage to stdout if no arguments are passed.
  """
  def main(args)

  def main(args) when args == [], do: IO.puts(@usage)

  def main(args) do
    options = [
      secret: :string,
      algorithm: :string,
      verify: :string,
      iss: :string,
      jti: :string,
      sub: :string,
      aud: :string,
      iat: :string,
      exp: :string,
      nbf: :string
    ]

    {parsed, payload, unused} = OptionParser.parse(args, strict: options)
    if unused != [] do
      raise ArgumentError, message: "Argument #{elem(hd(unused), 0)} is not recognized as a valid option."
    end

    algorithm = if parsed[:algorithm], do: parsed[:algorithm], else: @default_algorithm
    secret = if parsed[:secret], do: parsed[:secret], else: @default_secret

    if :verify in Keyword.keys(parsed) do
      verify_token(parsed[:verify], secret, algorithm)
    else
      registered = %{
        issuer: parsed[:iss],
        jwt_id: parsed[:jti],
        subject: parsed[:sub],
        audience: parsed[:aud],
        issued_at: parsed[:iat],
        expiration: parsed[:exp],
        not_before: parsed[:nbf]
      }

      if payload == [] do
        generate_token(%{}, secret, algorithm, registered)
      else
        case Jason.decode(payload) do
          {:ok, decoded} -> generate_token(decoded, secret, algorithm, registered)
          {:error, err} -> raise err
        end
      end
    end
  end
end
