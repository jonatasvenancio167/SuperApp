# config/initializers/cache.rb
#
# Usa Redis como cache store em todos os ambientes (exceto testes).
# O Redis já está disponível no Docker Compose para o Sidekiq,
# então reaproveitamos a mesma instância com namespace separado
# para evitar colisão com as filas do Sidekiq.
#
unless Rails.env.test?
  Rails.application.config.cache_store = :redis_cache_store, {
    url:            ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    namespace:      "agenda_edu:cache",
    expires_in:     1.hour,
    connect_timeout: 5,
    read_timeout:    1,
    write_timeout:   1,
    error_handler:  ->(method:, returning:, exception:) {
      Rails.logger.error("[Cache] #{method} failed: #{exception.message}")
    }
  }
end
 