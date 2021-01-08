import Config

config :mini_repo,
  port: 4000,
  url: System.get_env("MINI_REPO_URL", "http://localhost:4000")

repo_name = String.to_atom(System.get_env("MINI_REPO_REPO_NAME", "clsa_repo"))

private_key =
  System.get_env("MINI_REPO_PRIVATE_KEY") ||
    File.read!(Path.join([:code.priv_dir(:mini_repo), "test_repo_private.pem"]))

public_key =
  System.get_env("MINI_REPO_PUBLIC_KEY") ||
    File.read!(Path.join([:code.priv_dir(:mini_repo), "test_repo_public.pem"]))

auth_token =
  System.get_env("MINI_REPO_AUTH_TOKEN", "lD22NLEzSWOPZshqP3bVDIgBcdSYWQxT") ||
    raise """
    Environment variable MINI_REPO_AUTH_TOKEN must be set.

    You can generate secret e.g. with this:

        iex> length = 32
        iex> :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
        "Xyf..."
    """

store = {MiniRepo.Store.Local, root: {:mini_repo, "data"}}

config :mini_repo,
  # System.fetch_env!("MINI_REPO_AUTH_TOKEN"),
  auth_token: "lD22NLEzSWOPZshqP3bVDIgBcdSYWQxT",
  repositories: [
    clsa_repo: [
      private_key: private_key,
      public_key: public_key,
      store: store
    ],
    hexpm_mirror: [
      store: store,
      upstream_name: "hexpm",
      upstream_url: "https://repo.hex.pm",

      # only mirror following packages
      only:
        File.read!("packages.txt")
        |> String.split("\n", trim: true)
        |> Enum.map(fn x -> String.trim(x) |> String.replace(~r/[^\w+]/, "") end)
        |> Enum.uniq(),
      # 5min
      sync_interval: 5 * 60 * 1000,
      sync_opts: [max_concurrency: 1, timeout: :infinity],

      # https://hex.pm/docs/public_keys
      upstream_public_key: """
      -----BEGIN PUBLIC KEY-----
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApqREcFDt5vV21JVe2QNB
      Edvzk6w36aNFhVGWN5toNJRjRJ6m4hIuG4KaXtDWVLjnvct6MYMfqhC79HAGwyF+
      IqR6Q6a5bbFSsImgBJwz1oadoVKD6ZNetAuCIK84cjMrEFRkELtEIPNHblCzUkkM
      3rS9+DPlnfG8hBvGi6tvQIuZmXGCxF/73hU0/MyGhbmEjIKRtG6b0sJYKelRLTPW
      XgK7s5pESgiwf2YC/2MGDXjAJfpfCd0RpLdvd4eRiXtVlE9qO9bND94E7PgQ/xqZ
      J1i2xWFndWa6nfFnRxZmCStCOZWYYPlaxr+FZceFbpMwzTNs4g3d4tLNUcbKAIH4
      0wIDAQAB
      -----END PUBLIC KEY-----
      """
    ]
  ]

# ExAWS
config :ex_aws,
  json_codec: Jason,
  access_key_id:
    System.get_env(
      "AWS_ACCESS_KEY_ID",
      "AWS_ACCESS_KEY_ID - Please set the value of this env var"
    ),
  secret_access_key:
    System.get_env(
      "AWS_SECRET_ACCESS_KEY",
      "AWS_SECRET_ACCESS_KEY - please set the value of this env var"
    ),
  s3: [
    scheme: "https://",
    region: "ap-southeast-1",
    host: "s3-ap-southeast-1.amazonaws.com"
  ]

config :ex_aws, :retries,
  max_attempts: 2,
  base_backoff_in_ms: 10,
  max_backoff_in_ms: 5000

config :ex_aws, :hackney_opts,
  proxy: System.get_env("PROXY", nil),
  follow_redirect: true,
  ssl_options: [{:versions, [:"tlsv1.2"]}],
  insecure: true
