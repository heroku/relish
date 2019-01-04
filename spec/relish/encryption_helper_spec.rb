require 'spec_helper'

describe Relish::EncryptionHelper do
  let(:secret_one)     { 'a' * 32    }
  let(:secret_two)     { 'b' * 32    }
  let(:data)           { 'test-data' }
  let(:encrypt_helper) { Relish::EncryptionHelper.new('static_secret', [secret_one]) }

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
  end

  describe '#encrypt' do
    it 'encrypts' do
      token = encrypt_helper.encrypt(data)
      assert_equal data, encrypt_helper.decrypt(token)
    end
  end
end
