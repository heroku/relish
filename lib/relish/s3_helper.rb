require "fog"

class Relish
  class S3Helper

    def initialize(aws_access_key, aws_secret_key, bucket_name)
      @aws_access_key = aws_access_key
      @aws_secret_key = aws_secret_key
      @bucket_name = bucket_name
    end

    def db
      @db ||= Fog::AWS::S3.new(:aws_access_key_id => @aws_access_key, :aws_secret_access_key => @aws_secret_key)
    end

    def signed_url(name, expiry)
      db.directories.new(:key => @bucket_name).files.new(:key => name).url(expiry)
    end
  end
end
