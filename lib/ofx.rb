module OFXRB
  # Creates an OfxObject for the version detected in the ofx_doc
  def self.import(ofx_doc)
    Parser102.parse(ofx_doc)
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


  class CreditCardStatement < OfxObject
    attr_reader :properties, :transactions
    
    ofx_attrs :version => 'VERSION'

    def initialize
      @properties = {}
      @transactions = []
    end
  
    def stmttrn(properties)
      @transactions << Transaction.new(properties)
    end
  
    def method_missing(name, *args)
    end
  end


  class Transaction < OfxObject
    ofx_attrs :amount => 'TRNAMT'
      
    def initialize(properties)
      @properties = properties
    end
  end

end