require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  describe "behavior it inherits from OpenStruct" do

    it "can represent arbitrary data objects" do
      ros = RecursiveOpenStruct.new
      ros.blah = "John Smith"
      ros.blah.should == "John Smith"
    end

    it "can be created from a hash" do
      h = { :asdf => 'John Smith' }
      ros = RecursiveOpenStruct.new(h)
      ros.asdf.should == "John Smith"
    end

    it "can modify an existing key" do
      h = { :blah => 'John Smith' }
      ros = RecursiveOpenStruct.new(h)
      ros.blah = "George Washington"
      ros.blah.should == "George Washington"
    end

    describe "handling of arbitrary attributes" do
      before(:each) do
        @ros = RecursiveOpenStruct.new
        @ros.blah = "John Smith"
      end

      describe "#respond?" do
        it { @ros.should respond_to :blah }
        it { @ros.should respond_to :blah= }
        it { @ros.should_not respond_to :asdf }
        it { @ros.should_not respond_to :asdf= }
      end # describe #respond?

      describe "#methods" do
        it { @ros.methods.should include "blah" }
        it { @ros.methods.should include "blah=" }
        it { @ros.methods.should_not include "asdf" }
        it { @ros.methods.should_not include "asdf=" }
      end # describe #methods
    end # describe handling of arbitrary attributes
  end # describe behavior it inherits from OpenStruct

  describe "recursive behavior" do
    before(:each) do
      h = { :blah => { :another => 'value' } }
      @ros = RecursiveOpenStruct.new(h)
    end

    it "returns accessed hashes as RecursiveOpenStructs instead of hashes" do
      @ros.blah.another.should == 'value'
    end

    it "uses #key_as_a_hash to return key as a Hash" do
      @ros.blah_as_a_hash.should == { :another => 'value' }
    end

  end # recursive behavior
end # describe RecursiveOpenStruct