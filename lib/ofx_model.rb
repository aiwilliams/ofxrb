module OFXRB
  
  class FinancialInstitution < OfxObject
    has_attrs :organization => 'ORG',
              :identifier   => 'FID'
  end


  class Status < OfxObject
    has_attrs :code     => 'CODE',
              :severity => 'SEVERITY'
  end


  class Transaction < OfxObject
    has_attrs :amount => 'TRNAMT'
    
    def amount
      attribute(:amount).gsub(/\./, '').to_i
    end
  end


  class CreditCardStatement < OfxObject
    has_attrs :identifier => 'TRNUID',
              :currency   => ['CCSTMTRS', 'CURDEF'],
              :number     => ['CCSTMTRS', 'CCACCTFROM', 'ACCTID'],
              :start_date => ['CCSTMTRS', 'BANKTRANLIST', 'DTSTART'],
              :end_date   => ['CCSTMTRS', 'BANKTRANLIST', 'DTEND']
              
    has_one :status

    has_many :transactions, ['CCSTMTRS', 'BANKTRANLIST', 'STMTTRN']
  end

  class OfxInstance < OfxObject
    has_header :version

    has_one     :status, ['OFX', 'SIGNONMSGSRSV1', 'SONRS', 'STATUS']
    has_one     :financial_institution, ['OFX', 'SIGNONMSGSRSV1', 'SONRS', 'FI']

    has_many  :credit_card_statements, ['OFX', 'CREDITCARDMSGSRSV1', 'CCSTMTTRNRS']
  end
  
end