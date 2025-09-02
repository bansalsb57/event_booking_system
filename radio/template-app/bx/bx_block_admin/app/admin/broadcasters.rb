# frozen_string_literal: true
require_relative '../rails_helper'
include Warden::Test::Helpers

RSpec.describe Admin::BroadcastersController, type: :controller do
  render_views
  let(:admin_user) do 
    AdminUser.create!(
      name: "admin",
      email: "tesla@example.com",
      password: "Password1!!",
      password_confirmation: "Password1!!",
      user_type: "admin",
      activated: true
    )
  end

  let(:valid_attributes) { 
    attributes_for(:account_block_account).merge(
      user_type: "Broadcaster",
      server_hostname: "example.com",
      server_port: 8000,
      server_password: "password",
      server_mount: "/live",
      server_bitrate: 128
    )
  }

  let(:invalid_attributes) do
    {
      user_name: "",
      email: "invalid",
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
    # Clear any previous registration states to avoid conflicts
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
      load Rails.root.join("bx/bx_block_admin/app/admin/broadcasters.rb")
    end
  end
  
  describe "GET /admin/broadcasters" do
    let!(:broadcaster1) do
      AccountBlock::Account.create!(
        user_name: "Broadcaster One",
        email: "broadcaster1@example.com",
        password: "Password1!!",
        password_confirmation: "Password1!!",
        user_type: "Broadcaster",
        activated: true
      )
    end
  
    let!(:broadcaster2) do
      AccountBlock::Account.create!(
        user_name: "Broadcaster Two",
        email: "broadcaster2@example.com",
        password: "Password2!!",
        password_confirmation: "Password2!!",
        user_type: "Broadcaster",
        activated: false
      )
    end
  
    it "renders the index page with selectable column and action links" do
      get :index
  
      expect(response).to be_successful
      expect(response.body).to include(broadcaster1.id.to_s)
      expect(response.body).to include(broadcaster1.user_name)
      expect(response.body).to include(broadcaster1.email)
      expect(response.body).to include(broadcaster1.user_type)
      expect(response.body).to include(broadcaster1.activated.to_s)
  
      expect(response.body).to include(broadcaster2.id.to_s)
      expect(response.body).to include(broadcaster2.user_name)
      expect(response.body).to include(broadcaster2.email)
      expect(response.body).to include(broadcaster2.user_type)
      expect(response.body).to include(broadcaster2.activated.to_s)
  
      # Check for selectable column and action links
      expect(response.body).to include('input type="checkbox"')
      expect(response.body).to include('a href="/admin/broadcasters')
      expect(response.body).to include('Edit')
      expect(response.body).to include('Delete')
    end
  end

  describe "GET /admin/broadcasters/new" do
    it "renders the new form" do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        account: {
          user_name: "NewBroadcaster",
          email: "broadcaster#{rand(1000)}@example.com",
          server_hostname: "stream.example.com",
          server_port: 8000,
          server_password: "secure123",
          server_mount: "/live",
          server_bitrate: 128
        }
      }
    end

    before do
      allow(SecureRandom).to receive(:hex).with(10).and_return('generatedpassword')
    end

    context 'with valid parameters' do
      it 'creates a new broadcaster' do
        expect {
          post :create, params: valid_params
        }.to change(AccountBlock::Account, :count).by(1)
      end

      it 'logs creation attempt' do
        allow(Rails.logger).to receive(:info)
        post :create, params: valid_params
        expect(Rails.logger).to have_received(:info).with(/Creating Broadcaster Account - Params:/)
      end

      it 'generates random password' do
        post :create, params: valid_params
        expect(SecureRandom).to have_received(:hex).with(10)
        expect(AccountBlock::Account.last.authenticate('generatedpassword')).to be_truthy
      end

      it 'sets broadcaster attributes' do
        post :create, params: valid_params
        broadcaster = AccountBlock::Account.last
        expect(broadcaster.user_type).to eq('Broadcaster')
        expect(broadcaster.activated).to be false
      end

      it 'redirects to show page with success message' do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_broadcaster_path(AccountBlock::Account.last))
        expect(flash[:notice]).to include('created successfully')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { account: { user_name: "" } } }

      before do
        post :create, params: invalid_params
      end

      it 'renders new template with errors' do
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to be_present
      end
    end
  end
end

# template-app/bx/bx_block_admin/app/admin/broadcasters.rb

module Broadcasters
  extend TemplateLoadHelper
end

if Broadcasters.page_registered?("Broadcaster") && Broadcasters.is_being_loaded_from_app?
  Broadcasters.unload_activeadmin_resource("Broadcaster")
