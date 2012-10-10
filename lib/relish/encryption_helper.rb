require "fernet"
require "openssl"

class RelishDecryptionFailed < RuntimeError; end

class Relish
  class EncryptionHelper

    attr_reader :static_secret, :secrets

    def initialize(static_secret, secrets)
      @static_secret = static_secret
      @secrets = secrets
    end

    def hmac_secrets
      @hmac_secrets ||= @secrets.map do |secret|
        OpenSSL::HMAC.hexdigest('sha256', @static_secret, secret)
      end
    end

    def encrypt_env(env)
      encrypt_key_with_secret("env", env, hmac_secrets.first)
    end

    def decrypt_env(encrypted_token)
      hmac_secrets.each_with_index do |secret, i|
        success, env = try_decrypt(secret, encrypted_token, "env")
        if success
          return env
        end
      end
      raise RelishDecryptionFailed
    end

    def try_decrypt(secret, encrypted_token, hash_key)
      decrypt_key(secret, encrypted_token, hash_key)
    rescue OpenSSL::Cipher::CipherError => e
      return false, {}
    end

    protected

    def decrypt_key(secret, encrypted_token, hash_key)
      verifier = Fernet.verifier(secret, encrypted_token)
      verifier.enforce_ttl = false
      unless verifier.valid?
        return false, {}
      end
      [true, verifier.data[hash_key]]
    end

    def encrypt_key_with_secret(hash_key, value, secret)
      Fernet.generate(secret) do |gen|
        gen.data = {hash_key => value}
      end
    end
  end
end
