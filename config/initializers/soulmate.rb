module Soulmate
  Soulmate.redis = 'redis://127.0.0.1:6379/0'
  Soulmate.min_complete = 1
# or you can asign an existing instance of Redis, Redis::Namespace, etc.
# Soulmate.redis = $redis
end