end

unless Broadcasters.page_registered?("Broadcasters")
  ActiveAdmin.register AccountBlock::Account, as: "Broadcaster" do
    permit_params :user_name, :email, :user_type, :activated,
                  :server_hostname, :server_port, :server_password, :server_mount, :server_bitrate

    index do
      selectable_column
      id_column
      column :user_name
      column :email
      column :user_type
      column :activated
      column :created_at
      actions
    end

    filter :user_name
    filter :email
    filter :activated
    filter :created_at

    form do |f|
      f.inputs "Broadcaster Details" do
        f.input :user_name, label: "User Name"
        f.input :email
        f.input :user_type, input_html: { value: "Broadcaster" }, as: :hidden
        f.input :activated, input_html: { value: false }, as: :hidden

        if current_admin_user.present?
          f.inputs "Server Details" do
            f.input :server_hostname
            f.input :server_port
            f.input :server_password
            f.input :server_mount
            f.input :server_bitrate
          end
        end
      end
      f.actions
    end

    controller do
      def create
        logger.info "Creating Broadcaster Account - Params: #{params.inspect}"
    
        random_password = SecureRandom.hex(10)
    
        account_params = permitted_params[:account].merge(
          user_type: "Broadcaster",
          activated: false,
          password: random_password,
          password_confirmation: random_password
        )
    
        @broadcaster = AccountBlock::Account.new(account_params)
    
        if @broadcaster.save
          flash[:notice] = "Broadcaster account created successfully. A password reset link has been sent to the email."
          redirect_to admin_broadcaster_path(@broadcaster)
        else
          flash.now[:alert] = @broadcaster.errors.full_messages.join(", ")
          render :new
        end
      end

      private

      def permitted_params
        params.permit(account: [
          :user_name, :email, :user_type, :activated,
          :server_hostname, :server_port, :server_password, :server_mount, :server_bitrate
        ])
      end
    end
  end
end
# =====================
# template-app/bx/bx_block_admin/app/admin/admin_users.rb
module AdminUsers
  extend TemplateLoadHelper
end

if AdminUsers.page_registered?("AdminUser") && AdminUsers.is_being_loaded_from_app?
  AdminUsers.unload_activeadmin_resource("AdminUser")
end

unless AdminUsers.page_registered?("AdminUsers")
  ActiveAdmin.register AdminUser do
    permit_params :name, :email, :password, :password_confirmation, :user_type, :activated

    index do
      selectable_column
      id_column
      column :name
      column :email
      column :user_type
      column :activated
      actions
    end

    filter :name
    filter :email
    filter :user_type
    filter :activated

    form do |f|
      f.inputs do
        f.input :name
        f.input :email
        f.input :password
        f.input :password_confirmation
        f.input :user_type, as: :select, collection: ['admin'], include_blank: false
        f.input :activated, as: :boolean, input_html: { checked: true }
      end
      f.actions
    end

    controller do
      def create
        account_info = params[:admin_user]

        super do |success, failure|
          if success && resource.valid?
            publish_analytics_event('admin.account.created', account_info.except(:password, :password_confirmation))
          else
            handle_error_messages
          end
        end
      end

      def update
        account_info = params[:admin_user].except(:password, :password_confirmation)

        super do |success, failure|
          if success && resource.valid?
            publish_analytics_event('admin.account.updated', account_info)
          else
            handle_error_messages
          end
        end
      end

      def publish_analytics_event(event_name, properties)
        properties = properties || {}
      
        analytics_data = {
          identifier: current_admin_user&.id.to_s,
          properties: properties.compact,
          event_name: event_name
        }
      
        analytics_data[:properties] = analytics_data[:properties].merge(
          action_by: current_admin_user&.id.to_s,
          account_id: resource&.id.to_s
        ).compact

        begin
          BuilderBase::AnalyticsEvent.publish(analytics_data)
        rescue URI::InvalidURIError => e
          Rails.logger.error "Analytics URI Error: #{e.message}"
        rescue StandardError => e
          Rails.logger.error "Analytics Error: #{e.message}"
        end
      end

      private

      def handle_error_messages
        flash.now[:alert] = resource.errors.full_messages.join(' & ')
      end
    end
  end
end
# ================================================================
# template-app/bx/bx_block_admin/spec/admin/admin_users_spec.rb
# frozen_string_literal: true
require_relative '../rails_helper'
include Warden::Test::Helpers

