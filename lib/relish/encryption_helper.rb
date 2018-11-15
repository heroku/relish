require "relish/release"
require "fernet/legacy"
require "fernet"
require "openssl"

class RelishDecryptionFailed < RuntimeError; end

class Relish
  class EncryptionHelper

    def initialize(static_secret, secrets)
      @static_secret = static_secret
      @secrets = secrets
    end

    def encrypt(_key = 'env', value)
      current_encrypt(value)
    end

    def current_encrypt(value)
      Fernet.generate(hmac_secrets.first[0, 32], value)
    end

    def legacy_encrypt(key, value)
      Fernet::Legacy.generate(hmac_secrets.first) do |gen|
        gen.data = { key => value }
      end
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

    def legacy?(token)
      !!(token =~ /.+?\|.+?\|.+?/)
    end

    protected

    def hmac_secrets
      @hmac_secrets ||= @secrets.map do |secret|
        OpenSSL::HMAC.hexdigest('sha256', @static_secret, secret)
      end
    end

    def decrypt_with_secret(secret, token, key)
      legacy = legacy?(token)
      verifier = if legacy
        Fernet::Legacy.verifier(secret, token)
      else
        Fernet.verifier(secret[0, 32], token)
      end

      verifier.enforce_ttl = false
      verifier.verify_token(token) if legacy
      return nil unless verifier.valid?

      legacy ? verifier.data[key] : verifier.message
    rescue OpenSSL::Cipher::CipherError
      # Certain combinations of keys and encrypted data cause decryption with an
      # incorrect key to succeed (no CipherError) but produce garbage data which
      # cannot be decoded into JSON, and thus fail with a ParseError instead.
    rescue MultiJson::ParseError
    end
  end
end
