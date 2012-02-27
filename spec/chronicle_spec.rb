require 'spec_helper'

describe Chronicle do

  before(:each) do
    @things = [
      double("thing", :created_at => 39.days.ago),
      double("thing", :created_at => 9.days.ago),
      double("thing", :created_at => 8.days.ago),
      double("thing", :created_at => 3.days.ago),
      double("thing", :created_at => 10.minutes.ago),
      double("thing", :created_at => Time.now)
    ]
    
    @chronicle = Chronicle.new(@things)
  end

  it "doesn't have any empty eras" do
    @chronicle.values.all? {|v| v.present? }.should == true
  end
  
  it "uses the default eras" do
    @chronicle.keys.first.should == 'one month ago'
    @chronicle.keys.last.should == 'just now'
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
      @chronicle = Chronicle.new(@things, :eras => ['35 days ago', '3 minutes ago'])
      @chronicle.keys.last.should == 'just now'
    end

    it "allows custom eras to be set in any order" do
      @chronicle = Chronicle.new(@things, :eras => ['just now', '35 days ago', '3 minutes ago'])
      @chronicle.keys.should == ['35 days ago', '3 minutes ago', 'just now']
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
      @chronicle.keys.first.should == 'one year ago'
      @chronicle.keys.last.should == 'just now'
    end
  
  end

end
