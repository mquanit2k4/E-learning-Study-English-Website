require "rails_helper"

RSpec.describe Admin::TestsController, type: :controller do
  let(:admin) { create(:user, role: :admin) }
  let(:test_obj) { create(:test) }
  let(:valid_attributes) { attributes_for(:test) }
  let(:invalid_attributes) { { name: "", duration: -1 } }

  before do
    log_in_as admin
  end

  describe "GET #index" do
    context "when accessing tests list" do
      let!(:test1) { create(:test, name: "Math Test") }
      let!(:test2) { create(:test, name: "Science Test") }

      before { get :index }

      it "returns successful response" do
        expect(response).to have_http_status(:success)
      end

      it "assigns @tests" do
        expect(assigns(:tests)).to include(test1, test2)
      end

      it "assigns @pagy" do
        expect(assigns(:pagy)).to be_present
      end
    end

    context "when searching tests" do
      let!(:math_test) { create(:test, name: "Math Test") }
      let!(:science_test) { create(:test, name: "Science Test") }

      before { get :index, params: { search: "Math" } }

      it "includes matching tests" do
        expect(assigns(:tests)).to include(math_test)
      end

      it "excludes non-matching tests" do
        expect(assigns(:tests)).not_to include(science_test)
      end
    end
  end

  describe "GET #show" do
    context "when test exists" do
      let!(:question) { create(:question, test: test_obj) }

      before { get :show, params: { id: test_obj.id } }

      it "returns successful response" do
        expect(response).to have_http_status(:success)
      end

      it "assigns @test" do
        expect(assigns(:test)).to eq(test_obj)
      end

      it "assigns @questions with answers" do
        expect(assigns(:questions)).to include(question)
      end
    end

    context "when test does not exist" do
      before { get :show, params: { id: -1 } }

      it "sets danger flash message" do
        expect(flash[:danger]).to be_present
      end

      it "redirects to tests index" do
        expect(response).to redirect_to(admin_tests_path)
      end
    end
  end

  describe "GET #new" do
    before { get :new }

    it "returns successful response" do
      expect(response).to have_http_status(:success)
    end

    it "assigns new test instance" do
      expect(assigns(:test)).to be_a_new(Test)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      before { post :create, params: { test: valid_attributes } }

      it "creates a new test" do
        expect(Test.count).to eq(1)
      end

      it "assigns @test" do
        expect(assigns(:test)).to be_persisted
      end

      it "sets success flash message" do
        expect(flash[:success]).to be_present
      end

      it "redirects to test show page" do
        expect(response).to redirect_to(admin_test_path(assigns(:test)))
      end
    end

    context "with invalid parameters" do
      before { post :create, params: { test: invalid_attributes } }

      it "does not create a new test" do
        expect(Test.count).to eq(0)
      end

      it "assigns @test as new record" do
        expect(assigns(:test)).to be_a_new(Test)
      end

      it "assigns @test with errors" do
        expect(assigns(:test).errors).not_to be_empty
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to be_present
      end

      it "renders new template" do
        expect(response).to render_template(:new)
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET #edit" do
    context "when test exists" do
      before { get :edit, params: { id: test_obj.id } }

      it "returns successful response" do
        expect(response).to have_http_status(:success)
      end

      it "assigns @test" do
        expect(assigns(:test)).to eq(test_obj)
      end
    end

    context "when test does not exist" do
      before { get :edit, params: { id: -1 } }

      it "sets danger flash message" do
        expect(flash[:danger]).to be_present
      end

      it "redirects to tests index" do
        expect(response).to redirect_to(admin_tests_path)
      end
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      let(:new_attributes) { { name: "Updated Test Name" } }

      before { patch :update, params: { id: test_obj.id, test: new_attributes } }

      it "updates the test" do
        test_obj.reload
        expect(test_obj.name).to eq("Updated Test Name")
      end

      it "assigns @test" do
        expect(assigns(:test)).to eq(test_obj)
      end

      it "sets success flash message" do
        expect(flash[:success]).to be_present
      end

      it "redirects to test show page" do
        expect(response).to redirect_to(admin_test_path(test_obj))
      end
    end

    context "with invalid parameters" do
      before { patch :update, params: { id: test_obj.id, test: invalid_attributes } }

      it "does not update the test" do
        original_name = test_obj.name
        test_obj.reload
        expect(test_obj.name).to eq(original_name)
      end

      it "assigns @test" do
        expect(assigns(:test)).to eq(test_obj)
      end

      it "assigns @test with errors" do
        expect(assigns(:test).errors).not_to be_empty
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to be_present
      end

      it "renders edit template" do
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when test does not exist" do
      before { patch :update, params: { id: -1, test: valid_attributes } }

      it "sets danger flash message" do
        expect(flash[:danger]).to be_present
      end

      it "redirects to tests index" do
        expect(response).to redirect_to(admin_tests_path)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when test can be destroyed" do
      before { delete :destroy, params: { id: test_obj.id } }

      it "destroys the test" do
        expect(Test.exists?(test_obj.id)).to be_falsey
      end

      it "sets success flash message" do
        expect(flash[:success]).to be_present
      end

      it "redirects to tests index" do
        expect(response).to redirect_to(admin_tests_path)
      end
    end

    context "when test cannot be destroyed" do
      before do
        allow_any_instance_of(Test).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: test_obj.id }
      end

      it "does not destroy the test" do
        expect(Test.exists?(test_obj.id)).to be_truthy
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to be_present
      end

      it "redirects to test show page" do
        expect(response).to redirect_to(admin_test_path(test_obj))
      end
    end

    context "when test does not exist" do
      before { delete :destroy, params: { id: -1 } }

      it "sets danger flash message" do
        expect(flash[:danger]).to be_present
      end

      it "redirects to tests index" do
        expect(response).to redirect_to(admin_tests_path)
      end
    end
  end
end
