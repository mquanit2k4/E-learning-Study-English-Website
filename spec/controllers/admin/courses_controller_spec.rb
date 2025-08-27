require "rails_helper"

RSpec.describe Admin::CoursesController, type: :controller do
  shared_context "admin authentication setup" do
    let(:admin_user) { create(:user, :admin) }

    before do
      log_in_as admin_user
    end
  end

  shared_context "regular user authentication setup" do
    let(:regular_user) { create(:user, :user_role) }

    before do
      log_in_as regular_user
    end
  end

  shared_context "course test data setup" do
    let!(:course1) { create(:course, creator: admin_user, title: "Ruby Programming", description: "Learn Ruby basics") }
    let!(:course2) { create(:course, creator: admin_user, title: "Rails Framework", description: "Advanced Rails") }
    let!(:course3) { create(:course, creator: admin_user, title: "JavaScript", description: "Frontend development") }
  end

  shared_context "pagination setup" do
    before do
      allow(Settings.course).to receive(:page_number).and_return(2)
    end
  end

  include_context "admin authentication setup"

  describe "GET #index action" do
    include_context "course test data setup"

    context "when accessing courses index without search" do
      before do
        get :index
      end

      it "should assign paginated courses to @courses variable" do
        expect(assigns(:courses)).to be_present
      end

      it "should return HTTP 200 success status" do
        expect(response).to have_http_status(:success)
      end

      it "should render the index template" do
        expect(response).to render_template(:index)
      end

      it "should assign pagination object to @pagy variable" do
        expect(assigns(:pagy)).to be_present
      end
    end

    context "when searching by course title" do
      before do
        get :index, params: { search: "Ruby" }
      end

      it "should filter courses by title containing search term" do
        expect(assigns(:courses).any? { |c| c.title.include?("Ruby") }).to be true
      end

      it "should return HTTP 200 success status" do
        expect(response).to have_http_status(:success)
      end
    end

    context "when pagination is configured" do
      include_context "pagination setup"

      before do
        get :index
      end

      it "should create pagination object with correct settings" do
        expect(assigns(:pagy)).to be_present
      end

      it "should limit results according to pagination settings" do
        expect(assigns(:courses).count).to be <= 2
      end
    end

    context "when searching with empty search term" do
      before do
        get :index, params: { search: "" }
      end

      it "should return all courses" do
        expect(assigns(:courses).count).to eq(3)
      end
    end
  end

  describe "GET #new action" do
    context "when accessing new course form" do
      before do
        get :new
      end

      it "should assign new Course instance to @course variable" do
        expect(assigns(:course)).to be_a_new(Course)
      end

      it "should return HTTP 200 success status" do
        expect(response).to have_http_status(:success)
      end

      it "should render the new template" do
        expect(response).to render_template(:new)
      end

      it "should assign admin users to @admin_users variable" do
        expect(assigns(:admin_users)).to be_present
      end
    end
  end

  describe "POST #create action" do
    context "when submitting valid course parameters" do
      let(:valid_course_params) do
        {
          title: "New Course",
          description: "New course description",
          duration: 30,
          course_admin_ids: [admin_user.id]
        }
      end

      before do
        post :create, params: { course: valid_course_params }
      end

      it "should create exactly one new course in database" do
        expect(Course.count).to eq(1)
      end

      it "should create course with correct title attribute" do
        expect(Course.last.title).to eq("New Course")
      end

      it "should create course with correct description attribute" do
        expect(Course.last.description).to eq("New course description")
      end

      it "should assign current user as course creator" do
        expect(Course.last.creator).to eq(admin_user)
      end

      it "should set success flash message using I18n translation" do
        expect(flash[:success]).to eq(I18n.t("admin.courses.create_success"))
      end

      it "should redirect to admin course path" do
        expect(response).to redirect_to(admin_course_path(Course.last))
      end
    end

    context "when submitting invalid course parameters" do
      let(:invalid_course_params) do
        {
          title: "",
          description: "",
          course_admin_ids: []
        }
      end

      before do
        post :create, params: { course: invalid_course_params }
      end

      it "should not create any new course in database" do
        expect(Course.count).to eq(0)
      end

      it "should render the new template for form redisplay" do
        expect(response).to render_template(:new)
      end

      it "should return HTTP 422 unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "should assign admin users to @admin_users variable" do
        expect(assigns(:admin_users)).to be_present
      end
    end
  end

  describe "GET #show action" do
    include_context "course test data setup"

    context "when viewing existing course with valid ID" do
      before do
        get :show, params: { id: course1.id }
      end

      it "should assign the found course to @course variable" do
        expect(assigns(:course)).to eq(course1)
      end

      it "should return HTTP 200 success status" do
        expect(response).to have_http_status(:success)
      end

      it "should render the show template" do
        expect(response).to render_template(:show)
      end
    end

    context "when attempting to view course with invalid ID" do
      before do
        get :show, params: { id: -1 }
      end

      it "should set danger flash message using I18n translation" do
        expect(flash[:danger]).to eq(I18n.t("admin.courses.show.course_not_found"))
      end

      it "should redirect to admin courses path" do
        expect(response).to redirect_to(admin_courses_path)
      end
    end
  end

  describe "GET #edit action" do
    include_context "course test data setup"

    context "when editing existing course with valid ID" do
      before do
        get :edit, params: { id: course1.id }
      end

      it "should assign the found course to @course variable" do
        expect(assigns(:course)).to eq(course1)
      end

      it "should return HTTP 200 success status" do
        expect(response).to have_http_status(:success)
      end

      it "should render the edit template" do
        expect(response).to render_template(:edit)
      end

      it "should assign admin users to @admin_users variable" do
        expect(assigns(:admin_users)).to be_present
      end

      it "should set course admin ids from course admins" do
        expect(assigns(:course).course_admin_ids).to be_an(Array)
      end
    end

    context "when attempting to edit course with invalid ID" do
      before do
        get :edit, params: { id: -1 }
      end

      it "should set danger flash message using I18n translation" do
        expect(flash[:danger]).to eq(I18n.t("admin.courses.edit.course_not_found"))
      end

      it "should redirect to admin courses path" do
        expect(response).to redirect_to(admin_courses_path)
      end
    end
  end

  describe "PATCH #update action" do
    include_context "course test data setup"

    context "when updating with valid parameters" do
      let(:valid_update_params) do
        {
          title: "Updated Course",
          description: "Updated description",
          duration: 45,
          course_admin_ids: [admin_user.id]
        }
      end

      before do
        patch :update, params: { id: course1.id, course: valid_update_params }
        course1.reload
      end

      it "should update course title attribute correctly" do
        expect(course1.title).to eq("Updated Course")
      end

      it "should update course description attribute correctly" do
        expect(course1.description).to eq("Updated description")
      end

      it "should set success flash message using I18n translation" do
        expect(flash[:success]).to eq(I18n.t("admin.courses.update_success"))
      end

      it "should redirect to admin course path" do
        expect(response).to redirect_to(admin_course_path(course1))
      end
    end

    context "when updating with invalid parameters" do
      let(:invalid_update_params) do
        {
          title: "",
          description: "",
          course_admin_ids: []
        }
      end

      before do
        original_title = course1.title
        patch :update, params: { id: course1.id, course: invalid_update_params }
        course1.reload
        @original_title = original_title
      end

      it "should not change course title attribute" do
        expect(course1.title).to eq(@original_title)
      end

      it "should render the edit template for form redisplay" do
        expect(response).to render_template(:edit)
      end

      it "should return HTTP 422 unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "should assign admin users to @admin_users variable" do
        expect(assigns(:admin_users)).to be_present
      end
    end

    context "when attempting to update course with invalid ID" do
      before do
        patch :update, params: { id: -1, course: { title: "test" } }
      end

      it "should set danger flash message using I18n translation" do
        expect(flash[:danger]).to eq(I18n.t("admin.courses.update.course_not_found"))
      end

      it "should redirect to admin courses path" do
        expect(response).to redirect_to(admin_courses_path)
      end
    end
  end

  describe "DELETE #destroy action" do
    include_context "course test data setup"

    context "when destroy operation is successful" do
      before do
        delete :destroy, params: { id: course1.id }
      end

      it "should remove the course from database" do
        expect(Course.exists?(course1.id)).to be_falsey
      end

      it "should set success flash message using I18n translation" do
        expect(flash[:success]).to eq(I18n.t("admin.courses.destroy.delete_success"))
      end

      it "should redirect to admin courses path" do
        expect(response).to redirect_to(admin_courses_path)
      end
    end

    context "when destroy operation fails" do
      before do
        allow_any_instance_of(Course).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: course1.id }
      end

      it "should not remove the course from database" do
        expect(Course.exists?(course1.id)).to be_truthy
      end

      it "should set error flash message using I18n translation" do
        expect(flash[:error]).to eq(I18n.t("admin.courses.destroy.delete_failed"))
      end

      it "should redirect to admin courses path" do
        expect(response).to redirect_to(admin_courses_path)
      end
    end

    context "when attempting to destroy course with invalid ID" do
      before do
        delete :destroy, params: { id: -1 }
      end

      it "should set danger flash message using I18n translation" do
        expect(flash[:danger]).to eq(I18n.t("admin.courses.destroy.course_not_found"))
      end

      it "should redirect to admin courses path" do
        expect(response).to redirect_to(admin_courses_path)
      end
    end
  end

  describe "private method #set_course" do
    context "when course exists in database" do
      let!(:existing_course) { create(:course, creator: admin_user) }

      before do
        get :show, params: { id: existing_course.id }
      end

      it "should set @course instance variable correctly" do
        expect(assigns(:course)).to eq(existing_course)
      end
    end

    context "when course does not exist in database" do
      before do
        get :show, params: { id: -1 }
      end

      it "should redirect with danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.courses.show.course_not_found"))
      end

      it "should redirect to admin courses path" do
        expect(response).to redirect_to(admin_courses_path)
      end
    end
  end

  describe "authorization and access control scenarios" do
    include_context "course test data setup"

    context "when user is not admin but regular user" do
      include_context "regular user authentication setup"

      context "accessing index action" do
        before do
          get :index
        end

        it "should set danger flash message for unauthorized access" do
          expect(flash[:danger]).to eq(I18n.t("admin.courses.authenticate_admin.not_authorized"))
        end

        it "should redirect to root path" do
          expect(response).to redirect_to(root_path)
        end
      end

      context "accessing new action" do
        before do
          get :new
        end

        it "should set danger flash message for unauthorized access" do
          expect(flash[:danger]).to eq(I18n.t("admin.courses.authenticate_admin.not_authorized"))
        end

        it "should redirect to root path" do
          expect(response).to redirect_to(root_path)
        end
      end

      context "accessing create action" do
        before do
          post :create, params: { course: { title: "test" } }
        end

        it "should set danger flash message for unauthorized access" do
          expect(flash[:danger]).to eq(I18n.t("admin.courses.authenticate_admin.not_authorized"))
        end

        it "should redirect to root path" do
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context "when user is not authenticated at all" do
      before do
        log_out
      end

      context "accessing index action without authentication" do
        before do
          get :index
        end

        it "should set danger flash message for unauthorized access" do
          expect(flash[:danger]).to eq(I18n.t("admin.courses.authenticate_admin.not_authorized"))
        end

        it "should redirect to root path" do
          expect(response).to redirect_to(root_path)
        end
      end

      context "accessing create action without authentication" do
        before do
          post :create, params: { course: { title: "test" } }
        end

        it "should set danger flash message for unauthorized access" do
          expect(flash[:danger]).to eq(I18n.t("admin.courses.authenticate_admin.not_authorized"))
        end

        it "should redirect to root path" do
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
