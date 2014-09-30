require_relative "test_helper"

describe Relish do
    it "initializes legacy style" do
      r = Relish.new('accessKey', 'secretKey', 'tablename')
      r.instance_variable_get("@db").db.must_be_instance_of Fog::AWS::DynamoDB::Real
    end

    it "initializes new style" do
      r = Relish.new(
        :aws_access_key_id => 'aws_access_key',
        :aws_secret_access_key => 'aws_secret_key',
        :table_name => 'tablename'
      )
      r.instance_variable_get("@db").db.must_be_instance_of Fog::AWS::DynamoDB::Real
    end

    it "initializes new style localhost" do
      r = Relish.new(
          :aws_access_key_id => 'aws_access_key',
          :aws_secret_access_key => 'aws_secret_key',
          :host => 'localhost',
          :port => 8080,
          :scheme => 'http'
      )
      r.instance_variable_get("@db").db.must_be_instance_of Fog::AWS::DynamoDB::Real
    end
end
