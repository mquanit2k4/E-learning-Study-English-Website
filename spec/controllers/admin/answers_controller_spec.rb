require "rails_helper"

RSpec.describe Admin::AnswersController, type: :controller do
  render_views false

  shared_context "admin authenticated" do
    let(:admin_user) { create(:user, :admin) }
    before { log_in_as admin_user }
  end

  shared_context "test-question-answer data" do
    let!(:test_record) { create(:test) }
    let!(:question) { create(:question, test: test_record) }
    let!(:answer) { create(:answer, question: question, correct: true) }
  end

  include_context "admin authenticated"

  before do
    # Prevent missing partial errors; controller logic already sets instance vars
    allow(controller).to receive(:render).and_call_original
    allow(controller).to receive(:render).with(hash_including(partial: "answers/form")) do
      controller.response_body = ""
    end
  end

  describe "GET #new when test/question exist" do
    include_context "test-question-answer data"
    before { get :new, params: { test_id: test_record.id, question_id: question.id }, xhr: true }
    it "assigns @answer new record" do
      expect(assigns(:answer)).to be_a_new(Answer)
    end
    it "assigns @test" do
      expect(assigns(:test)).to eq(test_record)
    end
    it "assigns @question" do
      expect(assigns(:question)).to eq(question)
    end
    it "responds success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new when test missing" do
    before { get :new, params: { test_id: -1, question_id: 0 } }
    it "sets flash error I18n" do
      expect(flash[:error]).to eq(I18n.t("admin.answers.new.test_not_found"))
    end
    it "redirects to tests index" do
      expect(response).to redirect_to(admin_tests_path)
    end
  end

  describe "GET #new when question missing" do
    let!(:test_record) { create(:test) }
    before { get :new, params: { test_id: test_record.id, question_id: -1 } }
    it "sets flash error question_not_found" do
      expect(flash[:error]).to eq(I18n.t("admin.answers.new.question_not_found"))
    end
    it "redirects to test show" do
      expect(response).to redirect_to(admin_test_path(test_record))
    end
  end

  describe "POST #create with valid params" do
    include_context "test-question-answer data"
    let(:params_answer) { { content: "New Answer", correct: false } }
    before do
      @previous_count = question.answers.count
      post :create, params: { test_id: test_record.id, question_id: question.id, answer: params_answer }
    end
    it "increments answers count" do
      expect(question.answers.count).to eq(@previous_count + 1)
    end
    it "creates answer with content" do
      expect(Answer.exists?(question: question, content: "New Answer", correct: false)).to be true
    end
    it "creates answer with correct flag" do
      expect(Answer.where(question: question, content: "New Answer").pluck(:correct)).to eq([false])
    end
    it "sets flash success" do
      expect(flash[:success]).to eq(I18n.t("admin.answers.create.create.success"))
    end
    it "redirects to question show" do
      expect(response).to redirect_to(admin_test_question_path(test_record, question))
    end
  end

  describe "POST #create with invalid params" do
    include_context "test-question-answer data"
    before do
      @previous_count = question.answers.count
      post :create, params: { test_id: test_record.id, question_id: question.id, answer: { content: "" } }
    end
    it "does not create answer" do
      expect(question.answers.count).to eq(@previous_count)
    end
    it "sets flash error" do
      expect(flash[:error]).to eq(I18n.t("admin.answers.create.create.failure"))
    end
    it "redirects back" do
      expect(response).to redirect_to(admin_test_question_path(test_record, question))
    end
  end

  describe "POST #create when test missing" do
    before { post :create, params: { test_id: -1, question_id: -1, answer: { content: "X" } } }
    it "sets flash error test_not_found" do
      expect(flash[:error]).to eq(I18n.t("admin.answers.create.test_not_found"))
    end
    it "redirects tests index" do
      expect(response).to redirect_to(admin_tests_path)
    end
  end

  describe "POST #create when question missing" do
    let!(:test_record) { create(:test) }
    before { post :create, params: { test_id: test_record.id, question_id: -1, answer: { content: "X" } } }
    it "sets flash error question_not_found" do
      expect(flash[:error]).to eq(I18n.t("admin.answers.create.question_not_found"))
    end
    it "redirects test show" do
      expect(response).to redirect_to(admin_test_path(test_record))
    end
  end

  describe "DELETE #destroy success" do
    include_context "test-question-answer data"
    before { delete :destroy, params: { test_id: test_record.id, question_id: question.id, id: answer.id } }
    it "destroys answer" do
      expect(Answer.exists?(answer.id)).to be false
    end
    it "sets flash success" do
      expect(flash[:success]).to eq(I18n.t("admin.answers.destroy.destroy.success"))
    end
    it "redirects back" do
      expect(response).to redirect_to(admin_test_question_path(test_record, question))
    end
  end

  describe "DELETE #destroy when destroy fails" do
    include_context "test-question-answer data"
    before do
      allow_any_instance_of(Answer).to receive(:destroy).and_return(false)
      delete :destroy, params: { test_id: test_record.id, question_id: question.id, id: answer.id }
    end
    it "keeps answer" do
      expect(Answer.exists?(answer.id)).to be true
    end
    it "sets flash error" do
      expect(flash[:error]).to eq(I18n.t("admin.answers.destroy.destroy.failure"))
    end
    it "redirects back" do
      expect(response).to redirect_to(admin_test_question_path(test_record, question))
    end
  end

  describe "DELETE #destroy when test missing" do
    before { delete :destroy, params: { test_id: -1, question_id: -1, id: -1 } }
    it "sets flash error test_not_found" do
      expect(flash[:error]).to eq(I18n.t("admin.answers.destroy.test_not_found"))
    end
    it "redirects tests index" do
      expect(response).to redirect_to(admin_tests_path)
    end
  end

  describe "DELETE #destroy when question missing" do
    let!(:test_record) { create(:test) }
    before { delete :destroy, params: { test_id: test_record.id, question_id: -1, id: -1 } }
    it "sets flash error question_not_found" do
      expect(flash[:error]).to eq(I18n.t("admin.answers.destroy.question_not_found"))
    end
    it "redirects test show" do
      expect(response).to redirect_to(admin_test_path(test_record))
    end
  end

  describe "DELETE #destroy when answer missing" do
    include_context "test-question-answer data"
    before { delete :destroy, params: { test_id: test_record.id, question_id: question.id, id: -1 } }
    it "sets flash error answer_not_found" do
      expect(flash[:error]).to eq(I18n.t("admin.answers.destroy.answer_not_found"))
    end
    it "redirects back" do
      expect(response).to redirect_to(admin_test_question_path(test_record, question))
    end
  end
end
