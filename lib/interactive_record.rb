require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    
    DB[:conn].results_as_hash = true 
    
    sql = "PRAGMA table_info(#{table_name})"
    columns_info = DB[:conn].execute(sql)
    column_names = []
    # binding.pry
    columns_info.each do |col_info|
      column_names << col_info["name"]
    end
    column_names
  end
  
  def initialize(attributes={})
    attributes.each do |attribute, value|
      send("#{attribute}=", value)
    end
  end
  
  def table_name_for_insert
    self.class.to_s.downcase.pluralize
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if do |name|
      name == "id"
    end.join(", ")
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each do |name| 
      values << "'#{send(name)}'" unless send(name).nil?
    end
    values.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql) 
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end 

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end
  
  def self.find_by(attribute_hash)
    # binding.pry
    sql = "SELECT * FROM #{table_name} WHERE #{attribute_hash.keys[0].to_s} = '#{attribute_hash.values[0].to_s}'"
    DB[:conn].execute(sql)
  end
  
end