# # frozen_string_literal: true

# module Vault
#     # Vault::ApiKeySecret helper
#     module ApiKeySecret
#       Error = Class.new(StandardError)
  
#       class <<self
#         ISSUER_NAME = 'Barong'
  
#         def server_available?
#           read_data('sys/health').present?
#         rescue StandardError
#           false
#         end
        
#         ## Naming is awful
#         def api_key_secret_secret(api_key_secret)
#             CGI.parse(URI.parse(api_key_secret.data[:url]).query)['secret'][0]
#         end

#         def safe_create(kid)
#             return if exist?(kid)
#             create(kid)
#         end
  
#         def create(kid)
#             write_data(secret_key(uid),
#                        generate: true,
#                        issuer: ENV.fetch('APP_NAME', 'Barong'),
#                        account_name: email,
#                        qr_size: 300)
#         end
  
#         def exist?(uid)
#           read_data(totp_key(uid)).present?
#         end
  
#         def validate?(uid, code)
#           return false unless exist?(uid)
#           write_data(totp_code_key(uid), code: code).data[:valid]
#         end
  
#         def delete(uid)
#           delete_data(totp_key(uid))
#         end
  
#         def with_human_error
#           raise ArgumentError, 'Block is required' unless block_given?
#           yield
#         rescue Vault::VaultError => e
#           Rails.logger.error { e }
#           if e.message.include?('connection refused')
#             raise Error, '2FA server is under maintenance'
#           end
  
#           if e.message.include?('code already used')
#             raise Error, 'This code was already used. Wait until the next time period'
#           end
  
#           raise e
#         end
  
#       private
  
#         def api_key_secret_key(kid)
#           "api_key_secret/kid/#{kid}"
#         end
  
#         def totp_code_key(uid)
#           "api_key_secret/secret_key/#{uid}"
#         end
  
#         def read_data(key)
#           with_human_error do
#             vault.read(key)
#           end
#         end
  
#         def write_data(key, params)
#           with_human_error do
#             vault.write(key, params)
#           end
#         end
  
#         def delete_data(key)
#           with_human_error do
#             vault.delete(key)
#           end
#         end
  
#         def vault
#           Vault.logical
#         end
#       end
#     end
#   end
  