class OFXRB::Parser102
rule
  root: headers objects

  headers: headers key_value_pair
         | key_value_pair

  key_value_pair: STRING COLON STRING {@event_handler.header_event(val[0], val[2])}
  
  objects: object objects
         | attribute objects
         | object
         | attribute

  object: start_tag objects end_tag
        | start_tag end_tag

  attribute: start_tag NOTHING end_tag {attribute_event(val[0], nil)}
            | start_tag STRING CARRIAGE {attribute_event(val[0], val[1])}
            | start_tag STRING end_tag {attribute_event(val[0], val[1])}

  start_tag: START_TAG {start_tag_event(val[0])}

  end_tag: END_TAG {end_tag_event(val[0])}
end

---- header ----
require 'strscan'

---- inner ----
def name_from_ofx(tag)
  $1 if tag =~ /<\/?(\w+|\w+\.\w+)>/
end

def attribute_event(tag, value)
  @event_handler.attribute_event(name_from_ofx(tag), value)
  @in_attribute = false
end

def end_tag_event(tag)
  tag_event(tag, 'end') unless end_of_attribute?
end

def start_tag_event(tag)
  tag_event(tag, 'start') unless start_of_attribute?
end

def end_of_attribute?
  end_attr = @in_attribute
  @in_attribute = false
  end_attr
end

def start_of_attribute?
  @in_attribute = [:STRING, :NOTHING].include?(@tokens.first.first)
end

def tag_event(tag, type)
  tag_name = name_from_ofx(tag)
  method = "#{tag_name.downcase}_#{type}_event".to_sym
  if @event_handler.respond_to?(method)
    @event_handler.send(method)
  elsif @event_handler.respond_to?(generic_method = "#{type}_tag_event".to_sym)
    @event_handler.send(generic_method, tag_name)
  end
end

def self.parse(ofx_doc, root_object = OfxHandler.new)
  new.parse(ofx_doc, root_object)
end

def parse(ofx_doc, event_handler)
  @event_handler = event_handler

  start_tag = [:START_TAG, /<(\w+|\w+\.\w+)>/]
  end_tag = [:END_TAG, /<\/(\w+|\w+\.\w+)>/]
  carriage = [:CARRIAGE, /[\r\n]/]

  @in_body = false
  @match_tokens = [start_tag, end_tag, [:STRING, /[^\r\n<>:]+/], [:COLON, /:/]]
  @tokens, s = [], StringScanner.new(ofx_doc)
  until s.eos?
    if @in_body then s.scan(/[\f\t ]*/) else s.scan(/\s*/) end
    @match_tokens.each do |key, value|
      if s.scan(value)
        # Handle case where there is a blank line
        break if :CARRIAGE == key and @tokens.last.first == :CARRIAGE
        matched = s.matched
        if [:START_TAG, :END_TAG].include?(key)
          unless @in_body
            # Redefine string after headers so that : is allowed in values
            # and start tracking carriage returns so that attributes can be determined
            @match_tokens = [start_tag, end_tag, [:STRING, /[^\r\n<>]+/], carriage]
            @in_body = true
          end
          # Consume the carriages that come immediately after start/end tags
          while s.check(/[\f\t ]*[\r\n]/)
            s.scan(/[\f\t ]*[\r\n]/)
          end
          # Handle case where object end tag follows attribute value
          if :END_TAG == key && :STRING == @tokens[-1][0]
            @tokens << [:CARRIAGE, "\r\n"] if @tokens[-2][1][1..-2] != matched[2..-2]
          end
        end
        @tokens << [key, matched]
        # Handle case where an attribute has nothing, not even a single space
        @tokens << [:NOTHING, ""] if :START_TAG == key and s.check(end_tag[1])
        break # to consume more whitespace, move forward
      end
    end
  end

  # @yydebug = true
  do_parse
  @event_handler.ofx_object
end

private
def next_token
  @tokens.shift
end