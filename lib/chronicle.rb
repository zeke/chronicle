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
      "right now",
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
            
      # Remove objects with nil timestamps
      collection.reject! {|obj| obj.send(options[:date_attr]).nil? }
      
      # Determine whether collection contains future or past timestamps
      if collection.all? { |obj| obj.send(options[:date_attr]) < Time.now }
        order = :past
      elsif collection.all? { |obj| obj.send(options[:date_attr]) > Time.now }
        order = :future
      else
        raise "Chronicle collections must be entirely in the past or the future."
      end
            
      # Sort collection by date
      # For past collections, newest objects come first 
      # For future collections, oldest objects come first
      collection = collection.sort_by {|obj| obj.send(options[:date_attr]) }
      collection.reverse! if order == :past

      # Force inclusion of 'now' era in case it's missing.
      eras.push('right now').uniq!
      
      # Parse era strings using Chronic
      # Ensure all eras can be parsed
      # { "7 years ago" => 2006-01-02 23:29:05 -0800, ... }
      era_date_pairs = eras.inject({}) {|h,era|
        h[era] = Chronic.parse(era)
        raise "Could not parse era: #{era}" if h[era].nil?
        h
      }

      # Sort eras by date
      # For past collections, newest eras come first
      # For future collections, oldest eras come first
      eras = eras.sort_by {|era| era_date_pairs[era] }
      eras.reverse! if order == :future
    
      # Initialize all hash keys chronologically
      eras.reverse.each {|era| self[era] = [] }
      
      collection.each do |obj|
        era = eras.find do |era|
          if order == :future
            # Find newest possible era for the object
            obj.send(options[:date_attr]) > era_date_pairs[era]
          else
            # Find oldest possible era for the object
            obj.send(options[:date_attr]) < era_date_pairs[era]
          end
        end
        self[era] << obj
      end
    
      # Remove empty eras
      self.keys.each {|k| self.delete(k) if self[k].empty? }
    
      self
    end
    
  end
  
end