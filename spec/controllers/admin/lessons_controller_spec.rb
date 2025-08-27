require "rails_helper"

RSpec.describe Admin::LessonsController, type: :controller do
  shared_context "admin authenticated" do
    let(:admin_user) { create(:user, :admin) }
    before { log_in_as admin_user }
  end

  shared_context "course with lessons" do
    let!(:course) { create(:course, creator: admin_user) }
    let!(:lesson1) { create(:lesson, course: course, creator: admin_user, position: 1) }
    let!(:lesson2) { create(:lesson, course: course, creator: admin_user, position: 2) }
  end

  include_context "admin authenticated"
  include_context "course with lessons"

  before do
    allow(Settings.lesson).to receive(:pagy_items).and_return(2)
  end

  describe "GET #index action listing lessons" do
    context "when no filter params provided" do
      before { get :index, params: { course_id: course.id } }
      it "assigns all lessons sorted by position" do
        expect(assigns(:lessons).map(&:id)).to eq([lesson1.id, lesson2.id])
      end
      it "assigns pagy object" do
        expect(assigns(:pagy)).to be_present
      end
      it "returns success status" do
        expect(response).to have_http_status(:success)
      end
    end

    context "when filtering by query content" do
      before { get :index, params: { course_id: course.id, query: lesson1.title.split.first } }
      it "filters lessons containing query" do
        expect(assigns(:lessons)).to include(lesson1)
      end
    end

    context "when course id invalid" do
      before { get :index, params: { course_id: -1 } }
      it "sets flash danger course_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.lessons.index.course_not_found"))
      end
      it "redirects to courses index" do
        expect(response).to redirect_to(admin_courses_path)
      end
    end
  end

  describe "GET #new action building lesson" do
    before { get :new, params: { course_id: course.id } }
    it "assigns new lesson" do
      expect(assigns(:lesson)).to be_a_new(Lesson)
    end
    it "initializes selected_word_ids empty" do
      expect(assigns(:selected_word_ids)).to eq([])
    end
    it "initializes selected_test_ids empty" do
      expect(assigns(:selected_test_ids)).to eq([])
    end
    it "initializes selected_paragraphs empty" do
      expect(assigns(:selected_paragraphs)).to eq([])
    end
  end

  describe "GET #new action with invalid course" do
    before { get :new, params: { course_id: -1 } }
    it "sets flash danger course_not_found" do
      expect(flash[:danger]).to eq(I18n.t("admin.lessons.new.course_not_found"))
    end
    it "redirects to courses index" do
      expect(response).to redirect_to(admin_courses_path)
    end
  end

  describe "POST #create action creating lesson" do
    let(:word) { create(:word) }
    let(:test_model) { create(:test) }
    let(:valid_params) do
      {
        course_id: course.id,
        lesson: {
          title: "New Lesson Title",
          description: "New Lesson Description",
          word_ids: ["", word.id],
          test_ids: ["", test_model.id],
          paragraphs: [{ content: "Paragraph A" }, { content: "Paragraph B" }]
        }
      }
    end

    context "with valid params" do
      before { post :create, params: valid_params }
      it "creates lesson record" do
        expect(Lesson.exists?(title: "New Lesson Title")).to be true
      end
      it "sets flash success" do
        expect(flash[:success]).to eq(I18n.t("admin.lessons.create.success"))
      end
      it "redirects show path" do
        expect(response).to redirect_to(admin_course_lesson_path(course, Lesson.last))
      end
    end

    context "with invalid params missing title" do
      before { post :create, params: { course_id: course.id, lesson: { title: "", description: "" } } }
      it "does not create lesson" do
        expect(Lesson.where(description: "").count).to eq(0)
      end
      it "responds unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it "sets flash danger failure" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.lessons.create.failure"))
      end
    end

    context "with invalid course id" do
      before { post :create, params: valid_params.merge(course_id: -1) }
      it "sets flash danger course_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.lessons.create.course_not_found"))
      end
      it "redirects courses index" do
        expect(response).to redirect_to(admin_courses_path)
      end
    end

    context "with multiple component types for coverage" do
      let(:word1) { create(:word) }
      let(:word2) { create(:word) }
      let(:test_a) { create(:test) }
      let(:complex_params) do
        {
          course_id: course.id,
          lesson: {
            title: "Complex Lesson",
            description: "Complex Description",
            word_ids: ["", word1.id, word2.id],
            test_ids: ["", test_a.id],
            paragraphs: [{ content: "Para1" }, { content: "Para2" }]
          }
        }
      end
      before { post :create, params: complex_params }
      it "creates lesson with combined components count" do
        expect(Lesson.find_by(title: "Complex Lesson").components.count).to eq(5)
      end
    end
  end

  describe "GET #edit action loading lesson" do
    before { get :edit, params: { course_id: course.id, id: lesson1.id } }
    it "assigns lesson" do
      expect(assigns(:lesson)).to eq(lesson1)
    end
    it "preloads selected_word_ids array" do
      expect(assigns(:selected_word_ids)).to be_an(Array)
    end
    it "preloads selected_test_ids array" do
      expect(assigns(:selected_test_ids)).to be_an(Array)
    end
    it "preloads selected_paragraphs array" do
      expect(assigns(:selected_paragraphs)).to be_an(Array)
    end
  end

  describe "GET #edit action with invalid lesson id" do
    before { get :edit, params: { course_id: course.id, id: -1 } }
    it "sets flash danger lesson_not_found" do
      expect(flash[:danger]).to eq(I18n.t("admin.lessons.edit.lesson_not_found"))
    end
    it "redirects to course show" do
      expect(response).to redirect_to(admin_course_path(course))
    end
  end

  describe "PATCH #update action updating lesson" do
    let(:update_params) do
      {
        course_id: course.id,
        id: lesson1.id,
        lesson: { title: "Updated Title", description: "Updated Description", paragraphs: [] }
      }
    end

    context "with valid params" do
      before { patch :update, params: update_params }
      it "updates title attribute" do
        expect(lesson1.reload.title).to eq("Updated Title")
      end
      it "updates description attribute" do
        expect(lesson1.reload.description).to eq("Updated Description")
      end
      it "sets flash success" do
        expect(flash[:success]).to eq(I18n.t("admin.lessons.update.success"))
      end
      it "redirects to show path" do
        expect(response).to redirect_to(admin_course_lesson_path(course, lesson1))
      end
    end

    context "with invalid params blank title" do
      before { patch :update, params: { course_id: course.id, id: lesson1.id, lesson: { title: "", description: "" } } }
      it "does not update title" do
        expect(lesson1.reload.title).not_to eq("")
      end
      it "sets flash danger failure" do
        expect(flash[:danger] || flash.now[:danger]).to eq(I18n.t("admin.lessons.update.failure"))
      end
    end

    context "with invalid course id" do
      before { patch :update, params: update_params.merge(course_id: -1) }
      it "sets flash danger course_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.lessons.update.course_not_found"))
      end
      it "redirects courses index" do
        expect(response).to redirect_to(admin_courses_path)
      end
    end

    context "with invalid lesson id" do
      before { patch :update, params: { course_id: course.id, id: -1, lesson: { title: "X" } } }
      it "sets flash danger lesson_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.lessons.update.lesson_not_found"))
      end
      it "redirects course show" do
        expect(response).to redirect_to(admin_course_path(course))
      end
    end

    context "with component replacement to exercise destroy and insert_all" do
      let!(:existing_component) { lesson1.components.create(component_type: Settings.component_types.paragraph, content: "Old", index_in_lesson: 1) }
      before do
        patch :update, params: { course_id: course.id, id: lesson1.id, lesson: { title: "Updated Title", description: "Updated Description", paragraphs: [{ content: "New Para" }] } }
      end
      it "replaces old components with new set" do
        contents = lesson1.components.paragraph.pluck(:content)
        expect(contents).to eq(["New Para"])
      end
    end
  end

  describe "GET #show action displaying lesson" do
    before { get :show, params: { course_id: course.id, id: lesson1.id } }
    it "assigns lesson" do
      expect(assigns(:lesson)).to eq(lesson1)
    end
  end

  describe "GET #show action with invalid ids" do
    context "when invalid course id" do
      before { get :show, params: { course_id: -1, id: lesson1.id } }
      it "sets flash danger course_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.lessons.show.course_not_found"))
      end
      it "redirects courses index" do
        expect(response).to redirect_to(admin_courses_path)
      end
    end

    context "when invalid lesson id" do
      before { get :show, params: { course_id: course.id, id: -1 } }
      it "sets flash danger lesson_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.lessons.show.lesson_not_found"))
      end
      it "redirects course show" do
        expect(response).to redirect_to(admin_course_path(course))
      end
    end
  end

  describe "DELETE #destroy action deleting lesson" do
    context "when destroy success" do
      before { delete :destroy, params: { course_id: course.id, id: lesson2.id } }
      it "removes lesson record" do
        expect(Lesson.exists?(lesson2.id)).to be false
      end
      it "sets flash success" do
        expect(flash[:success]).to eq(I18n.t("admin.lessons.destroy.success"))
      end
      it "redirects lessons index" do
        expect(response).to redirect_to(admin_course_lessons_path(course))
      end
    end

    context "when destroy fails" do
      before do
        allow_any_instance_of(Lesson).to receive(:destroy).and_return(false)
        delete :destroy, params: { course_id: course.id, id: lesson1.id }
      end
      it "keeps lesson record" do
        expect(Lesson.exists?(lesson1.id)).to be true
      end
      it "sets flash danger failure" do
        expect(flash[:danger]).to eq(I18n.t("admin.lessons.destroy.failure"))
      end
      it "redirects lessons index" do
        expect(response).to redirect_to(admin_course_lessons_path(course))
      end
    end

    context "when invalid course id" do
      before { delete :destroy, params: { course_id: -1, id: lesson1.id } }
      it "sets flash danger course_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.lessons.destroy.course_not_found"))
      end
      it "redirects courses index" do
        expect(response).to redirect_to(admin_courses_path)
      end
    end

    context "when invalid lesson id" do
      before { delete :destroy, params: { course_id: course.id, id: -1 } }
      it "sets flash danger lesson_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.lessons.destroy.lesson_not_found"))
      end
      it "redirects course show" do
        expect(response).to redirect_to(admin_course_path(course))
      end
    end
  end
end
