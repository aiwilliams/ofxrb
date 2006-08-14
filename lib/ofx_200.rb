module OFXRB
  class Parser200
    def self.parse(ofx_doc)
      o = Object.new
      class << o
        def version
          "200"
        end
      end
      o
    end
  end
end