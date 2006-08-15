module OFXRB
  # Creates an OfxObject for the version detected in the ofx_doc
  def self.import(ofx_doc)
    raise "Not a valid OFX document. Must contain OFXHEADER value." unless ofx_doc =~ /.*?OFXHEADER/
    
    version = $1 if ofx_doc =~ /VERSION:(102)/i
    version ||= $1 if ofx_doc =~ /VERSION="(200)"/
    raise "Unsupported OFX document version" unless version
    
    "OFXRB::Parser#{version}".constantize.parse(ofx_doc)
  end


  # The basic OFX document event handler, used to create an OFX model from
  # an OFX document
  class OfxHandler
    # All handlers answer the OFX object model that they are building
    attr_reader :ofx_object

    def initialize
      @stack = []
      @current = @ofx_object = OfxInstance.new
    end

    def header_event(name, value)
      @current.header(name, value)
    end

    def property_event(name, value)
      @current.property(name, value)
    end

    def start_tag_event(name)
      new_state = @current.start(name)
      if new_state != @current
        @stack.push(@current)
        @current = new_state
      end
    end
    
    def end_tag_event(name)
      while @current and @current.end?(name)
        @current = @stack.pop
      end
    end

  end


  class OfxObject

    class <<self
      attr_reader :ofx_header_humane, :ofx_paths
    end
    
    def initialize
      @current_path = []
      @children = {}
      @attributes = {}
      @headers = {}
    end

    def self.has_attrs(mapping)
      @ofx_paths ||= {}

      mapping.each do |name, ofx_path|
        ofx_path = [ofx_path] if ofx_path.is_a? String
        @ofx_paths[ofx_path] = name
        module_eval <<-"end;"
          def #{name.to_s}
            @attributes[:#{name.to_s}]
          end

          def #{name.to_s}=(value)
            @attributes[:#{name.to_s}] = value
          end
        end;
      end
    end
    
    def self.has_child(child_name, ofx_path = [child_name.to_s.upcase])
      @ofx_paths ||= {}
      
      raise "Child #{child_name} already defined" if respond_to? child_name
      @ofx_paths[ofx_path] = child_name
      module_eval <<-"end;"
        def #{child_name.to_s}
          @children[:#{child_name.to_s}]
        end
      
        def #{child_name.to_s}=(value)
          @children[:#{child_name.to_s}] = value
        end
      end;
    end
    
    def self.has_children(children_name, ofx_path = [children_name.to_s.upcase])
    end

    def self.has_header(name, ofx_element = name.to_s.upcase)
      @ofx_header_humane ||= Hash.new
      
      raise "Header #{name} already defined" if respond_to? name
      @ofx_header_humane[ofx_element] = name
      module_eval <<-"end;"
        def #{name.to_s}
          @headers[:#{name.to_s}]
        end
      
        def #{name.to_s}=(value)
          @headers[:#{name.to_s}] = value
        end
      end;
    end

    def property(ofx_element, value)
      property_path = @current_path.dup << ofx_element
      if property_name = self.class.ofx_paths[property_path]
        self.send("#{property_name}=".to_sym, value)
      end
    end

    def header(ofx_element, value)
      assign = "#{self.class.ofx_header_humane[ofx_element]}=".to_sym
      self.send(assign, value) if respond_to? assign
    end
    
    def start(ofx_element)
      @current_path.push(ofx_element)
      if child_name = self.class.ofx_paths[@current_path]
        self.send("#{child_name}=".to_sym, "OFXRB::#{child_name.to_s.camelize}".constantize.new)
      else
        self
      end
    end

    def end?(ofx_element)
      @current_path.pop unless @current_path.empty?
      @current_path.empty?
    end

  end

end