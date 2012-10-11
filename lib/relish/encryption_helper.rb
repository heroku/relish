require "relish/release"
require "fernet"
require "openssl"

class RelishDecryptionFailed < RuntimeError; end

class Relish
  class EncryptionHelper

    def initialize(static_secret, secrets)
      @static_secret = static_secret
      @secrets = secrets
    end

    def encrypt_env(env)
      encrypt_key_with_secret("env", env, hmac_secrets.first)
    end

    def decrypt_env(encrypted_token)
      try_decrypt_with_index(encrypted_token)[0]
    end

    def upgrade_env_encryption(encrypted_token)
      if encrypted_token.nil? || encrypted_token == ""
        return false, encrypted_token
      end
      env, i = try_decrypt_with_index(encrypted_token)
      i == 0 ? [false, encrypted_token] : [true, encrypt_env(env)]
    end

    protected

    def hmac_secrets
      @hmac_secrets ||= @secrets.map do |secret|
        OpenSSL::HMAC.hexdigest('sha256', @static_secret, secret)
      end
    end

    def try_decrypt_with_index(encrypted_token)
      hmac_secrets.each_with_index do |secret, i|
        success, env = try_decrypt_key(secret, encrypted_token, "env")
        if success
          return env, i
        end
      end
      raise RelishDecryptionFailed
    end

    def try_decrypt_key(secret, encrypted_token, hash_key)
      verifier = Fernet.verifier(secret, encrypted_token)
      verifier.enforce_ttl = false
      unless verifier.valid?
        return false, nil
      end
      [true, verifier.data[hash_key]]
    rescue OpenSSL::Cipher::CipherError => e
      return false, nil
    end

    def encrypt_key_with_secret(hash_key, value, secret)
      Fernet.generate(secret) do |gen|
        gen.data = {hash_key => value}
      end
    end

    def inspect
      "#<Relish::EncryptionHelper @static_secret=[masked] @secrets=[masked]>"
    end
    alias to_s inspect
  end
end
