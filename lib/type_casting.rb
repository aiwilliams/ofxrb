require 'parsedate'

module OFXRB

  # This code is borrowed from Ruby on Rails' active_record/connection_adapters/abstract/schema_definitions.rb.
  # It has been modified and reduced for use in this library.
  module TypeCasting

    # Determines whether to use Time.local (using :local) or Time.utc (using :utc) when pulling dates and times from the database.
    # This is set to :local by default.
    DEFAULT_TIMEZONE = :local

    # Casts value (which is a String) to an appropriate instance.
    def type_cast(value, type)
      return nil if value.nil?
      case type
        when :string    then value
        when :text      then value
        when :money     then string_to_money(value)
        when :integer   then value.to_i rescue value ? 1 : 0
        when :float     then value.to_f
        when :datetime  then string_to_time(value)
        when :timestamp then string_to_time(value)
        when :time      then string_to_dummy_time(value)
        when :date      then string_to_date(value)
        when :boolean   then value_to_boolean(value)
        else value
      end
    end

    def string_to_money(string)
      return string unless string.is_a?(String)
      if string =~ /\./
        string.gsub(/[\.,]/, '')
      else
        string + "00"
      end.to_i rescue nil
    end

    def string_to_date(string)
      return string unless string.is_a?(String)
      date_array = ParseDate.parsedate(string)
      # treat 0000-00-00 as nil
      Date.new(date_array[0], date_array[1], date_array[2]) rescue nil
    end

    def string_to_time(string)
      return string unless string.is_a?(String)
      time_array = ParseDate.parsedate(string)[0..5]
      # treat 0000-00-00 00:00:00 as nil
      Time.send(DEFAULT_TIMEZONE, *time_array) rescue nil
    end

    def string_to_dummy_time(string)
      return string unless string.is_a?(String)
      time_array = ParseDate.parsedate(string)
      # pad the resulting array with dummy date information
      time_array[0] = 2000; time_array[1] = 1; time_array[2] = 1;
      Time.send(DEFAULT_TIMEZONE, *time_array) rescue nil
    end

    # convert something to a boolean
    def value_to_boolean(value)
      return value if value==true || value==false
      case value.to_s.downcase
      when "true", "t", "1" then true
      else false
      end
    end
    
  end
end