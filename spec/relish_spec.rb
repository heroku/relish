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
          item["name"]    == { "S" => "foobar" }
      end
    end

    it "retries on errors" do
      stub_request(:any, @dynamo_url).to_return(status: 503)
      @relish.copy("1234", "1", { name: "foobar" })
      assert_requested(:post, @dynamo_url, times: 3)
    end
  end
end
