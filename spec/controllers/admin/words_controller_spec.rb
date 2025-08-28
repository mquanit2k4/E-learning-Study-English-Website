require "rails_helper"

RSpec.describe Admin::WordsController, type: :controller do
  shared_context "admin authentication" do
    let(:admin_user) { create(:user, :admin) }
    before { log_in_as admin_user }
  end

  shared_context "word test data" do
    let!(:word1) { create(:word, content: "apple", meaning: "A red fruit", word_type: "noun") }
    let!(:word2) { create(:word, content: "run", meaning: "To move fast", word_type: "verb") }
    let!(:word3) { create(:word, content: "beautiful", meaning: "Good looking", word_type: "adjective") }
  end

  include_context "admin authentication"

  describe "GET #index listing words" do
    include_context "word test data"

    context "when displaying all words without filters" do
      before { get :index }
      it "assigns non empty words collection" do
        expect(assigns(:words)).to be_present
      end
      it "responds with success status" do
        expect(response).to have_http_status(:success)
      end
      it "renders index template" do
        expect(response).to render_template(:index)
      end
      it "assigns pagy pagination object" do
        expect(assigns(:pagy)).to be_present
      end
    end

    context "when searching by content query" do
      before { get :index, params: { query: "apple" } }
      it "assigns filtered words collection present" do
        expect(assigns(:words)).to be_present
      end
      it "includes searched content in results" do
        expect(assigns(:words).pluck(:content)).to include("apple")
      end
      it "responds success for search" do
        expect(response).to have_http_status(:success)
      end
    end

    context "when filtering by time today" do
      before do
        allow(Settings.filter_days).to receive(:today).and_return("today")
        get :index, params: { filter_time: "today" }
      end
      it "applies time filter to collection present" do
        expect(assigns(:words)).to be_present
      end
      it "responds success for time filter" do
        expect(response).to have_http_status(:success)
      end
    end

    context "when paginating with multiple pages" do
      before do
        # create extra records beyond default page size (10) to force pagination
        create_list(:word, Settings.word.pagy_items + 5)
        get :index, params: { page: 1 }
        @expected_first_page_ids = Word.order(created_at: :desc).limit(Settings.word.pagy_items).pluck(:id)
      end
      it "assigns page number 1" do
        expect(assigns(:pagy).page).to eq(1)
      end
      it "limits items to configured per page size" do
        expect(assigns(:words).size).to eq(Settings.word.pagy_items)
      end
      it "sets total count equal to words count" do
        expect(assigns(:pagy).count).to eq(Word.count)
      end
      it "lists correct first page word ids in order" do
        expect(assigns(:words).pluck(:id)).to eq(@expected_first_page_ids)
      end
    end

    context "when searching with empty query returns all" do
      before { get :index, params: { query: "" } }
      it "returns full words count from dataset" do
        expect(assigns(:words).count).to eq(3)
      end
    end
  end

  describe "GET #new displaying form" do
    context "when accessing new word form as admin" do
      before { get :new }
      it "assigns new word instance" do
        expect(assigns(:word)).to be_a_new(Word)
      end
      it "responds success for new form" do
        expect(response).to have_http_status(:success)
      end
      it "renders new template view" do
        expect(response).to render_template(:new)
      end
    end
  end

  describe "POST #create creating word" do
    context "with valid word parameters saves record" do
      let(:valid_params) { { content: "test", meaning: "a test word", word_type: "noun" } }
      it "increments word count by one" do
        expect { post :create, params: { word: valid_params } }.to change(Word, :count).by(1)
      end
      it "persists content attribute" do
        post :create, params: { word: valid_params }
        expect(Word.last.content).to eq("test")
      end
      it "persists meaning attribute" do
        post :create, params: { word: valid_params }
        expect(Word.last.meaning).to eq("a test word")
      end
      it "persists word_type attribute" do
        post :create, params: { word: valid_params }
        expect(Word.last.word_type).to eq("noun")
      end
      it "sets success flash i18n message" do
        post :create, params: { word: valid_params }
        expect(flash[:success]).to eq(I18n.t("admin.words.create.success"))
      end
      it "redirects to words index after create" do
        post :create, params: { word: valid_params }
        expect(response).to redirect_to(admin_words_path)
      end
    end

    context "with invalid word parameters re-renders" do
      let(:invalid_params) { { content: "", meaning: "", word_type: "noun" } }
      it "does not change word count" do
        expect { post :create, params: { word: invalid_params } }.not_to change(Word, :count)
      end
      it "renders new template on failure" do
        post :create, params: { word: invalid_params }
        expect(response).to render_template(:new)
      end
      it "returns unprocessable entity status code" do
        post :create, params: { word: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it "assigns errored word instance present" do
        post :create, params: { word: invalid_params }
        expect(assigns(:word)).to be_present
      end
      it "populates errors on word instance" do
        post :create, params: { word: invalid_params }
        expect(assigns(:word).errors).to be_present
      end
    end

    context "with unpermitted parameters ignored" do
      let(:params_with_extra) { { content: "test", meaning: "test meaning", word_type: "noun", malicious_param: "ignored" } }
      it "does not expose forbidden attribute on model" do
        post :create, params: { word: params_with_extra }
        expect(Word.last).not_to respond_to(:malicious_param)
      end
    end
  end

  describe "GET #edit editing word" do
    let!(:word) { create(:word) }
    context "when editing existing word loads successfully" do
      before { get :edit, params: { id: word.id } }
      it "assigns existing word to @word" do
        expect(assigns(:word)).to eq(word)
      end
      it "responds success for edit form" do
        expect(response).to have_http_status(:success)
      end
      it "renders edit template view" do
        expect(response).to render_template(:edit)
      end
    end

    context "when word is not found by id -1" do
      before { get :edit, params: { id: -1 } }
      it "sets danger flash not_found" do
        expect(flash[:danger]).to eq(I18n.t("not_found"))
      end
      it "redirects to words index on missing" do
        expect(response).to redirect_to(admin_words_path)
      end
    end
  end

  describe "PATCH #update updating word" do
    let!(:word) { create(:word, content: "old", meaning: "old meaning", word_type: "noun") }

    context "with valid update parameters succeeds" do
      let(:valid_update_params) { { content: "updated", meaning: "updated meaning", word_type: "verb" } }
      it "updates content field" do
        patch :update, params: { id: word.id, word: valid_update_params }
        expect(word.reload.content).to eq("updated")
      end
      it "updates meaning field" do
        patch :update, params: { id: word.id, word: valid_update_params }
        expect(word.reload.meaning).to eq("updated meaning")
      end
      it "updates word_type field" do
        patch :update, params: { id: word.id, word: valid_update_params }
        expect(word.reload.word_type).to eq("verb")
      end
      it "sets success flash after update" do
        patch :update, params: { id: word.id, word: valid_update_params }
        expect(flash[:success]).to eq(I18n.t("admin.words.update.success"))
      end
      it "redirects to words index after update" do
        patch :update, params: { id: word.id, word: valid_update_params }
        expect(response).to redirect_to(admin_words_path)
      end
    end

    context "with invalid update parameters fails" do
      let(:invalid_update_params) { { content: "", meaning: "", word_type: "noun" } }
      it "does not change content on failure" do
        patch :update, params: { id: word.id, word: invalid_update_params }
        expect(word.reload.content).to eq("old")
      end
      it "does not change meaning on failure" do
        patch :update, params: { id: word.id, word: invalid_update_params }
        expect(word.reload.meaning).to eq("old meaning")
      end
      it "renders edit template for invalid update" do
        patch :update, params: { id: word.id, word: invalid_update_params }
        expect(response).to render_template(:edit)
      end
      it "returns unprocessable entity for invalid update" do
        patch :update, params: { id: word.id, word: invalid_update_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when word is not found using id -1" do
      before { patch :update, params: { id: -1, word: { content: "test" } } }
      it "sets danger flash not_found on update missing" do
        expect(flash[:danger]).to eq(I18n.t("not_found"))
      end
      it "redirects to index when update target missing" do
        expect(response).to redirect_to(admin_words_path)
      end
    end
  end

  describe "DELETE #destroy removing word" do
    let!(:word) { create(:word, content: "test word") }

    context "when destroy is successful" do
      it "decrements word count by one" do
        expect { delete :destroy, params: { id: word.id } }.to change(Word, :count).by(-1)
      end
      it "sets success flash with word content" do
        delete :destroy, params: { id: word.id }
        expect(flash[:success]).to eq(I18n.t("admin.words.destroy.success", word_content: "test word"))
      end
      it "redirects to words index after destroy" do
        delete :destroy, params: { id: word.id }
        expect(response).to redirect_to(admin_words_path)
      end
    end

    context "when destroy fails returning false" do
      before { allow_any_instance_of(Word).to receive(:destroy).and_return(false) }
      it "does not change word count on failure" do
        expect { delete :destroy, params: { id: word.id } }.not_to change(Word, :count)
      end
      it "sets danger flash failure message" do
        delete :destroy, params: { id: word.id }
        expect(flash[:danger]).to eq(I18n.t("admin.words.destroy.failure", word_content: "test word"))
      end
      it "redirects to index after failed destroy" do
        delete :destroy, params: { id: word.id }
        expect(response).to redirect_to(admin_words_path)
      end
    end

    context "when word not found for destroy id -1" do
      before { delete :destroy, params: { id: -1 } }
      it "sets danger flash not_found on destroy" do
        expect(flash[:danger]).to eq(I18n.t("not_found"))
      end
      it "redirects to index when destroy target missing" do
        expect(response).to redirect_to(admin_words_path)
      end
    end
  end

  describe "private methods behavior" do
    describe "#set_word before_action" do
      context "when word exists set instance variable" do
        let!(:word) { create(:word) }
        it "assigns word via edit action" do
          get :edit, params: { id: word.id }
          expect(assigns(:word)).to eq(word)
        end
      end

      context "when word missing triggers redirect" do
        it "sets flash danger not_found for edit" do
          get :edit, params: { id: -1 }
          expect(flash[:danger]).to eq(I18n.t("not_found"))
        end
        it "redirects to index on missing word in before_action" do
          get :edit, params: { id: -1 }
          expect(response).to redirect_to(admin_words_path)
        end
      end
    end

    describe "#word_params strong parameters" do
      it "permits only allowed parameters ignoring forbidden" do
        post :create, params: { word: { content: "test", meaning: "test", word_type: "noun", forbidden: "ignored" } }
        expect(Word.last).not_to respond_to(:forbidden)
      end
    end
  end

  describe "authorization and access control" do
    context "when user is not admin accessing controller" do
      let(:regular_user) { create(:user, :user_role) }
      before do
        log_out
        log_in_as regular_user
      end
      it "redirects non admin index access" do
        get :index
        expect(response).to be_redirect
      end
      it "redirects non admin new access" do
        get :new
        expect(response).to be_redirect
      end
      it "redirects non admin create access" do
        post :create, params: { word: { content: "test" } }
        expect(response).to be_redirect
      end
    end

    context "when user is not authenticated access blocked" do
      before { log_out }
      it "redirects unauthenticated index request" do
        get :index
        expect(response).to be_redirect
      end
      it "redirects unauthenticated create request" do
        post :create, params: { word: { content: "test" } }
        expect(response).to be_redirect
      end
    end
  end
end
