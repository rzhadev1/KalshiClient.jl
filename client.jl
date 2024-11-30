using HTTP
using Dates
using Base64

const BASE_URL = "https://api.elections.kalshi.com"
const EXCHANGE_PATH = "/trade-api/v2/exchange"
const MARKET_PATH = "/trade-api/v2/market"
const AUTH_PATH = "/trade-api/v2/auth"
const PORTFOLIO_PATH = "/trade-api/v2/portfolio"

function get_signature(private_key_path::String, message::String)
    cmd = pipeline(`echo -n "$message"`, 
                `openssl dgst -sha256 -binary`, 
                `openssl pkeyutl -sign -inkey $private_key_path -pkeyopt digest:sha256 -pkeyopt rsa_padding_mode:pss -pkeyopt rsa_pss_saltlen:-1`)
    signature = base64encode(read(cmd, String))
    return signature
end

function get_headers(private_key_path::String, public_key::String, method::String, path::String)
    timestamp = string(floor(Int, time()) * 1000)
    message = timestamp * method * path
    signature = get_signature(private_key_path, message)
    headers = Dict(
        "KALSHI-ACCESS-KEY" => public_key,
        "KALSHI-ACCESS-SIGNATURE" => signature,
        "KALSHI-ACCESS-TIMESTAMP" => timestamp
    )
    return headers
end

struct Client 
    private_key_path::String
    public_key::String
    last_message_ts::Int 
end 

abstract type KalshiMessage end

struct GetPortfolioBalance <: KalshiMessage
    path = PORTFOLIO_PATH * "/balance"
    method = "GET"
end

struct GetPortfolioRequest <: Kalshi

# send(*Request*, Client) -> RequestResponse 
public_key = "26d079f2-3bb3-49f9-bbd3-c9ead1fca2cf"

timestamp = string(floor(Int, time()) * 1000)
method = "GET"
base_url = "https://api.elections.kalshi.com"
path = "/trade-api/v2/portfolio/balance"
msg = timestamp * method * path
println(msg)
key_path = "kalshi_key.pem"
cmd = pipeline(`echo -n "$msg"`, 
               `openssl dgst -sha256 -binary`, 
               `openssl pkeyutl -sign -inkey $key_path -pkeyopt digest:sha256 -pkeyopt rsa_padding_mode:pss -pkeyopt rsa_pss_saltlen:-1`)
signature = base64encode(read(cmd, String))
headers = Dict(
    "KALSHI-ACCESS-KEY" => "26d079f2-3bb3-49f9-bbd3-c9ead1fca2cf",
    "KALSHI-ACCESS-SIGNATURE" => signature,
    "KALSHI-ACCESS-TIMESTAMP" => timestamp
)

r = HTTP.get(base_url * path, headers)
print(String(r.body))


