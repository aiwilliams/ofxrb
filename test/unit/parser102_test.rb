require File.dirname(__FILE__) + "/test_help"

class Parser102Test < Test::Unit::TestCase
  include OfxTestHelp

  def test_parse
    ofx = OFXRB::Parser102.parse(fixture_credit_card_statement_102)
    assert_equal '102', ofx.version
    assert_equal '42.74', ofx.transactions.first.amount
  end
end