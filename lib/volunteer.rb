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

  def self.find(vol_id)
    # gate checking if the project_id is a string or integer
    vol_id = vol_id.to_i
    result = DB.exec("SELECT * FROM volunteers WHERE id ='#{vol_id}';").first
    Volunteer.new({:name => result["name"], :id => result["id"].to_i, :project_id => result["project_id"]})
  end

  def save
    # DB returns the ID of whatever was inserted, which is set as the new ID value for this project object
    new_id = DB.exec("INSERT INTO volunteers (name, project_id) VALUES ('#{self.name}', '#{self.project_id}') RETURNING id;").first["id"].to_i
    # update the ID of the project object
    self.id = new_id
  end

  def update(attr_hash)
    # ok so...
    # this is an overkill solution, but kind of cool because it allows for partial upating of attributes, AKA an incomplete attr hash, like if a project had an attribute such as @city
    #go through the input hash and for each key
    attr_hash.each_key do |key|
      # if the methods on self include the key, so include? :title => true
      if self.methods.include? key.to_sym
        # then, execute that method on the object!
        # using the value from the hash at that key
        # attr_hash[:title] => "Project Title"
        # self.title= "Project Title"
        # IDEA: use a rescue here if the method errors out
        self.public_send(key.to_s + "=", attr_hash[key])
        #then update the database
        # don't want to try and change the ID of the object because the ID should be a permanent value, and ID is technically an accessor right now
        if key != :id
          DB.exec("UPDATE volunteers SET #{key.to_s} = '#{attr_hash[key]}' WHERE id=#{self.id.to_i} ;")
        end
      end
    end

  end

end
