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

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  # check out what they did for this one
  def values_for_insert
    instance = self
    unformatted_values = self.class.column_names.map do |attribute|
      insertion = instance.send("#{attribute}").to_s unless instance.send("#{attribute}") == nil
      insertion = "\'#{insertion}\'" unless insertion == nil
    end.compact.join(", ")
  end

  # def save
  #   bound_parameters = self.col_names_for_insert.split(", ").map {|x| x = "?"}.join(", ")
  #   binding.pry
  #   sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{bound_parameters})"
  #   binding.pry
  #   DB[:conn].execute(sql, self.values_for_insert)
  #   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  #   self
  # end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ? LIMIT 1"
    # binding.pry
    DB[:conn].execute(sql, name)    
  end

  def self.find_by(info)
    attributes = []
    values = []
    info.each do |a,v|
      attributes << a.to_s
      values << v.to_s
    end
    sql = "SELECT * FROM #{self.table_name} WHERE #{attributes.join(", ")} = '#{values.join(", ")}' LIMIT 1"
    DB[:conn].execute(sql)
  end
end