# encoding: utf-8
require 'sequel'

LOGGER ||= nil
$DBURL ||= 'postgres://user@localhost/myapp_dev'

Sequel.extension(:pagination)

DB = Sequel.connect($DBURL, :logger => LOGGER)
DB << "SET CLIENT_ENCODING TO 'UTF8'"

require 'date'

class Sequel::Model
  def self.smart_date_attr(*args)
    args.each do |a|
      define_method("#{a}=".to_sym) do |v|
        if v.class == String and !v.nil? and v != ""
          begin
            super(Date.strptime(v, "%Y-%m-%d"))
          rescue
            super(Date.strptime(v, "%m/%d/%Y"))
          end
        else
          super(v)
        end
      end
    end
  end
  
  def self.smart_money_attr(*args)
    args.each do |a|
      define_method("#{a}=".to_sym) do |v|
        if v.class == String
          super(v.gsub(/[$,]/, ''))
        else
          super(v)
        end
      end
    end
  end
end

require_relative 'user'
