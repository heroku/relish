require 'spec_helper'

describe Relish::EncryptionHelper do
  let(:secret_one)     { 'a' * 32    }
  let(:secret_two)     { 'b' * 32    }
  let(:data)           { 'test-data' }
  let(:encrypt_helper) { Relish::EncryptionHelper.new('static_secret', [secret_one]) }

  let(:encrypt_helper_array) { Relish::EncryptionHelper.new(['static_secret1','static_secret2'], ['a' * 32, 'c' * 32])}
  let(:secret_encrypt) {['b' * 32, 'd' * 32]}

  describe '#decrypt' do
    it 'raises RelishDecryptionFailed on incorrect decryption secret' do
      token = encrypt_helper.encrypt(data)
      decrypt_helper = Relish::EncryptionHelper.new('static_secret', [secret_two])

      assert_raises(RelishDecryptionFailed) do
        decrypt_helper.decrypt(token)
      end
    end

    it 'decrypts data encrypted with a previous secret' do
      token = encrypt_helper.encrypt(data)
      decrypt_helper = Relish::EncryptionHelper.new('static_secret', [secret_two, secret_one])

      assert_equal data, decrypt_helper.decrypt(token)
    end

    it 'raises RelishDecryptionFailed on incorrect decryption for array of secrets' do
      # token = encrypt_helper.encrypt(data)
      token = encrypt_helper_array.encrypt(data)
      decrypt_helper_array = Relish::EncryptionHelper.new(['static_secret1','static_secret2'], secret_encrypt)

      assert_raises(RelishDecryptionFailed) do
        decrypt_helper_array.decrypt(token)
      end
    end

  end

  describe '#encrypt' do
    it 'encrypts' do
      token = encrypt_helper.encrypt(data)
      assert_equal data, encrypt_helper.decrypt(token)
    end
  end
end
