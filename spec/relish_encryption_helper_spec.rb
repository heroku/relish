require 'spec_helper'

describe Relish::EncryptionHelper do
  let(:good_secret) { 'a' * 32    }
  let(:bad_secret)  { 'b' * 32    }
  let(:key)         { 'my-key'    }
  let(:data)        { 'test-data' }
  let(:encrypt_helper) { Relish::EncryptionHelper.new('static_secret', [good_secret]) }

  describe '#decrypt' do
    it 'raises RelishDecryptionFailed on incorrect decryption secret' do
      encrypt_helper = Relish::EncryptionHelper.new('static_secret', [good_secret])
      decrypt_helper = Relish::EncryptionHelper.new('static_secret', [bad_secret])
      token = encrypt_helper.encrypt(key, data)

      assert_raises(RelishDecryptionFailed) do
        decrypt_helper.decrypt(key, token)
      end
    end

    it 'ignores keys that raise JSON errors' do
      allow(Fernet).to receive(:verifier).and_call_original
      token = encrypt_helper.encrypt(key, data)
      decrypt_helper = Relish::EncryptionHelper.new('static_secret', [bad_secret, good_secret])

      expect(Fernet).to receive(:verifier).and_raise(MultiJson::ParseError)
      assert_equal data, decrypt_helper.decrypt(key, token)
    end

    it 'assumes the key is env' do
      token = encrypt_helper.encrypt(data)
      assert_equal data, encrypt_helper.decrypt(token)
    end
  end

  context "upgrading" do
    it "reads data encrypted with legacy fernet" do
      legacy_token = encrypt_helper.legacy_encrypt('foo', 'bar')
      assert_equal 'bar', encrypt_helper.decrypt('foo', legacy_token)
    end

    it "reads data encrypted with non-legacy fernet" do
      token = encrypt_helper.current_encrypt('foo', 'bar')
      assert_equal 'bar', encrypt_helper.decrypt('foo', token)
    end

    it "writes data encrypted with non-legacy fernet" do
      token = encrypt_helper.encrypt('foo', 'bar')
      assert_equal false, encrypt_helper.legacy?(token)
    end

    it "includes a key name as cipher meta data"
  end
end
