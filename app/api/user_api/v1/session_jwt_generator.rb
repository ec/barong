# frozen_string_literal: true

require 'barong/security/access_token'

module UserApi
  module V1
    class SessionJWTGenerator
      ALGORITHM = 'RS256'

      ## TODO signature?
      def initialize(signature:, key_id:)
        @key_id = key_id
        @signature = jwt_token
        @api_key = APIKey.active.find_by!(uid: key_id)
      end

      def verify_hmac_payload
        kid = ApiKey.find_by_key_id(params.key_id).kid
        data = params.nonce + kid + params.key_id
        ## GET A SECRET KEY FROM THE VAULT BY KID
        ## Think about naming
        true_signature = OpenSSL::HMAC.hexdigest("SHA256", "secret_key_from_vault", data).upcase
        true_signature == params.signature
      end

      def verify_rsa_payload
        payload, = decode_payload
        payload.present?
      end

      def generate_session_jwt
        account = @api_key.account
        payload = {
          iat: Time.current.to_i,
          exp: @api_key.expires_in.seconds.from_now.to_i,
          sub: 'session',
          iss: 'barong',
          aud: @api_key.scopes,
          jti: SecureRandom.hex(12).upcase,
          uid:   account.uid,
          email: account.email,
          role:  account.role,
          level: account.level,
          state: account.state,
          api_key_id: @api_key.key_id
        }

        JWT.encode(payload, Barong::Security.private_key, ALGORITHM)
      end

    private

      def decode_payload
        public_key = OpenSSL::PKey.read(Base64.urlsafe_decode64(@api_key.public_key))
        return {} if public_key.private?

        JWT.decode(@jwt_token,
                   public_key,
                   true,
                   APIKey::JWT_OPTIONS)
      end
    end
  end
end
