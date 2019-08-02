require('pry')

class Volunteer
  attr_accessor :name, :id, :project_id
  def initialize(attr)
    (attr.key? :name) ? @name = attr.fetch(:name) : @name = "Missing Name"
    (attr.key? :id) ? @id = attr.fetch(:id) : @id = nil
    (attr.key? :project_id) ? @project_id = attr.fetch(:project_id) : @project_id = nil
  end

  def ==(volunteer)
    (self.name == volunteer.name && self.id == volunteer.id) ? true : false
  end

  def self.all
    result = DB.exec("SELECT * FROM volunteers;")
    volunteers = []
    result.each do |volunteer|
      vol = Volunteer.new({:name => volunteer["name"], :id => volunteer["id"].to_i, :project_id => volunteer["project_id"].to_i})
      volunteers.push(vol)
    end
    return volunteers
  end

  def save
    # DB returns the ID of whatever was inserted, which is set as the new ID value for this project object
    new_id = DB.exec("INSERT INTO volunteers (name, project_id) VALUES ('#{self.name}', '#{self.project_id}') RETURNING id;").first["id"].to_i
    # update the ID of the project object
    self.id = new_id
  end
end
