module OFXRB
  
  class FinancialInstitution < OfxObject
    has_attrs :organization => 'ORG',
              :identifier   => 'FID'
  end


  class Signon < OfxObject
    has_child :financial_institution, 'FI'
  end

  class Status < OfxObject
    
  end

  class CreditCardStatement < OfxObject
    # has_attrs :identifier => 'TRNUID',
    #           :currency   => ['CCSTMTRS', 'CURDEF'],
    #           :number     => ['CCSTMTRS', 'CCACCTFROM', 'ACCTID'],
    #           :start_date => ['CCSTMTRS', 'BANKTRANLIST', 'DTSTART'],
    #           :end_date   => ['CCSTMTRS', 'BANKTRANLIST', 'DTEND']
    #           
    # has_child :status
    # has_child :transactions, ['CCSTMTRS', 'BANKTRANLIST', 'STMTTRN']
  end


  class OfxInstance < OfxObject
    has_header :version

    # has_child :signon, ['OFX', 'SIGNONMSGSRSV1']
    has_child :financial_institution, ['OFX', 'SIGNONMSGSRSV1', 'SONRS', 'FI']
    # has_children :credit_card_statements, ['OFX', 'CREDITCARDMSGSRSV1', 'CCSTMTTRNRS']
  end
  
end