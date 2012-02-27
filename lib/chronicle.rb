require 'rubygems'
require 'chronic'
require 'active_support/all' # OrderedHash

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
      "3 years ago",
      "2 years ago",
      "one year ago",
      "6 months ago",
      "3 months ago",
      "2 months ago",
      "one month ago",
      "3 weeks ago",
      "2 weeks ago",
      "one week ago",
      "6 days ago",
      "4 days ago",
      "3 days ago",
      "2 days ago",
      "yesterday",
      "8 hours ago",
      "4 hours ago",
      "2 hours ago",
      "1 hour ago",
      "30 minutes ago",
      "20 minutes ago",
      "10 minutes ago",
      "5 minutes ago",
      "3 minutes ago",
      "2 minutes ago",
      "one minute ago",
      "just now"
    ]
  end

  class ChronicleHash < ActiveSupport::OrderedHash

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
    
      # Initialize all OrderedHash keys chronologically
      eras.each {|era| self[era] = [] }

      # Find the oldest era in which each object was created
      collection.each do |obj|
        era = eras.find {|era| obj.send(options[:date_attr]) < Chronic.parse(era) }
        self[era] << obj
      end
    
      # Remove keys for empty eras
      self.keys.each {|k| self.delete(k) if self[k].blank? }
    
      self
    end
    
  end
  
end