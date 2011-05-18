require File.expand_path('../../spec_helper', __FILE__)
require 'chef/api_client'
require 'chef/node'

SecurityGroup = Struct.new(:name, :description, :ip_permissions, :owner_id)
KeyPair = Struct.new(:name, :fingerprint, :private_key)
Server = Struct.new(:id,
                    :availability_zone,
                    :dns_name,
                    :groups,
                    :flavor_id,
                    :image_id,
                    :created_at,
                    :private_dns_name,
                    :private_ip_address,
                    :public_ip_address )

describe Instance do
  before do
    @security_group = SecurityGroup.new("example-sg", 'Example SG for rspec', nil, nil)
    @key_pair = KeyPair.new("skynet-governator-qs-12345-kp", "b9:c1:74:30:96:29:91:1c:7f:1a:54:14:2a:c2:e7:1c:00:1c:c9:fd",
                            "--begin blah blah blah end---")
    @server = Server.new("i-42",
                         "us-east-1c",
                         "ec2-123-45-67-89.compute-1.amazonaws.com",
                         ["skynet-governator-qs-12345-sg"],
                         "m1.small",
                         "ami-12345",
                         "2011-05-10 20:15:47 UTC",
                         "domU-98.76.54.32.compute-1.internal",
                         "98.76.54.32",
                         "123.45.67.89")

    @api_client = Chef::ApiClient.new.tap {|c| c.name("i-42")}

    @node = Chef::Node.new.tap {|n| n.name("i-42") }

  end

  shared_examples_for "a fully created instance object" do

    it "stores the security group created for the instance" do
      @instance.security_group_name.should == 'example-sg'
    end

    it "stores the name of the keypair created for the instance" do
      @instance.key_pair_name.should == 'skynet-governator-qs-12345-kp'
    end

    it "stores the Chef ApiClient name" do
      @instance.api_client_name.should == 'i-42'
    end

    it "stores the Chef Node name" do
      @instance.node_name.should == 'i-42'
    end

    it "stores the EC2 instance data" do
      @instance.instance_id.should == 'i-42'
      @instance.public_hostname.should == 'ec2-123-45-67-89.compute-1.amazonaws.com'
      @instance.public_ipaddress.should == '123.45.67.89'
      @instance.created_at.should == '2011-05-10 20:15:47 UTC'
    end

    it "stores the bootstrap log" do
      @instance.chef_log.should == "built yer infrastructure yo."
    end

    it "converts to a hash including all attributes" do
      @instance.to_hash.should == {
        :security_group_name => 'example-sg',
        :key_pair_name => 'skynet-governator-qs-12345-kp',
        :api_client_name => 'i-42',
        :node_name => 'i-42',
        :instance_id => 'i-42',
        :public_hostname => 'ec2-123-45-67-89.compute-1.amazonaws.com',
        :public_ipaddress => '123.45.67.89',
        :created_at => '2011-05-10 20:15:47 UTC'
      }
    end
  end

  describe "when created with a block" do
    before do
      @instance = Instance.new do |i|
        i.from_security_group @security_group
        i.from_key_pair @key_pair
        i.from_cloud_server @server
        i.from_api_client @api_client
        i.from_node @node
        i.from_log  'built yer infrastructure yo.'
      end
    end

    it_behaves_like "a fully created instance object"
  end

  describe "when created with an attribute hash" do
    before do
      @instance = Instance.new({
        'security_group_name' => 'example-sg',
        'key_pair_name' => 'skynet-governator-qs-12345-kp',
        'api_client_name' => 'i-42',
        'node_name' => 'i-42',
        'instance_id' => 'i-42',
        'public_hostname' => 'ec2-123-45-67-89.compute-1.amazonaws.com',
        'public_ipaddress' => '123.45.67.89',
        'created_at' => '2011-05-10 20:15:47 UTC',
        'chef_log'  => 'built yer infrastructure yo.'
      })
    end

    it_behaves_like "a fully created instance object"
  end
end
