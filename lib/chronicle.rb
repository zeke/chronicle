require 'rubygems'
require 'chronic'
require 'chronicle'

module Chronicle
  
  def self.new(collection, options={})  
    defaults = {
      :eras => Chronicle.default_eras,
      :date_attr => :created_at
    }
    ChronicleHash.new(collection, defaults.merge(options))
  end

  def self.default_eras
    [
      "7 years ago",
      "6 years ago",
      "5 years ago",
      "4 years ago",
      "3 years ago",
      "2 years ago",
      "1 year ago",
      "6 months ago",
      "5 months ago",
      "4 months ago",
      "3 months ago",
      "2 months ago",
      "1 month ago",
      "3 weeks ago",
      "2 weeks ago",
      "1 week ago",
      "6 days ago",
      "5 days ago",
      "4 days ago",
      "3 days ago",
      "2 days ago",
      "1 day ago",
      "8 hours ago",
      "7 hours ago",
      "6 hours ago",
      "5 hours ago",
      "4 hours ago",
      "3 hours ago",
      "2 hours ago",
      "1 hour ago",
      "30 minutes ago",
      "20 minutes ago",
      "10 minutes ago",
      "5 minutes ago",
      "3 minutes ago",
      "2 minutes ago",
      "1 minute ago",
      "just now"
    ]
  end

  class ChronicleHash < Hash

    def initialize(collection, options)
      
      eras = options[:eras]

      # Make sure 'just now' is included, so no objects fall through the cracks
      eras << "just now" unless eras.any? {|era| era =~ /now/i }
    
      # Ensure all eras can be parsed
      eras.each do |era|
        raise "Could not parse era: #{era}" if Chronic.parse(era).nil?
      end
      
      # Sort eras oldest to newest
      eras = eras.sort_by {|era| Chronic.parse(era) }
    
      # Initialize all hash keys chronologically (newest to oldest)
      eras.reverse.each {|era| self[era] = [] }

      # Find the oldest era in which each object was created
      collection.sort_by {|obj| obj.send(options[:date_attr])}.reverse.each do |obj|
        era = eras.find {|era| obj.send(options[:date_attr]) < Chronic.parse(era) }
        self[era] << obj
      end
    
      # Remove keys for empty eras
      self.keys.each {|k| self.delete(k) if self[k].empty? }
    
      self
    end
    
  end
  
end