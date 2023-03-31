require "spec_helper"

describe Relish do
  before do
    @relish = Relish.new("access-key", "secret-key", "table", "us-east-1")
    @dynamo_url = "https://dynamodb.us-east-1.amazonaws.com/"
    stub_request(:any, @dynamo_url)
  end

  describe "#copy" do
    it "makes a POST to the Dynamo API" do
      @relish.copy("1234", "1", { name: "foobar" })
      assert_requested(:post, @dynamo_url) do |req|
        params = MultiJson.decode(req.body)
        item   = params["Item"]
        params["TableName"] == "table" &&
          item["id"]      == { "S" => "1234" } &&
          item["version"] == { "N" => "1" } &&
          item["name"]    == { "S" => "foobar" } &&
          item["draft"]   == nil
      end
    end

    it "creates a draft release" do
      @relish.copy("1234", "1", { name: "foobar", draft: true })
      assert_requested(:post, @dynamo_url) do |req|
        params = MultiJson.decode(req.body)
        params["Item"]["draft"] == { "BOOL" => 'true' }
      end
    end

    describe "on errors" do
      before do
        stub_request(:any, @dynamo_url).to_return(status: 503)
      end

      it "retries the API calls" do
        assert_raise Excon::Errors::ServiceUnavailable do
          @relish.copy("1234", "1", { name: "foobar" })
        end
        assert_requested(:post, @dynamo_url, times: 3)
      end

      it "calls a custom proc so consumers can log/measure Dynamo errors with retries" do
        @error = nil
        @retries = []
        @relish.set_error_handler do |e, r|
          @error = e
          @retries << r
        end
        assert_raise Excon::Errors::ServiceUnavailable do
          @relish.copy("1234", "1", { name: "foobar" })
        end
        assert_equal Excon::Errors::ServiceUnavailable, @error.class
        assert_equal [true, true, false], @retries
      end
    end
  end

  describe "#current" do
    it "returns the current release" do
      @relish.current("1234")

      assert_requested(:post, @dynamo_url) do |req|
        params = MultiJson.decode(req.body)
        params['KeyConditionExpression'] == 'id = :id AND version > :version' &&
          params['FilterExpression'] == 'draft <> :isDraft' &&
          params['ExpressionAttributeValues'] == {
            ':id' => {'S' => '1234'},
            ':version' => {'N' => '0'},
            ':isDraft' => {'BOOL' => true}
          }
      end
    end
  end

  describe "#create" do
    it "makes a POST to the Dynamo API" do
      @relish.create("1234", { name: "foobar" })
      assert_requested(:post, @dynamo_url) do |req|
        params = MultiJson.decode(req.body)
        params['KeyConditionExpression'] == 'id = :id AND version > :version' &&
          params['ExpressionAttributeValues'] == {
            ':id' => {'S' => '1234'},
            ':version' => {'N' => '0'}
          }
      end
    end
  end
end
