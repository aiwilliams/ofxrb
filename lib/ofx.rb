module OFXRB
  # Creates an OfxObject for the version detected in the ofx_doc
  def self.import(ofx_doc)
    raise "Not a valid OFX document. Must contain OFXHEADER value." unless ofx_doc =~ /.*?OFXHEADER/
    
    version = $1 if ofx_doc =~ /VERSION:(102)/i
    version ||= $1 if ofx_doc =~ /VERSION="(200)"/
    raise "Unsupported OFX document version" unless version
    
    "OFXRB::Parser#{version}".constantize.parse(ofx_doc)
  end

  # The basic OFX document event handler, used to create an OFX model from
  # an OFX document
  class OfxHandler
    # All handlers answer the OFX object model that they are building
    attr_reader :ofx_object

    def initialize
      @ofx_object = BankStatement.new
    end

    def header_event(name, value)
      @ofx_object.properties[name] = value
    end

    def property_event(name, value)
    end

  end

  class OfxObject
    
    # Maps humane attr_readers to the element names of the OFX specification.
    def self.ofx_attrs(mapping)
      mapping.each do |humane, ofx_name|
        module_eval "def #{humane.to_s}; self['#{ofx_name}']; end"
      end
    end

    # Provides access to properties via their actual names in the OFX spec.
    def [](key)
      @properties[key]
    end

  end

  class BankStatement < OfxObject
    attr_reader :properties, :credit_cards

    ofx_attrs :version => 'VERSION'

    def initialize
      @properties = {}
      @credit_cards = []
    end

    def ccstmtrs(properties)
      @credit_cards << cc = CreditCard.new(properties)
      cc.transactions = @transactions
      
    end

    def method_missing(name, *args)
      # p "Need to handle #{name} in #{self.class.name}"
    end

  end


  class CreditCard < OfxObject
    attr_reader :properties, :transactions

    def initialize
      @properties = {}
      @transactions = []
    end
  
    def stmttrn(properties)
      @transactions << Transaction.new(properties)
    end
  
    def method_missing(name, *args)
      p "Need to handle #{name} in #{self.class.name}"
    end

  end


  class Transaction < OfxObject
    ofx_attrs :amount => 'TRNAMT'
      
    def initialize(properties)
      @properties = properties
    end

  end

end