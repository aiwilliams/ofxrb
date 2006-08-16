require File.dirname(__FILE__) + "/test_help"

class Parser102Test < Test::Unit::TestCase
  include OfxTestHelp

  def test_parse_events
    my_handler = Object.new
    class << my_handler

      # Keeping in line with API
      def ofx_object
      end

      def start_tag_event(name)
        events << name + "_start"
      end
      
      def end_tag_event(name)
        events << name + "_end"
      end
      
      def bankmsgsrsv1_start_event
        events << 'bankmsgsrsv1_start'
      end

      def bankmsgsrsv1_end_event
        events << 'bankmsgsrsv1_end'
      end

      def attribute_event(name, value)
        events << name + '_attribute'
      end

      def events
        @events ||= []
      end

      def header_event(name, value)
        events << name + '_header'
      end

    end

    OFXRB::Parser102.parse(fixture_simplest_102, my_handler)
    assert_events([
      'VERSION_header',
      'OFX_start',
      'CODE_attribute',
      'SIGNONMSGSRSV1_start',
      'SIGNONMSGSRSV1_end',
      'ATTRIBUTE_attribute',
      'bankmsgsrsv1_start',
      'bankmsgsrsv1_end',
      'OFX_end',
    ], my_handler.events)
    
    OFXRB::Parser102.parse(fixture_credit_card_statement_102, my_handler)    
    OFXRB::Parser102.parse(fixture_checking_and_savings_102, my_handler)
  end
    
  def assert_events(expected, events)
    actual = events.dup
    expected.each do |expectation|
      assert_equal expectation, actual.shift
    end
  end
    
end