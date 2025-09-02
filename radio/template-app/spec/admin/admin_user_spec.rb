# frozen_string_literal: true

require_relative '../rails_helper'
include Warden::Test::Helpers

RSpec.describe Admin::AdminUsersController, type: :controller do
  render_views

  PASSWORD = "SecurePass".freeze
  let(:admin_user) do 
    AdminUser.create!(
      name: "admin",
      email: "adminadmin@example.com",
      password: PASSWORD,
      password_confirmation: PASSWORD,
      user_type: "admin",
      activated: true
    )
  end

  let(:valid_attributes) { 
    {
      name: "Test Admin",
      email: "admin#{SecureRandom.hex(4)}@example.com",
      password: PASSWORD,
      password_confirmation: PASSWORD,
      user_type: "admin",
      activated: true
    }
  }

  let(:invalid_attributes) do
    {
      name: "",
      email: "",
      password: "",
      password_confirmation: "",
      user_type: "",
      activated: ""
    }
  end

  before(:each) do
    sign_in admin_user
  end

  before do
    allow(AdminUsers).to receive(:page_registered?).and_return(false)
    allow(AdminUsers).to receive(:is_being_loaded_from_app?).and_return(false)
  end

  it "does not call unload_activeadmin_resource when page is not registered" do
    expect(AdminUsers).not_to receive(:unload_activeadmin_resource)
    # Rails.application.reload_routes!
    load Rails.root.join("bx/bx_block_admin/app/admin/admin_users.rb")
  end

  context "when the page is registered and being loaded from app" do
    before do
      allow(AdminUsers).to receive(:page_registered?).with("AdminUser").and_return(true)
      allow(AdminUsers).to receive(:is_being_loaded_from_app?).and_return(true)
    end

    it "calls unload_activeadmin_resource" do
      expect(AdminUsers).to receive(:unload_activeadmin_resource).with("AdminUser")
      Rails.application.reload_routes!
      load Rails.root.join("bx/bx_block_admin/app/admin/admin_users.rb")
    end
  end

  describe "GET #index" do
    it "renders the index page with all columns and actions" do
      get :index

      expect(response).to have_http_status(:success)
      
      expect(response.body).to include("Name")
      expect(response.body).to include("Email")
      expect(response.body).to include("User Type")
      expect(response.body).to include("Activated")

      expect(response.body).to include(admin_user.name)
      expect(response.body).to include(admin_user.email)
      expect(response.body).to include(admin_user.user_type)
      expect(response.body).to include(admin_user.activated.to_s)

      expect(response.body).to include(admin_user.id.to_s)

      expect(response.body).to match(/(Edit|View|Delete)/i)
    end
  end

  describe "GET #new" do
    it "renders the new admin user form" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    let!(:admin) { AdminUser.create!(valid_attributes) }

    it "renders the show page with admin user details" do
      get :show, params: { id: admin.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include(admin.name)
      expect(response.body).to include(admin.email)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new admin user and redirects to show page" do
        expect {
          post :create, params: { admin_user: valid_attributes }
        }.to change(AdminUser, :count).by(1)
        expect(response).to redirect_to(admin_admin_user_path(AdminUser.last))
      end
    end

    context "with invalid attributes" do
      it "does not create a new admin user and re-renders the new template" do
        expect {
          post :create, params: { admin_user: invalid_attributes }
        }.not_to change(AdminUser, :count)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT #update" do
    let!(:admin) { AdminUser.create!(valid_attributes) }

    context "with valid params" do
      it "updates the admin user and redirects to show page" do
        put :update, params: { id: admin.id, admin_user: { name: "Updated Admin" } }
        admin.reload
        expect(admin.name).to eq("Updated Admin")
        expect(response).to redirect_to(admin_admin_user_path(admin))
      end
    end

    context "with invalid params" do
      it "does not update the admin user and re-renders the edit template" do
        put :update, params: { id: admin.id, admin_user: { email: "" } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:admin) { AdminUser.create!(valid_attributes) }

    it "destroys the admin user and redirects to index page" do
      expect {
        delete :destroy, params: { id: admin.id }
      }.to change(AdminUser, :count).by(-1)
      expect(response).to redirect_to(admin_admin_users_path)
    end

    it "handles destroy failure" do
      allow_any_instance_of(AdminUser).to receive(:destroy).and_return(false)
      delete :destroy, params: { id: admin.id }
      expect(response).to redirect_to(admin_admin_users_path)
      expect(flash[:alert]).to eq("Failed to delete Admin User.")
    end
  end
end
# =======================================================================================
# last updated

# # frozen_string_literal: true

# require_relative '../rails_helper'
# include Warden::Test::Helpers

# RSpec.describe Admin::AdminUsersController, type: :controller do
#   render_views

#   PASSWORD = "SecurePass".freeze
#   let(:admin_user) do 
#     AdminUser.create!(
#       name: "admin",
#       email: "adminadmin@example.com",
#       password: PASSWORD,
#       password_confirmation: PASSWORD,
#       user_type: "admin",
#       activated: true
#     )
#   end

#   let(:valid_attributes) { 
#     {
#       name: "Test Admin",
#       email: "admin#{SecureRandom.hex(4)}@example.com",
#       password: PASSWORD,
#       password_confirmation: PASSWORD,
#       user_type: "admin",
#       activated: true
#     }
#   }

#   let(:invalid_attributes) do
#     {
#       name: "",
#       email: "",
#       password: "",
#       password_confirmation: "",
#       user_type: "",
#       activated: ""
#     }
#   end

#   before(:each) do
#     sign_in admin_user
#   end

#   before do
#     allow(AdminUsers).to receive(:page_registered?).and_return(false)
#     allow(AdminUsers).to receive(:is_being_loaded_from_app?).and_return(false)
#   end

#   it "does not call unload_activeadmin_resource when page is not registered" do
#     expect(AdminUsers).not_to receive(:unload_activeadmin_resource)
#     # Rails.application.reload_routes!
#     load Rails.root.join("bx/bx_block_admin/app/admin/admin_users.rb")
#   end

#   context "when the page is registered and being loaded from app" do
#     before do
#       allow(AdminUsers).to receive(:page_registered?).with("AdminUser").and_return(true)
#       allow(AdminUsers).to receive(:is_being_loaded_from_app?).and_return(true)
#     end

#     it "calls unload_activeadmin_resource" do
#       expect(AdminUsers).to receive(:unload_activeadmin_resource).with("AdminUser")
#       Rails.application.reload_routes!
#       load Rails.root.join("bx/bx_block_admin/app/admin/admin_users.rb")
#     end
#   end

#   describe "GET #index" do
#     it "renders the index page with all columns and actions" do
#       get :index

#       expect(response).to have_http_status(:success)
      
#       # Check presence of table header columns (column names)
#       expect(response.body).to include("Name")
#       expect(response.body).to include("Email")
#       expect(response.body).to include("User Type")
#       expect(response.body).to include("Activated")

#       # Check presence of admin user's data inside the table
#       expect(response.body).to include(admin_user.name)
#       expect(response.body).to include(admin_user.email)
#       expect(response.body).to include(admin_user.user_type)
#       expect(response.body).to include(admin_user.activated.to_s)

#       expect(response.body).to include(admin_user.id.to_s)

#       expect(response.body).to match(/(Edit|View|Delete)/i)
#     end
#   end

#   describe "GET #new" do
#     it "renders the new admin user form" do
#       get :new
#       expect(response).to have_http_status(:success)
#     end
#   end

#   describe "GET #show" do
#     let!(:admin) { AdminUser.create!(valid_attributes) }

#     it "renders the show page with admin user details" do
#       get :show, params: { id: admin.id }
#       expect(response).to have_http_status(:success)
#       expect(response.body).to include(admin.name)
#       expect(response.body).to include(admin.email)
#     end
#   end

#   describe "POST #create" do
#     context "with valid attributes" do
#       it "creates a new admin user and redirects to show page" do
#         expect {
#           post :create, params: { admin_user: valid_attributes }
#         }.to change(AdminUser, :count).by(1)
#         expect(response).to redirect_to(admin_admin_user_path(AdminUser.last))
#       end
#     end

#     context "with invalid attributes" do
#       it "does not create a new admin user and re-renders the new template" do
#         expect {
#           post :create, params: { admin_user: invalid_attributes }
#         }.not_to change(AdminUser, :count)
#         expect(response).to render_template(:new)
#       end
#     end
#   end

#   describe "PUT #update" do
#     let!(:admin) { AdminUser.create!(valid_attributes) }

#     context "with valid params" do
#       it "updates the admin user and redirects to show page" do
#         put :update, params: { id: admin.id, admin_user: { name: "Updated Admin" } }
#         admin.reload
#         expect(admin.name).to eq("Updated Admin")
#         expect(response).to redirect_to(admin_admin_user_path(admin))
#       end
#     end

#     context "with invalid params" do
#       it "does not update the admin user and re-renders the edit template" do
#         put :update, params: { id: admin.id, admin_user: { email: "" } }
#         expect(response).to render_template(:edit)
#       end
#     end
#   end

#   describe "DELETE #destroy" do
#     let!(:admin) { AdminUser.create!(valid_attributes) }

#     it "destroys the admin user and redirects to index page" do
#       expect {
#         delete :destroy, params: { id: admin.id }
#       }.to change(AdminUser, :count).by(-1)
#       expect(response).to redirect_to(admin_admin_users_path)
#     end

#     it "handles destroy failure" do
#       allow_any_instance_of(AdminUser).to receive(:destroy).and_return(false)
#       delete :destroy, params: { id: admin.id }
#       expect(response).to redirect_to(admin_admin_users_path)
#       expect(flash[:alert]).to eq("Failed to delete Admin User.")
#     end
#   end
# end


require_relative '../rails_helper'
include Warden::Test::Helpers

RSpec.describe Admin::AdminUsersController, type: :controller do
  render_views

  PASSWORD = "SecurePass".freeze
  let(:admin_user) do 
    AdminUser.create!(
      name: "admin",
      email: "adminadmin@example.com",
      password: PASSWORD,
      password_confirmation: PASSWORD,
      user_type: "admin",
      activated: true
    )
  end

  let(:valid_attributes) { 
    {
      name: "Test Admin",
      email: "admin#{SecureRandom.hex(4)}@example.com",
      password: PASSWORD,
      password_confirmation: PASSWORD,
      user_type: "admin",
      activated: true
    }
  }

  let(:invalid_attributes) do
    {
      name: "",
      email: "",
      password: "",
      password_confirmation: "",
      user_type: "",
      activated: ""
    }
  end

  before(:each) do
    sign_in admin_user
  end

  before do
    allow(AdminUsers).to receive(:page_registered?).and_return(false)
    allow(AdminUsers).to receive(:is_being_loaded_from_app?).and_return(false)
  end

  it "does not call unload_activeadmin_resource when page is not registered" do
    expect(AdminUsers).not_to receive(:unload_activeadmin_resource)
    load Rails.root.join("bx/bx_block_admin/app/admin/admin_users.rb")
  end

  context "when the page is registered and being loaded from app" do
    before do
      allow(AdminUsers).to receive(:page_registered?).with("AdminUser").and_return(true)
      allow(AdminUsers).to receive(:is_being_loaded_from_app?).and_return(true)
    end

    it "calls unload_activeadmin_resource" do
      expect(AdminUsers).to receive(:unload_activeadmin_resource).with("AdminUser")
      Rails.application.reload_routes!
      load Rails.root.join("bx/bx_block_admin/app/admin/admin_users.rb")
    end
  end

  describe "GET #index" do
    it "renders the index page with all columns and actions" do
      get :index
      expect(response).to have_http_status(:success)
      
      # Check presence of table header columns
      expect(response.body).to include("Name")
      expect(response.body).to include("Email")
      expect(response.body).to include("User Type")
      expect(response.body).to include("Activated")

      # Check presence of admin user's data
      expect(response.body).to include(admin_user.name)
      expect(response.body).to include(admin_user.email)
      expect(response.body).to include(admin_user.user_type)
      expect(response.body).to include(admin_user.activated.to_s)
      expect(response.body).to include(admin_user.id.to_s)
    end
  end

  describe "GET #new" do
    it "renders the new admin user form" do
      get :new
      expect(response).to have_http_status(:success)
      expect(response.body).to include("New Admin User")
      expect(response.body).to include("Name")
      expect(response.body).to include("Email")
      expect(response.body).to include("Password")
      expect(response.body).to include("User")
      expect(response.body).to include("Activated")
    end
  end

  describe "GET #show" do
    let!(:admin) { AdminUser.create!(valid_attributes) }

    it "renders the show page with admin user details" do
      get :show, params: { id: admin.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include(admin.name)
      expect(response.body).to include(admin.email)
      expect(response.body).to include(admin.user_type)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new admin user and redirects to show page" do
        expect {
          post :create, params: { admin_user: valid_attributes }
        }.to change(AdminUser, :count).by(1)
        expect(response).to redirect_to(admin_admin_user_path(AdminUser.last))
        expect(flash[:notice]).to eq("Admin User created successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not create a new admin user and re-renders the new template" do
        expect {
          post :create, params: { admin_user: invalid_attributes }
        }.not_to change(AdminUser, :count)
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "PUT #update" do
    let!(:admin) { AdminUser.create!(valid_attributes) }

    context "with valid params" do
      it "updates the admin user and redirects to show page" do
        put :update, params: { id: admin.id, admin_user: { name: "Updated Admin" } }
        admin.reload
        expect(admin.name).to eq("Updated Admin")
        expect(response).to redirect_to(admin_admin_user_path(admin))
        expect(flash[:notice]).to eq("Admin User updated successfully.")
      end
    end

    context "with invalid params" do
      it "does not update the admin user and re-renders the edit template" do
        put :update, params: { id: admin.id, admin_user: { email: "" } }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:admin) { AdminUser.create!(valid_attributes) }

    it "destroys the admin user and redirects to index page" do
      expect {
        delete :destroy, params: { id: admin.id }
      }.to change(AdminUser, :count).by(-1)
      expect(response).to redirect_to(admin_admin_users_path)
      expect(flash[:notice]).to eq("Admin User deleted successfully.")
    end

    it "handles destroy failure" do
      allow_any_instance_of(AdminUser).to receive(:destroy).and_return(false)
      delete :destroy, params: { id: admin.id }
      expect(response).to redirect_to(admin_admin_users_path)
      expect(flash[:alert]).to eq("Failed to delete Admin User.")
    end
  end
end

# ========================================================================================
# last updated

# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe Admin::BroadcastersController, type: :controller do
  render_views

  let(:admin_user) do 
    AdminUser.create!(
      name: "admin",
      email: "adminadmin@example.com",
      password: "Password1!!",
      password_confirmation: "Password1!!",
      user_type: "admin",
      activated: true
    )
  end

  let(:valid_attributes) { 
    {
      user_name: "Test Broadcaster",
      email: "broadcaster#{SecureRandom.hex(4)}@example.com",
      password: "asdf123",
      password_confirmation: "asdf123",
      user_type: "Broadcaster",
      server_hostname: "localhost",
      server_port: 8000,
      server_password: "password123",
      server_mount: "/test",
      server_bitrate: 32
    }
  }

  let(:invalid_attributes) do
    {
      user_name: "",
      email: "",
      server_hostname: "",
      server_port: "",
      server_password: "",
      server_mount: "",
      server_bitrate: ""
    }
  end

  before(:each) do
    sign_in admin_user
  end

  before do
    allow(Broadcasters).to receive(:page_registered?).and_return(false)
    allow(Broadcasters).to receive(:is_being_loaded_from_app?).and_return(false)
  end

  it "does not call unload_activeadmin_resource when page is not registered" do
    expect(Broadcasters).not_to receive(:unload_activeadmin_resource)
    load Rails.root.join("bx/bx_block_admin/app/admin/broadcasters.rb")
  end

  context "when the page is registered and being loaded from app" do
    before do
      allow(Broadcasters).to receive(:page_registered?).with("Broadcaster").and_return(true)
      allow(Broadcasters).to receive(:is_being_loaded_from_app?).and_return(true)
    end

    it "calls unload_activeadmin_resource" do
      expect(Broadcasters).to receive(:unload_activeadmin_resource).with("Broadcaster")
      Rails.application.reload_routes!
      load Rails.root.join("bx/bx_block_admin/app/admin/broadcasters.rb")
    end
  end

  describe "GET #index" do
    let!(:broadcaster) { AccountBlock::Account.create!(valid_attributes) }

    it "renders the index page with broadcasters" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Broadcasters")
      expect(response.body).to include(broadcaster.user_name)
      expect(response.body).to include(broadcaster.email)
    end
  end

  describe "GET #show" do
    let!(:broadcaster) { AccountBlock::Account.create!(valid_attributes) }

    it "renders the show page with broadcaster details" do
      get :show, params: { id: broadcaster.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include(broadcaster.user_name)
      expect(response.body).to include(broadcaster.email)
      expect(response.body).to include(broadcaster.server_hostname)
      expect(response.body).to include(broadcaster.server_mount)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new broadcaster and redirects to show page" do
        expect {
          post :create, params: { account: valid_attributes }
        }.to change(AccountBlock::Account, :count).by(1)

        new_broadcaster = AccountBlock::Account.last
        expect(new_broadcaster.user_name).to eq("Test Broadcaster")
        expect(new_broadcaster.user_type).to eq("Broadcaster")
        expect(response).to redirect_to(admin_broadcaster_path(new_broadcaster))
      end
    end

    context "with invalid attributes" do
      it "does not create a new broadcaster and re-renders the new template" do
        expect {
          post :create, params: { account: invalid_attributes }
        }.not_to change(AccountBlock::Account, :count)

        expect(response).to render_template(:new)
      end
    end
  end

  # describe "PUT #update" do
  #   let!(:broadcaster) { AccountBlock::Account.create!(valid_attributes) }

  #   context "with valid params" do
  #     let(:new_attributes) {
  #       { user_name: "Updated Broadcaster", server_bitrate: 256 }
  #     }

  #     it "updates the broadcaster and redirects to show page" do
  #       put :update, params: { id: broadcaster.id, account: new_attributes }
  #       broadcaster.reload
  #       expect(broadcaster.user_name).to eq("Updated Broadcaster")
  #       expect(broadcaster.server_bitrate).to eq(256)
  #       expect(response).to redirect_to(admin_broadcaster_path(broadcaster))
  #     end
  #   end

  #   context "with invalid params" do
  #     let(:invalid_attributes) { { email: "" } }

  #     it "does not update the broadcaster and re-renders the edit template" do
  #       put :update, params: { id: broadcaster.id, account: invalid_attributes }
  #       expect(response).to render_template(:edit)
  #     end
  #   end
  # end

  describe "DELETE #destroy" do
    let!(:broadcaster) { AccountBlock::Account.create!(valid_attributes) }

    it "destroys the broadcaster and redirects to index page" do
      expect {
        delete :destroy, params: { id: broadcaster.id }
      }.to change(AccountBlock::Account, :count).by(-1)

      expect(response).to redirect_to(admin_broadcasters_path)
    end
  end
end
