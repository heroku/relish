require "relish/release"
require "fernet/legacy"
require "openssl"

class RelishDecryptionFailed < RuntimeError; end

class Relish
  class EncryptionHelper

    def initialize(static_secret, secrets)
      @static_secret = static_secret
      @secrets = secrets
    end

    def encrypt(key, value)
      Fernet::Legacy.generate(hmac_secrets.first) do |gen|
        gen.data = {key => value}
      end
    end

    def decrypt(key, token)
      hmac_secrets.each do |secret|
        if verifier = verifier(secret, token)
          return verifier.data[key] if verifier.valid?
        end
      end
      raise RelishDecryptionFailed
    end

    def upgrade(key, token)
      if verifier = verifier(hmac_secrets.first, token)
        return encrypt(key, verifier.data[key]) if verifier.valid?
      end
      raise RelishDecryptionFailed
    end

    def inspect
      "#<Relish::EncryptionHelper>"
    end

    alias to_s inspect

    protected

    def hmac_secrets
      @hmac_secrets ||= @secrets.map do |secret|
        OpenSSL::HMAC.hexdigest('sha256', @static_secret, secret)
      end
    end

    def verifier(secret, token)
      Fernet::Legacy.verifier(secret, token).tap do |verifier|
        verifier.enforce_ttl = false
        verifier.verify_token(token)
      end
    rescue OpenSSL::Cipher::CipherError
    # Certain combinations of keys and encrypted data cause decryption with an
    # incorrect key to succeed (no CipherError) but produce garbage data which
    # cannot be decoded into JSON, and thus fail with a ParseError instead.
    rescue MultiJson::ParseError
    end
  end
end
