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
      @current.ofx_header(name, value)
    end

    def attribute_event(name, value)
      @current.ofx_attr(name, value)
    end

    def start_tag_event(name)
      new_state = @current.ofx_start_tag(name)
      if new_state != @current
        @stack.push(@current)
        @current = new_state
        new_state.ending_name = name
      end
    end
    
    def end_tag_event(name)
      while @current and @current.ofx_end(name)
        @current = @stack.pop
      end
    end

  end


  class OfxObject

    class << self

      def ofx_reverse_lookup_header
        @ofx_reverse_lookup_header ||= Hash.new
      end

      def ofx_paths
        @ofx_paths ||= Hash.new
      end

      def has_attrs(mapping)
        mapping.each do |name, ofx_path|
          ofx_path = [ofx_path] if ofx_path.is_a? String
          ofx_paths[ofx_path] = name
          ofx_attr_accessor(name, :attributes)
        end
      end
    
      def has_one(child_name, ofx_path = [child_name.to_s.upcase])
        ofx_paths[ofx_path] = child_name
        module_eval <<-"end;"
          def #{child_name}
            @children[:#{child_name}] ||= []
          end
      
          def #{child_name}=(value)
            @children[:#{child_name}] = value
          end
        end;
      end
    
      def has_many(children_name, ofx_path = [children_name.to_s.upcase])
        has_one(children_name, ofx_path)
        module_eval <<-"end;"
          def #{children_name}_add(child)
            send(:#{children_name}) << child
            child
          end
        end;
      end

      def has_header(name, ofx_element = name.to_s.upcase)
        ofx_reverse_lookup_header[ofx_element] = name
        ofx_attr_accessor(name, :headers)
      end
    
      private
        def ofx_attr_accessor(attr_name, attr_type)
          module_eval <<-"end;"
            def #{attr_name}
              @#{attr_type}[:#{attr_name}]
            end
            alias :ofx_attr_#{attr_name} :#{attr_name}

            def #{attr_name}=(value)
              @#{attr_type}[:#{attr_name}] = value
            end
            alias :ofx_attr_#{attr_name}= :#{attr_name}=
          end;
        end
    end
    

    attr_writer :ending_name
    
    def initialize
      @ending_name = nil
      @current_path = []
      @children = {}
      @attributes = {}
      @headers = {}
    end

    def attribute(name)
      @attributes[name.to_sym]
    end

    def ofx_attr(ofx_element, value)
      attribute_path = @current_path.dup << ofx_element
      if attribute_name = self.class.ofx_paths[attribute_path]
        self.send("#{attribute_name}=".to_sym, value)
      end
    end

    def ofx_header(ofx_element, value)
      assign = "#{self.class.ofx_reverse_lookup_header[ofx_element]}=".to_sym
      self.send(assign, value) if respond_to? assign
    end
    
    def ofx_start_tag(ofx_element)
      @current_path.push(ofx_element)
      if child_name = self.class.ofx_paths[@current_path]
        if child_name.to_s.plural?
          assign = "#{child_name}_add"
          object_class = child_name.to_s.singularize.camelize
        else
          assign = "#{child_name}="
          object_class = child_name.to_s.camelize
        end
        self.send(assign.to_sym, "OFXRB::#{object_class}".constantize.new)
      else
        self
      end
    end

    def ofx_end(ofx_element)
      @current_path.pop unless @current_path.empty?
      @ending_name == ofx_element
    end

  end

end