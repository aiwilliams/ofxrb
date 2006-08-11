require File.dirname(__FILE__) + "/test_help"

class OfxTest < Test::Unit::TestCase
  include OfxTestHelp

  def test_it
    ofx = OFXRB.import(fixture_credit_card_statement_102)
    assert_equal('102', ofx.version)
  end
end