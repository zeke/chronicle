require 'spec_helper'

describe Chronicle do

  before(:each) do
    @minute = 60
    @hour = @minute*60
    @day = @hour*24
  end
  
  context "dates in the past and the future" do
    
    before do
      offsets = [@day, -@day]
      @things = offsets.map do |offset|
        double("thing", :created_at => Time.now+offset)
      end
    end

    it "raises an error" do
      expect { Chronicle.new(@things) }.to raise_error("Chronicle collections must be entirely in the past or the future.")
    end
    
  end
  
  context "dates in the past" do
    
    before do
      offsets = [-39*@day, -8*@day, -9*@day, -3*@day, -10*@minute, 0]
      @things = offsets.map do |offset|
        double("thing", :created_at => Time.now+offset)
      end
      @chronicle = Chronicle.new(@things)
    end

    it "doesn't have any empty eras" do
      @chronicle.values.all? {|v| !v.empty? }.should == true
    end
  
    it "sorts era keys from newest to oldest" do
      @chronicle.keys.first.should == 'right now'
      @chronicle.keys.last.should == '1 month ago'
    end
  
    it "sorts objects in eras from newest to oldest" do
      era = @chronicle['1 week ago']
      era.size.should == 2
      era.last.created_at.should be < era.first.created_at
    end
  
    it "doesn't lose any items during processing" do
      @chronicle.values.flatten.size.should == @things.size
    end
  
    it "accounts for objects that were just created" do
      now = @chronicle['right now']
      now.should_not be_empty
      now.should be_an(Array)
      now.first.should == @things.last
    end
    
  end
  
  context "dates in the future" do
    
    before(:each) do
      @things = [
        double("thing", :created_at => Time.now + 39*@day),
        double("thing", :created_at => Time.now + 9*@day),
        double("thing", :created_at => Time.now + 8*@day),
        double("thing", :created_at => Time.now + 3*@day),
        double("thing", :created_at => Time.now + 9*@minute),
        double("thing", :created_at => Time.now + 2),
      ]
      @chronicle = Chronicle.new(@things, order: :asc)
    end

    it "doesn't have any empty eras" do
      @chronicle.values.all? {|v| !v.empty? }.should == true
    end
      
    it "sorts era keys from oldest to newest" do
      @chronicle.keys.first.should == 'right now'
      @chronicle.keys.last.should == '1 month from now'
    end
      
    it "sorts objects in eras from oldest to newest" do
      era = @chronicle['1 week from now']
      era.size.should == 2
      era.last.created_at.should be > era.first.created_at
    end
      
    it "doesn't lose any items during processing" do
      @chronicle.values.flatten.size.should == @things.size
    end
    
  end

  context "custom eras" do

    before do
      offsets = [-39*@day, -8*@day, -9*@day, -3*@day, -10*@minute, 0]
      @things = offsets.map do |offset|
        double("thing", :created_at => Time.now+offset)
      end
      @chronicle = Chronicle.new(@things)
    end
    
    it "add 'right now' to the list of eras if it's missing, to keep from losing very new objects" do
      @chronicle = Chronicle.new(@things, :eras => ['3 minutes ago', '35 days ago'])
      @chronicle.keys.first.should == 'right now'
    end

    it "allows custom eras to be set in any order" do
      @chronicle = Chronicle.new(@things, :eras => ['right now', '35 days ago', '3 minutes ago'])
      @chronicle.keys.should == ['right now', '3 minutes ago', '35 days ago']
    end
    
    it "raises an exception for eras that cannot be parsed" do
      expect { Chronicle.new(@things, :eras => ['63 eons hence']) }.to raise_error("Could not parse era: 63 eons hence")
    end
    
  end
  
  context "custom date attribute" do
    
    before(:each) do
      @things = [
        double("thing", :updated_at => Time.now - 369*@day, :created_at => nil),
        double("thing", :updated_at => Time.now - 9*@day, :created_at => nil),
        double("thing", :updated_at => Time.now - 8*@day, :created_at => nil),
        double("thing", :updated_at => Time.now - 3*@day, :created_at => nil),
        double("thing", :updated_at => Time.now - 10*@minute, :created_at => nil),
        double("thing", :updated_at => Time.now, :created_at => nil)
      ]
    end

    it "allows an alternative to created_at" do
      @chronicle = Chronicle.new(@things, :date_attr => :updated_at)
      @chronicle.values.flatten.size.should == @things.size
      @chronicle.keys.last.should == '1 year ago'
      @chronicle.keys.first.should == 'right now'
    end
    
    it "gracefully ignores objects with nil timestamps" do
      @things = [
        double("thing", :updated_at => Time.now - 369*@day),
        double("thing", :updated_at => Time.now - 9*@day),
        double("thing", :updated_at => nil)
      ]
      @chronicle = Chronicle.new(@things, :date_attr => :updated_at)
      @chronicle.size.should == 2
    end
  
  end

end
