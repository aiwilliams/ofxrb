require File.dirname(__FILE__) + "/test_help"

class BankingTest < Test::Unit::TestCase
  include OfxTestHelp

  # Bank in South Africa, courtesy of Trey Bean
  # This is the one that exposed the inability to handle attributes that have closing tags
  def test_natwest
    ofx_model = OFXRB.import(fixture_natwest)
    assert_equal('102', ofx_model.version)
  end

end