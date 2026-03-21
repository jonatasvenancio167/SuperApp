require "sidekiq/web"
require "rack/session"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end

Sidekiq::Web.use Rack::Session::Cookie,
  secret:    Rails.application.secret_key_base,
  same_site: true,
  max_age:   86400
