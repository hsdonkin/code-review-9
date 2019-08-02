class Project
  attr_accessor :title, :id

  def initialize(attr)

    # these keep the class from erroring out if a title wasn't found
    (attr.key? :title) ? @title = attr.fetch(:title) : @title = "Untitled Project"
    (attr.key? :id) ? @id = attr.fetch(:id) : @id = nil
  end

  def ==(project)
    # overriding the equals operator to check if title and id are the same, instead of comparing to see if it's the same object
    if self.title == project.title && self.id == project.id
        true
    else
        false
    end
  end

  def self.all
    result = DB.exec("SELECT * FROM projects;")
    projects = []
    result.each do |project|
      project = Project.new({:title => project["title"], :id => project["id"].to_i})
      projects.push(project)
    end
    return projects
  end

  def self.find(project_id)
    # gate checking if the project_id is a string or integer
    project_id = project_id.to_i
    result = DB.exec("SELECT * FROM projects WHERE id ='#{project_id}'").first
    Project.new({:title => result["title"], :id => result["id"].to_i})
  end

  def save
    # DB returns the ID of whatever was inserted, which is set as the new ID value for this project object
    new_id = DB.exec("INSERT INTO projects (title) VALUES ('#{self.title}') RETURNING id;").first["id"].to_i
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
        self.public_send(key.to_s + "=", attr_hash[key])
        #then update the database
        binding.pry
        # don't want to try and change the ID of the object because the ID should be a permanent value, and ID is technically an accessor right now
        if key != :id
          DB.exec("UPDATE projects SET #{key.to_s} = '#{attr_hash[key]}' WHERE id=#{self.id.to_i} ;")
        end
      end
    end

  end

  def volunteers
    result = DB.exec("SELECT * FROM volunteers WHERE project_id='#{self.id}'")
    volunteers = []
    result.each do |volunteer|
      vol = Volunteer.new({:name => volunteer["name"], :id => volunteer["id"].to_i, :project_id => volunteer["project_id"].to_i})
      volunteers.push(vol)
    end
    return volunteers
  end

end
