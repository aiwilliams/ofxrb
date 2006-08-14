class OFXRB::Parser102
rule
	root: headers elements
	headers: headers key_value_pair
	       | key_value_pair
	key_value_pair: STRING COLON STRING {@root_object.properties.store(val[0], val[2])}
	
	elements: elements element {result << val[1]}
	        | element {result = [val[0]]}
	
	element: closed_element | one_line_element
	one_line_element: START_TAG STRING {result = property(val)}
	closed_element: START_TAG elements END_TAG {result = element(val)}
end

---- header ----
require 'strscan'

---- inner ----
class Property
  attr_accessor :key, :value
  def initialize(name, value)
    @key = name
    @value = value
  end
end

class Element
  attr_reader :name, :properties
  def initialize(start_name, elements, end_name)
    raise "Element #{start_name} is being closed as #{end_name}" if start_name != end_name
    @name, @properties = start_name, {}
    elements.each { |e| @properties.store(e.key, e.value) if e.is_a?(Property) }
  end
end

def name_from_ofx(tag)
  $1 if tag =~ /<\/?(\w+)>/
end

def property(val)
  Property.new(name_from_ofx(val[0]), val[1])
end

# When an OFXRB::Element has been created, the current handler will receive a
# a method send where the name is the downcased name of the OFXRB::Element.
def element(val)
  e = Element.new(name_from_ofx(val[0]), val[1], name_from_ofx(val[2]));
  @root_object.send(e.name.downcase.to_sym, e.properties)
  e
end

def self.parse(ofx_doc, root_object = CreditCardStatement.new)
  new.parse(ofx_doc, root_object)
end

# Implements the Racc#parse method using a StringScanner to lex
def parse(ofx_doc, root_object)
  @root_object = root_object

  @match_tokens = {
    :START_TAG => /<\w+>/,
    :END_TAG => /<\/\w+>/,
    :STRING => /[^\r\n<>:]+/,
    :COLON => /:/,
  }

  @tokens, s = [], StringScanner.new(ofx_doc)
  until s.eos?
    s.scan(/\s*/)
    @match_tokens.each do |key, value|
      if s.scan(value)
        @tokens << [key, s.matched]
        # Redefine string after headers so that : is allowed in values
        @match_tokens[:STRING] = /[^\r\n<>]+/ if key == :START_TAG        
        break # to consume more whitespace, move forward
      end
    end
  end

  #@yydebug = true
  do_parse
  @root_object
end

private
def next_token
  @tokens.shift
end