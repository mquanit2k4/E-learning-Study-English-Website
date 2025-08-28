require "rails_helper"

RSpec.describe Admin::UserCoursesController, type: :controller do
  shared_context "admin logged in" do
    let(:admin_user) { create(:user, :admin) }
    before { log_in_as admin_user }
  end

  shared_context "user courses dataset" do
    let!(:course) { create(:course, creator: admin_user) }
    let!(:pending_uc) { create(:user_course, course: course, enrolment_status: :pending) }
    let!(:approved_uc) { create(:user_course, course: course, enrolment_status: :approved) }
    let!(:rejected_uc) { create(:user_course, :rejected, course: course) }
    let!(:completed_uc) { create(:user_course, enrolment_status: :completed, course: course) }
  end

  include_context "admin logged in"
  include_context "user courses dataset"

  describe "GET #index listing registrations" do
    before { get :index }
    it "assigns user_courses collection" do
      expect(assigns(:user_courses)).to be_present
    end
    it "assigns courses collection" do
      expect(assigns(:courses)).to be_present
    end
    it "assigns pagy object" do
      expect(assigns(:pagy)).to be_present
    end
  end

  describe "GET #index with filters" do
    before { get :index, params: { status: "approved", course: course.id } }
    it "filters by status approved" do
      expect(assigns(:user_courses).all?(&:approved?)).to be true
    end
  end

  describe "PATCH #approve approving single registration" do
    context "when success" do
      before { patch :approve, params: { id: pending_uc.id } }
      it "updates status to approved" do
        expect(pending_uc.reload.approved?).to be true
      end
      it "sets flash success" do
        expect(flash[:success]).to eq(I18n.t("admin.user_courses.approve.approve_success"))
      end
      it "redirects index" do
        expect(response).to redirect_to(admin_user_courses_path)
      end
    end

    context "when user_course not found" do
      before { patch :approve, params: { id: -1 } }
      it "sets flash danger user_course_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.user_courses.approve.user_course_not_found"))
      end
      it "redirects index" do
        expect(response).to redirect_to(admin_user_courses_path)
      end
    end

    context "when exception raised" do
      before do
        allow_any_instance_of(UserCourse).to receive(:approved!).and_raise(StandardError.new("boom"))
        patch :approve, params: { id: pending_uc.id }
      end
      it "sets flash danger approve_failed" do
        expect(flash[:danger]).to eq(I18n.t("admin.user_courses.approve.approve_failed"))
      end
    end
  end

  describe "PATCH #reject rejecting single registration" do
    context "when success with reason" do
      before { patch :reject, params: { id: pending_uc.id, reason: "Invalid docs" } }
      it "updates status to rejected" do
        expect(pending_uc.reload.rejected?).to be true
      end
      it "stores rejection reason" do
        expect(pending_uc.reload.reason).to eq("Invalid docs")
      end
      it "sets flash success" do
        expect(flash[:success]).to eq(I18n.t("admin.user_courses.reject.reject_success"))
      end
    end

    context "when failure rescued" do
      before do
        allow_any_instance_of(UserCourse).to receive(:update!).and_raise(StandardError.new("boom"))
        patch :reject, params: { id: pending_uc.id, reason: "X" }
      end
      it "sets flash danger reject_failed" do
        expect(flash[:danger]).to eq(I18n.t("admin.user_courses.reject.reject_failed"))
      end
    end
  end

  describe "POST #approve_selected bulk approval" do
    context "when selection missing" do
      before { post :approve_selected }
      it "sets flash danger no_selection" do
        expect(flash[:danger]).to eq(I18n.t("admin.user_courses.approve_selected.no_selection"))
      end
    end

    context "when contains invalid statuses" do
      before { post :approve_selected, params: { user_course_ids: [approved_uc.id] } }
      it "sets flash danger invalid_status_error" do
        expect(flash[:danger]).to eq(I18n.t("admin.user_courses.approve_selected.invalid_status_error"))
      end
    end

    context "when none approvable after filtering" do
      before { post :approve_selected, params: { user_course_ids: [completed_uc.id] } }
      it "sets flash danger no_approvable_courses" do
        expect(flash[:danger]).to eq(I18n.t("admin.user_courses.approve_selected.no_approvable_courses"))
      end
    end

    context "when valid pending row" do
      let!(:other_pending) { create(:user_course, course: course, enrolment_status: :pending) }
      before { post :approve_selected, params: { user_course_ids: [pending_uc.id, other_pending.id] } }
      it "updates all to approved" do
        expect(UserCourse.where(id: [pending_uc.id, other_pending.id]).all?(&:approved?)).to be true
      end
      it "sets flash success count message" do
        expect(flash[:success]).to eq(I18n.t("admin.user_courses.approve_selected.approve_selected_success", count: 2))
      end
    end
  end

  describe "POST #reject_selected bulk rejection" do
    context "when selection missing" do
      before { post :reject_selected }
      it "sets flash danger no_selection" do
        expect(flash[:danger]).to eq(I18n.t("admin.user_courses.reject_selected.no_selection"))
      end
    end

    context "when contains invalid statuses" do
      before { post :reject_selected, params: { user_course_ids: [rejected_uc.id] } }
      it "sets flash danger invalid_status_for_reject_error" do
        expect(flash[:danger]).to eq(I18n.t("admin.user_courses.reject_selected.invalid_status_for_reject_error"))
      end
    end

    context "when none rejectable after filtering" do
      before { post :reject_selected, params: { user_course_ids: [completed_uc.id] } }
      it "sets flash warning no_rejectable_courses" do
        expect(flash[:warning]).to eq(I18n.t("admin.user_courses.reject_selected.no_rejectable_courses"))
      end
    end

    context "when valid pending and approved rows" do
      let!(:another_pending) { create(:user_course, course: course, enrolment_status: :pending) }
      before { post :reject_selected, params: { user_course_ids: [pending_uc.id, approved_uc.id, another_pending.id] } }
      it "updates selected to rejected" do
        expect(UserCourse.where(id: [pending_uc.id, approved_uc.id, another_pending.id]).all?(&:rejected?)).to be true
      end
      it "sets flash success with count" do
        expect(flash[:success]).to eq(I18n.t("admin.user_courses.reject_selected.reject_selected_success", count: 3))
      end
    end
  end

  describe "GET #profile viewing user progress" do
    let!(:lesson) { create(:lesson, course: course) }
    before { get :profile, params: { id: approved_uc.id } }
    it "assigns user_course" do
      expect(assigns(:user_course)).to eq(approved_uc)
    end
    it "assigns user" do
      expect(assigns(:user)).to eq(approved_uc.user)
    end
    it "assigns course" do
      expect(assigns(:course)).to eq(course)
    end
    it "assigns lessons collection" do
      expect(assigns(:lessons)).to be_present
    end
    it "assigns test_results collection" do
      expect(assigns(:test_results)).to be_a(ActiveRecord::Relation)
    end
  end

  describe "GET #profile with missing id" do
    before { get :profile, params: { id: -1 } }
    it "sets flash danger user_course_not_found" do
      expect(flash[:danger]).to eq(I18n.t("admin.user_courses.profile.user_course_not_found"))
    end
    it "redirects index" do
      expect(response).to redirect_to(admin_user_courses_path)
    end
  end

  describe "GET #reject_form displaying modal" do
    before do
      allow(controller).to receive(:respond_modal_with)
      get :reject_form, params: { id: pending_uc.id }
    end
    it "calls respond_modal_with" do
      expect(controller).to have_received(:respond_modal_with).with(pending_uc)
    end
  end

  describe "GET #reject_detail displaying modal" do
    before do
      allow(controller).to receive(:respond_modal_with)
      get :reject_detail, params: { id: rejected_uc.id }
    end
    it "calls respond_modal_with detail" do
      expect(controller).to have_received(:respond_modal_with).with(rejected_uc)
    end
  end

  describe "PATCH #approve preserves filter params in redirect" do
    before do
      patch :approve, params: { id: pending_uc.id, status: "pending", course: course.id }
    end
    it "redirect includes filters" do
      expect(response.location).to include("status=pending", "course=#{course.id}")
    end
  end

  describe "PATCH #approve with referer filters when absent in params" do
    before do
      request.env["HTTP_REFERER"] = admin_user_courses_url(status: "approved", course: course.id)
      patch :approve, params: { id: pending_uc.id }
    end
    it "redirect inherits filters from referer" do
      expect(response.location).to include("status=approved", "course=#{course.id}")
    end
  end
end
