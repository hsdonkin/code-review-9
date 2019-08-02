require('sinatra')
require('sinatra/reloader')
require('pry')
require('rspec')
require('pg')
also_reload('./lib/**/*.rb')

DB = PG.connect({:dbname => 'volunteer_tracker'})

# this is a single line solution for requiring many files
Dir["./lib/*.rb"].each {|file| require file }

get('/')do
  erb :default
end

post ('/new_project')do
  project_title = params[:title]
  project = Project.new({:title => project_title})
  project.save
  redirect to ('/')
end

get ('/projects/:project_id')do
  @project = Project.find(params[:project_id])
  erb :details_project
end

get ('/projects/:project_id/edit')do
    @project = Project.find(params[:project_id])
    erb :edit_project
end

post ('/projects/:project_id/edit')do
    project_title = params[:title]
    project_id = params[:project_id].to_i
    project = Project.find(project_id)
    project.update({:title => project_title})
    redirect to ('/')
end

post('/projects/:project_id/delete')do
  project_id = params[:project_id].to_i
  project = Project.find(project_id)
  project.delete
  redirect to ('/')
end

get ('/volunteer/:volunteer_id')do
    @volunteer = Volunteer.find(params[:volunteer_id])
    erb :details_volunteer
end

post('/volunteer/:volunteer_id/edit')do
  @volunteer = Volunteer.find(params[:volunteer_id])
  @volunteer.update({:name => params[:name]})
  @project_id = @volunteer.project_id
  redirect to ("/projects/#{@project_id}")
end

post ('/projects/:project_id/add_vol')do
  vol_name = params[:volunteer_name]
  project_id = params[:project_id]
  volunteer = Volunteer.new({:name => vol_name, :project_id => project_id})
  volunteer.save
  redirect to ("/projects/#{project_id}")
end
