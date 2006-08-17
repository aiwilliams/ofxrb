$: << File.dirname(__FILE__) + '/../../lib'

require 'test/unit'
require 'ofxrb'

module OfxTestHelp
  def ofx_time(time)
    Time.local(*ParseDate.parsedate(time))
  end

  def read_fixture(name)
    File.read(File.dirname(__FILE__) + "/../fixtures/#{name}.ofx")
  end
  
  def method_missing(name,*args)
    if name.to_s =~ /^fixture_(.*)/
      read_fixture($1)
    else
      super
    end
  end
end