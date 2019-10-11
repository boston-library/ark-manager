
# module Executors
#   extend ActiveSupport::Concern
#   class_methods do
#     def with_transaction_lock(&block)
#       rails_executor_wrap do
#         Ark.connection_pool.with_connection do |conn|
#
#         end
#       end
#     end
#
#     def rails_executor_wrap
#       Rails.application.executor.wrap{ yield }
#     end
#
#
#     def rails_permit_lock_wrap
#       if !(Rails.application.config.eager_load && Rails.application.config.cache_classes)
#          ActiveSupport::Dependencies.interlock.permit_concurrent_loads { yield }
#       else
#         yield
#       end
#     end
#   end
# end
