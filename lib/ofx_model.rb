module OFXRB
  module Model
    
    class FinancialInstitution < OfxObject
      has_attrs :organization => 'ORG',
                :identifier   => 'FID'
    end


    class Status < OfxObject
      has_attrs :code     => 'CODE',
                :severity => 'SEVERITY'
    end


    class Transaction < OfxObject
      has_attrs :amount         => {:path => 'TRNAMT',
                                    :type => :money},
                :date           => {:path => 'DTPOSTED',
                                    :type => :datetime},
                :name           => 'NAME',
                :memo           => 'MEMO',
                :check_number   => 'CHECKNUM',
                :fi_identifier  => {:path => 'FITID',
                                    :doc => 'Unique, useful for determining whether this is already represented in client'}
    end

    class BankStatement < OfxObject
      has_attrs :identifier     => {:path => 'TRNUID',
                                    :doc => 'Client-assigned globally-unique ID for this transaction, 0 if a simple statement download'},
                :currency       => ['STMTRS', 'CURDEF'],
                :routing_number => ['STMTRS', 'BANKACCTFROM', 'BANKID'],
                :number         => ['STMTRS', 'BANKACCTFROM', 'ACCTID'],
                :type           => ['STMTRS', 'BANKACCTFROM', 'ACCTTYPE'],
                :start_date     => {:path => ['STMTRS', 'BANKTRANLIST', 'DTSTART'],
                                    :type => :datetime},
                :end_date       => {:path => ['STMTRS', 'BANKTRANLIST', 'DTEND'],
                                    :type => :datetime}
              
      has_one   :status

      has_many  :transactions, ['STMTRS', 'BANKTRANLIST', 'STMTTRN']
    end


    class CreditCardStatement < OfxObject
      has_attrs :identifier => {:path => 'TRNUID',
                                :doc => 'Client-assigned globally-unique ID for this transaction, 0 if a simple statement download'},
                :currency   => ['CCSTMTRS', 'CURDEF'],
                :number     => ['CCSTMTRS', 'CCACCTFROM', 'ACCTID'],
                :start_date => {:path => ['CCSTMTRS', 'BANKTRANLIST', 'DTSTART'],
                                :type => :datetime},
                :end_date   => {:path => ['CCSTMTRS', 'BANKTRANLIST', 'DTEND'],
                                :type => :datetime}
              
      has_one   :status

      has_many  :transactions, ['CCSTMTRS', 'BANKTRANLIST', 'STMTTRN']
    end

    class OfxInstance < OfxObject
      has_header  :version

      has_one     :status, ['OFX', 'SIGNONMSGSRSV1', 'SONRS', 'STATUS']
      has_one     :financial_institution, ['OFX', 'SIGNONMSGSRSV1', 'SONRS', 'FI']

      has_many    :bank_statements, ['OFX', 'BANKMSGSRSV1', 'STMTTRNRS']
      has_many    :credit_card_statements, ['OFX', 'CREDITCARDMSGSRSV1', 'CCSTMTTRNRS']
    end
  
  end
end