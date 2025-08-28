require "rails_helper"

RSpec.describe Admin::QuestionsController, type: :controller do
  shared_context "admin login" do
    let(:admin_user) { create(:user, :admin) }
    before { log_in_as admin_user }
  end

  shared_context "test with questions" do
    let!(:test_record) { create(:test) }
    let!(:question) { create(:question, test: test_record) }
  end

  include_context "admin login"
  include_context "test with questions"

  describe "GET #new building question" do
    before do
      allow(Settings.question).to receive(:answer_defaults_number).and_return(2)
      get :new, params: { test_id: test_record.id }
    end
    it "assigns new single_choice question" do
      expect(assigns(:question).single_choice?).to be true
    end
    it "builds default answers count" do
      expect(assigns(:question).answers.size).to eq(2)
    end
  end

  describe "GET #new with missing test" do
    before { get :new, params: { test_id: -1 } }
    it "sets flash danger test_not_found" do
      expect(flash[:danger]).to eq(I18n.t("admin.questions.new.test_not_found"))
    end
    it "redirects tests index" do
      expect(response).to redirect_to(admin_tests_path)
    end
  end

  describe "POST #create creating question" do
    let(:valid_params) do
      {
        test_id: test_record.id,
        question: {
          content: "New Q?",
          question_type: "single_choice",
          answers_attributes: {
            "0" => { content: "A", correct: "1" },
            "1" => { content: "B", correct: "0" }
          }
        }
      }
    end

    context "with valid params" do
      before { post :create, params: valid_params }
      it "creates question record" do
        expect(Test.find(test_record.id).questions.exists?(content: "New Q?")).to be true
      end
      it "sets flash success" do
        expect(flash[:success]).to eq(I18n.t("admin.questions.create.success"))
      end
      it "redirects test show" do
        expect(response).to redirect_to(admin_test_path(test_record))
      end
    end

    context "with invalid params missing content" do
      before { post :create, params: valid_params.deep_merge(question: { content: "" }) }
      it "does not create question" do
        expect(Test.find(test_record.id).questions.where(content: "").count).to eq(0)
      end
      it "sets flash danger failure" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.questions.create.failure"))
      end
      it "returns unprocessable status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with test not found" do
      before { post :create, params: valid_params.merge(test_id: -1) }
      it "sets flash danger test_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.questions.create.test_not_found"))
      end
      it "redirects tests index" do
        expect(response).to redirect_to(admin_tests_path)
      end
    end
  end

  describe "GET #edit editing question" do
    before { get :edit, params: { test_id: test_record.id, id: question.id } }
    it "assigns question" do
      expect(assigns(:question)).to eq(question)
    end
  end

  describe "GET #edit with missing question" do
    before { get :edit, params: { test_id: test_record.id, id: -1 } }
    it "sets flash danger question_not_found" do
      expect(flash[:danger]).to eq(I18n.t("admin.questions.edit.question_not_found"))
    end
    it "redirects test show" do
      expect(response).to redirect_to(admin_test_path(test_record))
    end
  end

  describe "GET #edit with missing test" do
    before { get :edit, params: { test_id: -1, id: question.id } }
    it "sets flash danger test_not_found" do
      expect(flash[:danger]).to eq(I18n.t("admin.questions.edit.test_not_found"))
    end
    it "redirects tests index" do
      expect(response).to redirect_to(admin_tests_path)
    end
  end

  describe "PATCH #update updating question" do
    let(:update_params) do
      {
        test_id: test_record.id,
        id: question.id,
        question: { content: "Updated Content", question_type: question.question_type, answers_attributes: { "0" => { id: question.answers.first.id, content: "New Ans", correct: "1" } } }
      }
    end

    context "with valid params" do
      before { patch :update, params: update_params }
      it "updates content attribute" do
        expect(question.reload.content).to eq("Updated Content")
      end
      it "sets flash success" do
        expect(flash[:success]).to eq(I18n.t("admin.questions.update.success"))
      end
      it "redirects test show" do
        expect(response).to redirect_to(admin_test_path(test_record))
      end
    end

    context "with invalid params blank content" do
      before { patch :update, params: update_params.deep_merge(question: { content: "" }) }
      it "does not update content" do
        expect(question.reload.content).not_to eq("")
      end
      it "sets flash danger failure" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.questions.update.failure"))
      end
      it "returns unprocessable status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with missing question id" do
      before { patch :update, params: update_params.merge(id: -1) }
      it "sets flash danger question_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.questions.update.question_not_found"))
      end
      it "redirects test show" do
        expect(response).to redirect_to(admin_test_path(test_record))
      end
    end

    context "with missing test id" do
      before { patch :update, params: update_params.merge(test_id: -1) }
      it "sets flash danger test_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.questions.update.test_not_found"))
      end
      it "redirects tests index" do
        expect(response).to redirect_to(admin_tests_path)
      end
    end
  end

  describe "DELETE #destroy deleting question" do
    context "when destroy success" do
      before { delete :destroy, params: { test_id: test_record.id, id: question.id } }
      it "removes question" do
        expect(Question.exists?(question.id)).to be false
      end
      it "sets flash success" do
        expect(flash[:success]).to eq(I18n.t("admin.questions.destroy.success"))
      end
      it "redirects test show" do
        expect(response).to redirect_to(admin_test_path(test_record))
      end
    end

    context "when destroy fails" do
      before do
        allow_any_instance_of(Question).to receive(:destroy).and_return(false)
        delete :destroy, params: { test_id: test_record.id, id: question.id }
      end
      it "keeps question" do
        expect(Question.exists?(question.id)).to be true
      end
      it "sets flash danger failure" do
        expect(flash[:danger]).to eq(I18n.t("admin.questions.destroy.failure"))
      end
      it "redirects test show" do
        expect(response).to redirect_to(admin_test_path(test_record))
      end
    end

    context "with missing question id" do
      before { delete :destroy, params: { test_id: test_record.id, id: -1 } }
      it "sets flash danger question_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.questions.destroy.question_not_found"))
      end
      it "redirects test show" do
        expect(response).to redirect_to(admin_test_path(test_record))
      end
    end

    context "with missing test id" do
      before { delete :destroy, params: { test_id: -1, id: question.id } }
      it "sets flash danger test_not_found" do
        expect(flash[:danger]).to eq(I18n.t("admin.questions.destroy.test_not_found"))
      end
      it "redirects tests index" do
        expect(response).to redirect_to(admin_tests_path)
      end
    end
  end
end
