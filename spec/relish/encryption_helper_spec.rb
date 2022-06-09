require 'spec_helper'

describe Relish::EncryptionHelper do
  let(:secret_one)                             { 'a' * 32    }
  let(:secret_two)                             { 'b' * 32    }
  let(:secret_three)                           { 'c' * 32    }
  let(:secret_four)                            { 'd' * 32    }
  let(:data)                                   { 'test-data' }
  let(:static_secret_one)                      {'static_secret1'}
  let(:static_secret_two)                      {'static_secret2'}
  let(:static_secret_three)                    {'static_secret3'}
  let(:static_secret_four)                     {'static_secret4'}
  let(:encrypt_helper_one_static_secret)       { Relish::EncryptionHelper.new(static_secret_one, [secret_one]) }
  let(:encrypt_helper_array_of_static_secrets) { Relish::EncryptionHelper.new([static_secret_one, static_secret_two], [secret_one, secret_three])}

  describe '#decrypt' do
    it 'raises RelishDecryptionFailed on incorrect decryption secret' do
      token = encrypt_helper_one_static_secret.encrypt(data)
      decrypt_helper = Relish::EncryptionHelper.new(static_secret_one, [secret_two])

      assert_raises(RelishDecryptionFailed) do
        decrypt_helper.decrypt(token)
      end
    end

    it 'raises RelishDecryptionFailed on incorrect decryption for array of secrets' do
      token = encrypt_helper_array_of_static_secrets.encrypt(data)
      decrypt_helper_array = Relish::EncryptionHelper.new([static_secret_three, static_secret_four], [secret_one, secret_three])

      assert_raises(RelishDecryptionFailed) do
        decrypt_helper_array.decrypt(token)
      end
    end

    it 'decrypts data encrypted with a previous secret' do
      token = encrypt_helper_one_static_secret.encrypt(data)
      decrypt_helper = Relish::EncryptionHelper.new(static_secret_one, [secret_two, secret_one])

      assert_equal data, decrypt_helper.decrypt(token)
    end

    it 'decrypts data encrypted with an array of static secrets' do
      token = encrypt_helper_array_of_static_secrets.encrypt(data)
      assert_equal data, encrypt_helper_one_static_secret.decrypt(token)
    end

    it 'decrypts data encrypted with a string as static secret' do
      token = encrypt_helper_one_static_secret.encrypt(data)
      assert_equal data, encrypt_helper_array_of_static_secrets.decrypt(token)
    end

    it 'decrypts data encrypted with a previous static secret in the array of static secrets' do
      token = encrypt_helper_array_of_static_secrets.encrypt(data)
      decrypt_helper_array = Relish::EncryptionHelper.new([static_secret_three, static_secret_one], [secret_one, secret_three])
      assert_equal data, decrypt_helper_array.decrypt(token)
    end
  end

  describe '#encrypt' do
    it 'encrypts' do
      token = encrypt_helper_one_static_secret.encrypt(data)
      assert_equal data, encrypt_helper_one_static_secret.decrypt(token)
    end

    it 'encrypts with array of static secrets' do
      token = encrypt_helper_array_of_static_secrets.encrypt(data)
      assert_equal data, encrypt_helper_array_of_static_secrets.decrypt(token)
    end
  end
end
