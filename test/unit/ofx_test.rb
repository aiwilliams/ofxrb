require File.dirname(__FILE__) + "/test_help"

class OfxTest < Test::Unit::TestCase
  include OfxTestHelp

  def test_checking_and_savings_200
    ofx_model = OFXRB.import(fixture_checking_and_savings_200)
    assert_equal('200', ofx_model.version)
    # no real support yet, just setting up appropriate parser
  end

  def test_credit_card_102
    ofx_model = OFXRB.import(fixture_credit_card_statement_102)
    assert_equal('102', ofx_model.version)
    assert_equal('CAPITALONE', ofx_model.financial_institution.organization)
    assert_equal('RICHMOND', ofx_model.financial_institution.identifier)
    
    cc = ofx_model.credit_card_statements[0]
    assert_equal(ofx_time('20060609170000'), cc.start_date)
    assert_equal('1234123412341234', cc.number)
    assert_equal(4274, cc.transactions[0].amount)
    assert_equal(74600, cc.transactions[1].amount)
  end

  def test_checking_and_savings_102
    ofx_model = OFXRB.import(fixture_checking_and_savings_102)
    assert_equal('102', ofx_model.version)
    assert_equal('SYNERGYBANKS', ofx_model.financial_institution.organization)
    assert_equal('WOODGRV', ofx_model.financial_institution.identifier)
    
    #bank_statements
    bank_statements = ofx_model.bank_statements
    assert_equal(bank_statements.length, 2)
    
    checking = bank_statements[0]
    savings = bank_statements[1]
    
    #checking
    assert_equal(ofx_time('20050706120000'), checking.start_date)
    assert_equal(ofx_time('20050803120000'), checking.end_date)
    assert_equal('BankRTN', checking.routing_number)
    assert_equal('AcctNum', checking.number)
    assert_equal('CHECKING', checking.type)
    assert_equal(checking.transactions.length, 3)
    
    #checking transactions
    t = checking.transactions.first
    assert_equal(-109924, t.amount)
    assert_equal('1633', t.check_number)
    assert_equal(ofx_time('20050706120000'), t.date)
    assert_equal('Home Insure Mortgage Company', t.name)
    assert_equal('Loan 67392938', t.memo)
  end

end