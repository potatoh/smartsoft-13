#encoding: UTF-8
require "spec_helper"
require "request_helpers"
include Warden::Test::Helpers
include RequestHelpers
include Devise::TestHelpers

describe ProjectsController, type: :controller do

  let(:gamer1){
	  gamer = Gamer.new
    gamer.username = "Nourhan"
    gamer.country = "Egypt"
    gamer.education_level = "high"
    gamer.gender = "female"
    gamer.date_of_birth = "1993-03-23"
    gamer.email = "mohamedtamer5@gmail.com"
    gamer.password = "1234567"
    gamer.save
    gamer
  }

  let(:developer1){
  	developer = Developer.new
  	developer.gamer_id = gamer1.id
  	developer.save
  	developer
  }

  let(:project){
    project = Project.new
    project.name = "banking"
    project.minAge = 19
    project.maxAge = 25
    project.owner_id = developer1.id
    project.save
    project
  }

  let(:word) {
    word = Keyword.new
    word.name = "testkeyword"
    word.save
    word
  }

  let(:syn) { syn = Synonym.new
    syn.name = "كلمة"
    syn.keyword_id = word.id
    syn.save
    syn
  }

  it "a developer can open the link of import of one of his projects" do
    sign_in developer1.gamer
    get :import_csv, :project_id => project.id
    page.should have_content(I18n.t(:import_csv_title))
  end


#Salma's Tests

  it "initializes a new project" do
    a = create_logged_in_developer
    sign_in(a.gamer)
    get :new
    response.code.should eq("200")
  end

  it "assigns the requested project to project" do
    a = create_logged_in_developer
    sign_in(a.gamer)
    project
    get :edit, id: project
    assigns(:project).should eq(project)
  end

  it "located the requested project" do
    a = create_logged_in_developer
    sign_in(a.gamer)
    project
    put :update, id: project.id, project: { name: "hospital", category:"" }
    assigns(:project).should eq(project)
  end

  it "changes project's attributes" do
    a = create_logged_in_developer
    sign_in(a.gamer)
    project
    put :update, id: project,
    project: { name: "Pro", minAge:"23", maxAge:"50",category:"" }
    project.reload
    project.name.should eq("Pro")
    project.minAge.should eq(23)
    project.maxAge.should eq(50)
  end

  it "redirects to the project index" do
    a = create_logged_in_developer
    sign_in(a.gamer)
    project
    put :update, id: project, project: { name: "Pro", minAge:"23", maxAge:"50",category:"" }
    response.should redirect_to projects_path
  end

  it "locates the requested project" do
    a = create_logged_in_developer
    sign_in(a.gamer)
    project
    put :update, id: project, project: { name: "Pro", minAge:"23", maxAge:"50",category:"" }
    assigns(:project).should eq(project)
  end

  it "does not change project's attributes" do
   a = create_logged_in_developer
   sign_in(a.gamer)
   project
   put :update, id: project,
   project: { name: "Pro", minAge:"500", maxAge:"50",category:"" }
   project.reload
   project.name.should_not eq("Pro")
   project.minAge.should_not eq(500)
   project.minAge.should eq(19)
 end

 it "re-renders the edit method" do
  a = create_logged_in_developer
  sign_in(a.gamer)
  project
  put :update, id: project, project: { name: "Pro", minAge:"500", maxAge:"50",category:"" }
  response.should render_template :edit
end

it "renders the #show view" do
  a = create_logged_in_developer
  sign_in(a.gamer)
  project
  get :show, id: project
  response.should render_template project
end

  # khloud's tests

  it "redirects to project path after calling export_to_csv if project empty" do
    p = create_project
    get :export_to_csv, project_id: p.id
    response.should redirect_to project_path(p.id)
  end

  it "redirects to project path after calling export_to_xml if project empty" do
    p = create_project
    get :export_to_xml, project_id: p.id
    response.should redirect_to project_path(p.id)
  end

  it "redirectsto project path after calling export_to_json if project empty" do
    p = create_project
    get :export_to_json, project_id: p.id
    response.should redirect_to project_path(p.id)
  end

  it "responds with ok code after calling export_to_csv with valid project" do
    p = create_project
    ps =
    PreferedSynonym.add_keyword_and_synonym_to_project(syn.id, word.id, p.id)
    get :export_to_csv, project_id: p.id
    response.code.should eq("200")
  end

  it "responds with ok code after calling export_to_xml with valid project" do
    p = create_project
    ps =
    PreferedSynonym.add_keyword_and_synonym_to_project(syn.id, word.id, p.id)
    get :export_to_xml, project_id: p.id
    response.code.should eq("200")
  end

  it "responds with ok code after calling export_to_json with valid project" do
    p = create_project
    ps =
    PreferedSynonym.add_keyword_and_synonym_to_project(syn.id, word.id, p.id)
    get :export_to_json, project_id: p.id
    response.code.should eq("200")
  end

end