class OFXRB::Parser102
rule
	root: headers objects

	headers: headers key_value_pair
	       | key_value_pair

	key_value_pair: STRING COLON STRING {@event_handler.header_event(val[0], val[2])}
	
	objects: object objects
	       | properties
	       | object

  object: start_tag objects end_tag
        | start_tag end_tag
  
  properties: property properties
            | property objects
            | property
  	          
	property: start_tag STRING {@event_handler.property_event(name_from_ofx(val[0]), val[1])}
	
	end_tags: end_tag end_tags
	          | end_tag

	start_tag: START_TAG {start_tag_event(val[0])}

  end_tag: END_TAG {end_tag_event(val[0])}
end

---- header ----
require 'strscan'

---- inner ----
def name_from_ofx(tag)
  $1 if tag =~ /<\/?(\w+)>/
end

def end_tag_event(tag)
  tag_event(tag, 'end')
end

def start_tag_event(tag)
  tag_event(tag, 'start')
end

def tag_event(tag, type)
  method = "#{name_from_ofx(tag).downcase}_#{type}_event".to_sym
  @event_handler.send(method) if @event_handler.respond_to?(method)
end

def self.parse(ofx_doc, root_object = OfxHandler.new)
  new.parse(ofx_doc, root_object)
end

def parse(ofx_doc, event_handler)
  @event_handler = event_handler

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
  @event_handler.ofx_object
end

private
def next_token
  @tokens.shift
end