RSpec.describe Admin::AdminUsersController, type: :controller do
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
      name: "Test Admin",
      email: "admin#{SecureRandom.hex(4)}@example.com",
      password: "Password1!!",
      password_confirmation: "Password1!!",
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
    # Clear any previous registration states to avoid conflicts
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
      load Rails.root.join("bx/bx_block_admin/app/admin/admin_users.rb")
    end
  end
  
  describe 'GET /admin/admin_users' do
    let!(:admin_user_1) do
      AdminUser.create!(
        name: "First Admin",
        email: "firstadmin@example.com",
        password: "Password1!!",
        password_confirmation: "Password1!!",
        user_type: "admin",
        activated: true
      )
    end
  
    let!(:admin_user_2) do
      AdminUser.create!(
        name: "Second Admin",
        email: "secondadmin@example.com",
        password: "Password1!!",
        password_confirmation: "Password1!!",
        user_type: "admin",
        activated: false
      )
    end
  
    it 'renders the index page with selectable column and actions' do
      get :index
  
      expect(response).to be_successful
      expect(response.body).to include("First Admin")
      expect(response.body).to include("firstadmin@example.com")
      expect(response.body).to include("Second Admin")
      expect(response.body).to include("secondadmin@example.com")
  
      # Check for selectable column checkboxes
      expect(response.body).to have_css("input[type='checkbox'][name='collection_selection[]'][value='#{admin_user_1.id}']")
      expect(response.body).to have_css("input[type='checkbox'][name='collection_selection[]'][value='#{admin_user_2.id}']")
  
      # Check for action links (View, Edit, Delete)
      expect(response.body).to include(admin_admin_user_path(admin_user_1))  # View link
      expect(response.body).to include(edit_admin_admin_user_path(admin_user_1))  # Edit link
      expect(response.body).to include(admin_admin_user_path(admin_user_1))  # Delete link (form action)
  
      expect(response.body).to include(admin_admin_user_path(admin_user_2))
      expect(response.body).to include(edit_admin_admin_user_path(admin_user_2))
      expect(response.body).to include(admin_admin_user_path(admin_user_2))
    end
  end
  

  describe "GET /admin/admin_users/new" do
    it "renders the new form" do
      get :new
      expect(response).to be_successful
      expect(response.body).to include("Name")
      expect(response.body).to include("Email")
      expect(response.body).to include("Password")
      expect(response.body).to include("Password confirmation")
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        admin_user: {
          name: "New Admin",
          email: "newadmin#{SecureRandom.hex(4)}@example.com",
          password: "Password1!!",
          password_confirmation: "Password1!!",
          user_type: "admin",
          activated: true
        }
      }
    end

    let(:invalid_params) do
      {
        admin_user: {
          name: "",
          email: "",
          password: "",
          password_confirmation: "",
          user_type: "",
          activated: ""
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new AdminUser and redirects to the show page' do
        expect {
          post :create, params: valid_params
        }.to change(AdminUser, :count).by(1)
    
        expect(response).to redirect_to(admin_admin_user_path(AdminUser.last))
      end
    
      it 'publishes an analytics event' do
        expect(BuilderBase::AnalyticsEvent).to receive(:publish).with(
          hash_including(
            event_name: 'admin.account.created',
            properties: hash_including(
              "name" => "New Admin",
              "email" => a_string_starting_with("newadmin"),
              "user_type" => "admin",
              "activated" => "true",
              "action_by" => admin_user.id.to_s,
              "account_id" => a_string_matching(/\d+/)
            )
          )
        )
        post :create, params: valid_params
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new AdminUser and renders the new form' do
        expect {
          post :create, params: invalid_params
        }.not_to change(AdminUser, :count)

        expect(response).to render_template(:new)
        expect(response.body).to include("error")
      end
    end
  end

  describe 'PUT #update' do
    let!(:admin) { create(:admin_user) }
    let(:valid_params) { { id: admin.id, admin_user: { name: 'Updated', activated: false } } }
    let(:invalid_params) { { id: admin.id, admin_user: { name: '' } } }

    before do
      allow(BuilderBase::AnalyticsEvent).to receive(:publish)
    end

    context 'successful update' do
      it 'updates attributes' do
        put :update, params: valid_params
        expect(admin.reload.name).to eq('Updated')
      end

      it 'publishes analytics event' do
        put :update, params: valid_params
        expect(BuilderBase::AnalyticsEvent).to have_received(:publish)
          .with(hash_including(event_name: 'admin.account.updated'))
      end
    end

    context 'failed update' do
      it 'shows errors' do
        put :update, params: invalid_params
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================