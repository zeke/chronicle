require 'spec_helper'

describe Chronicle do

  before(:each) do
    @things = [
      double("thing", :created_at => 39.days.ago),
      double("thing", :created_at => 8.days.ago),
      double("thing", :created_at => 9.days.ago),
      double("thing", :created_at => 3.days.ago),
      double("thing", :created_at => 10.minutes.ago),
      double("thing", :created_at => Time.now)
    ]
    
    @chronicle = Chronicle.new(@things)
  end

  it "doesn't have any empty eras" do
    @chronicle.values.all? {|v| v.present? }.should == true
  end
  
  it "sorts era keys from newest to oldest" do
    @chronicle.keys.first.should == 'just now'
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
    now = @chronicle['just now']
    now.should_not be_blank
    now.should be_an(Array)
    now.first.should == @things.last
  end
  
  context "custom eras" do
    
    it "add 'just now' to the list of eras if it's missing, to keep from losing very new objects" do
      @chronicle = Chronicle.new(@things, :eras => ['3 minutes ago', '35 days ago'])
      @chronicle.keys.first.should == 'just now'
    end

    it "allows custom eras to be set in any order" do
      @chronicle = Chronicle.new(@things, :eras => ['just now', '35 days ago', '3 minutes ago'])
      @chronicle.keys.should == ['just now', '3 minutes ago', '35 days ago']
    end
    
    it "raises an exception for eras that cannot be parse" do
      expect { Chronicle.new(@things, :eras => ['63 eons hence']) }.to raise_error("Could not parse era: 63 eons hence")
    end
    
  end
  
  context "custom date attribute" do
    
    before(:each) do
      @things = [
        double("thing", :updated_at => 369.days.ago, :created_at => nil),
        double("thing", :updated_at => 9.days.ago, :created_at => nil),
        double("thing", :updated_at => 8.days.ago, :created_at => nil),
        double("thing", :updated_at => 3.days.ago, :created_at => nil),
        double("thing", :updated_at => 10.minutes.ago, :created_at => nil),
        double("thing", :updated_at => Time.now, :created_at => nil)
      ]
    end

    it "allows an alternative to created_at" do
      @chronicle = Chronicle.new(@things, :date_attr => :updated_at)
      @chronicle.values.flatten.size.should == @things.size
      @chronicle.keys.last.should == '1 year ago'
      @chronicle.keys.first.should == 'just now'
    end
  
  end

end
