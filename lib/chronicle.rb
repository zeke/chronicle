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
      "just now",
      "1 minute from now",
      "2 minutes from now",
      "3 minutes from now",
      "5 minutes from now",
      "10 minutes from now",
      "20 minutes from now",
      "30 minutes from now",
      "1 hour from now",
      "2 hours from now",
      "3 hours from now",
      "4 hours from now",
      "5 hours from now",
      "6 hours from now",
      "7 hours from now",
      "8 hours from now",
      "1 day from now",
      "2 days from now",
      "3 days from now",
      "4 days from now",
      "5 days from now",
      "6 days from now",
      "1 week from now",
      "2 weeks from now",
      "3 weeks from now",
      "1 month from now",
      "2 months from now",
      "3 months from now",
      "4 months from now",
      "5 months from now",
      "6 months from now",
      "7 months from now",
      "1 year from now",
      "2 years from now",
      "3 years from now",
      "4 years from now",
      "5 years from now",
      "6 years from now",
      "7 years from now",
    ]
  end
  
  class ChronicleHash < Hash

    def initialize(collection, options)
      
      eras = options[:eras]
      
      # Sort order, defaut is new to old
      order = options[:order] || :desc
      
      # Remove objects with nil timestamps
      collection = collection.reject {|obj| obj.send(options[:date_attr]).nil? }
            
      # Sort collection by date
      collection = collection.sort_by {|obj| obj.send(options[:date_attr])}
      collection = collection.reverse if order == :desc
      
      # Ensure all eras can be parsed
      eras.each do |era|
        raise "Could not parse era: #{era}" if Chronic.parse(era).nil?
      end

      if order == :desc && Time.now > collection.first.send(options[:date_attr])
        eras << "just now" 
      end
      
      # Parse date strings
      # { "7 years ago"=>2006-01-02 23:29:05 -0800, ... }
      era_date_pairs = eras.inject({}) {|h,e| h[e] = Chronic.parse(e); h }
          
      # Sort eras oldest to newest
      eras = eras.sort_by {|era| Chronic.parse(era) }
      # .. or newest to oldest
      eras = eras.reverse unless order == :desc
    
      if order == :desc

        # Initialize all hash keys chronologically (newest to oldest)
        eras.reverse.each {|era| self[era] = [] }
        
        # Find the oldest era in which each object was created
        collection.each do |obj|
          # puts ("\n #{obj.send(options[:date_attr])} < #{era_date_pairs[era]}")
          era = eras.find {|era| obj.send(options[:date_attr]) < era_date_pairs[era]  }
          self[era] << obj
        end
      else
        
        # Initialize all hash keys chronologically (oldest to newest)
        eras.reverse.each {|era| self[era] = [] }
        
        # Find the newest era in which each object was created
        collection.each do |obj|
          era = eras.find {|era| obj.send(options[:date_attr]) > era_date_pairs[era]  }
          self[era] << obj
        end
      end
    
      # Remove keys for empty eras
      self.keys.each {|k| self.delete(k) if self[k].empty? }
    
      self
    end
    
  end
  
end