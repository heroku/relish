require "relish/release"
require "fernet"
require "openssl"

class RelishDecryptionFailed < RuntimeError; end

class Relish
  class EncryptionHelper

    def initialize(static_secrets, secrets)
      @static_secrets = static_secrets.is_a?(String) ? [static_secrets] : static_secrets
      @secrets = secrets
    end

    def encrypt(value)
      Fernet.generate(hmac_secrets.first[0, 32], value)
    end

    def decrypt(token)
      plain = nil
      hmac_secrets.each do |secret|
        plain = decrypt_with_secret(secret, token)
        break if plain
      end
      raise RelishDecryptionFailed unless plain
      plain
    end

    def inspect
      "#<Relish::EncryptionHelper>"
    end

    alias to_s inspect

    protected

    def hmac_secrets
      @hmac_secrets ||= @static_secrets.product(@secrets).map {|static_secret, secret|
        OpenSSL::HMAC.hexdigest('sha256', static_secret, secret)}
    end

    def decrypt_with_secret(secret, token)
      verifier = Fernet.verifier(secret[0, 32], token)
      verifier.enforce_ttl = false
      return nil unless verifier.valid?

      verifier.message
    end
  end
end
