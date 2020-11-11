require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{self.table_name}')"
    table_data = DB[:conn].execute(sql)

    column_names = table_data.map do |column|
        column["name"]
    end

    column_names.compact
  end

  def initialize(options={})
    options.each do |property, value|
        self.send("#{property}=", value) 
    end
  end


end