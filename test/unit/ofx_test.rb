require File.dirname(__FILE__) + "/test_help"

class OfxTest < Test::Unit::TestCase
  include OfxTestHelp

  def test_it
    ofx_model = OFXRB.import(fixture_credit_card_statement_102)
    assert_equal('102', ofx_model.version)
    assert_equal('CAPITALONE', ofx_model.financial_institution.organization)
    assert_equal('RICHMOND', ofx_model.financial_institution.identifier)
    
    cc = ofx_model.credit_card_statements[0]
    assert_equal(ParseDate.parse('20060609170000'), cc.start_date)
    assert_equal('1234123412341234', cc.number)
    assert_equal(4274, cc.transactions[0].amount)
  
    ofx_model = OFXRB.import(fixture_checking_and_savings_102)
    assert_equal('102', ofx_model.version)
  
    ofx_model = OFXRB.import(fixture_checking_and_savings_200)
    assert_equal('200', ofx_model.version)
  end

end