require File.dirname(__FILE__) + "/test_help"

class Parser102Test < Test::Unit::TestCase
  include OfxTestHelp

  def test_parse_events
    my_handler = Object.new
    class << my_handler

      # Keeping in line with API
      def ofx_object
      end

      def bankmsgsrsv1_start_event
        events << 'bankmsgsrsv1_start'
      end

      def bankmsgsrsv1_end_event
        events << 'bankmsgsrsv1_end'
      end
      
      def ofx_start_event
        events << 'ofx_start'
      end

      def ofx_end_event
        events << 'ofx_end'
      end
      
      def signonmsgsrsv1_start_event
        events << 'signonmsgsrsv1_start'
      end
      
      def signonmsgsrsv1_end_event
        events << 'signonmsgsrsv1_end'
      end

      def property_event(name, value)
        events << 'property'
      end

      def events
        @events ||= []
      end

      def header_event(name, value)
        events << 'header'
      end

    end

    OFXRB::Parser102.parse(fixture_simplest_102, my_handler)
    assert_events([['header',1], 'ofx_start', 'property', 'signonmsgsrsv1_start', 'signonmsgsrsv1_end', 'property', 'bankmsgsrsv1_start', 'bankmsgsrsv1_end', 'ofx_end'], my_handler.events)
    
    OFXRB::Parser102.parse(fixture_credit_card_statement_102, my_handler)    
    OFXRB::Parser102.parse(fixture_checking_and_savings_102, my_handler)
  end
    
  def assert_events(expected, events)
    actual = events.dup
    expected.each do |expectation|
      if expectation.is_a?(Array)
        expected_name, expected_occurrences = expectation
        occurrences = 0
        until actual.first != expected_name
          actual_name = actual.shift
          occurrences += 1
        end
        assert_equal(expected_occurrences, occurrences)
      else
        assert_equal expectation, actual.shift
      end
    end
  end
    
end