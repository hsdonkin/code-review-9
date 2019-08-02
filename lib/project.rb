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

end
