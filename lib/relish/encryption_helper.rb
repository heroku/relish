require "relish/release"
require "fernet/legacy"
require "fernet"
require "openssl"

class RelishDecryptionFailed < RuntimeError; end

class Relish
  class EncryptionHelper

    LEGACY_MATCHER = /.+?\|.+?\|.+?/.freeze

    def initialize(static_secret, secrets)
      @static_secret = static_secret
      @secrets = secrets
    end

    def encrypt(_key = 'env', value)
      current_encrypt(value)
    end

    def decrypt(key = 'env', token)
      plain = nil
      hmac_secrets.each do |secret|
        plain = decrypt_with_secret(secret, token, key)
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

    def current_encrypt(value)
      Fernet.generate(hmac_secrets.first[0, 32], value)
    end

    def legacy_encrypt(key, value)
      Fernet::Legacy.generate(hmac_secrets.first) do |gen|
        gen.data = { key => value }
      end
    end

    def legacy?(token)
      !!(token =~ LEGACY_MATCHER)
    end

    def hmac_secrets
      @hmac_secrets ||= @secrets.map do |secret|
        OpenSSL::HMAC.hexdigest('sha256', @static_secret, secret)
      end
    end

    def legacy_decrypt(secret, token, key)
      verifier = Fernet::Legacy.verifier(secret, token)
      verifier.enforce_ttl = false
      verifier.verify_token(token)
      return nil unless verifier.valid?
      verifier.data[key]
    rescue OpenSSL::Cipher::CipherError
      # Certain combinations of keys and encrypted data cause decryption with an
      # incorrect key to succeed (no CipherError) but produce garbage data which
      # cannot be decoded into JSON, and thus fail with a ParseError instead.
    rescue MultiJson::ParseError
    end

    def current_decrypt(secret, token)
      verifier = Fernet.verifier(secret[0, 32], token)
      verifier.enforce_ttl = false
      return nil unless verifier.valid?
      verifier.message
    end

    def decrypt_with_secret(secret, token, key)
      if legacy?(token)
        legacy_decrypt(secret, token, key)
      else
        current_decrypt(secret, token)
      end
    end
  end
end
