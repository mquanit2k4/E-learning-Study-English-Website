require "rails_helper"

RSpec.describe Test, type: :model do
  subject(:test) { build(:test) }

  describe "constants" do
    it "defines IMAGE_DISPLAY_SIZE correctly" do
      expect(Test::IMAGE_DISPLAY_SIZE).to eq([300, 200])
    end

    it "defines MINIMUM_DURATION correctly" do
      expect(Test::MINIMUM_DURATION).to eq(0)
    end

    it "defines MINIMUM_NAME_LENGTH correctly" do
      expect(Test::MINIMUM_NAME_LENGTH).to eq(3)
    end

    it "defines MAX_NAME_LENGTH correctly" do
      expect(Test::MAX_NAME_LENGTH).to eq(100)
    end

    it "defines MINIMUM_DESCRIPTION_LENGTH correctly" do
      expect(Test::MINIMUM_DESCRIPTION_LENGTH).to eq(10)
    end

    it "defines MAX_DESCRIPTION_LENGTH correctly" do
      expect(Test::MAX_DESCRIPTION_LENGTH).to eq(500)
    end

    it "defines TEST_PERMITTED correctly" do
      expect(Test::TEST_PERMITTED).to eq(%i(name description duration max_attempts))
    end
  end

  describe "associations" do
    it "has many questions with dependent destroy" do
      test = create(:test)
      question = create(:question, test: test)
      expect { test.destroy }.to change { Question.count }.by(-1)
    end

    it "has many components" do
      test = create(:test)
      expect(test.components).to be_empty
    end

    it "can have components associated" do
      test = create(:test)
      expect(test).to respond_to(:components)
    end
  end

  describe "validations" do
    describe "presence validations" do
      context "when name is missing" do
        it "is invalid" do
          test.name = nil
          expect(test).not_to be_valid
        end
      end

      context "when description is missing" do
        it "is invalid" do
          test.description = nil
          expect(test).not_to be_valid
        end
      end

      context "when duration is missing" do
        it "is invalid" do
          test.duration = nil
          expect(test).not_to be_valid
        end
      end

      context "when max_attempts is missing" do
        it "is invalid" do
          test.max_attempts = nil
          expect(test).not_to be_valid
        end
      end
    end

    describe "numericality validations" do
      context "when duration is zero" do
        it "is invalid" do
          test.duration = 0
          expect(test).not_to be_valid
        end
      end

      context "when duration is negative" do
        it "is invalid" do
          test.duration = -1
          expect(test).not_to be_valid
        end
      end

      context "when duration is positive" do
        it "is valid" do
          test.duration = 30
          expect(test).to be_valid
        end
      end

      context "when max_attempts is zero" do
        it "is invalid" do
          test.max_attempts = 0
          expect(test).not_to be_valid
        end
      end

      context "when max_attempts is negative" do
        it "is invalid" do
          test.max_attempts = -1
          expect(test).not_to be_valid
        end
      end

      context "when max_attempts is positive" do
        it "is valid" do
          test.max_attempts = 3
          expect(test).to be_valid
        end
      end
    end

    describe "length validations" do
      context "when name is too short" do
        it "is invalid" do
          test.name = "AB"
          expect(test).not_to be_valid
        end
      end

      context "when name is too long" do
        it "is invalid" do
          test.name = "A" * 101
          expect(test).not_to be_valid
        end
      end

      context "when name length is within range" do
        it "is valid" do
          test.name = "Valid Test Name"
          expect(test).to be_valid
        end
      end

      context "when description is too short" do
        it "is invalid" do
          test.description = "Short"
          expect(test).not_to be_valid
        end
      end

      context "when description is too long" do
        it "is invalid" do
          test.description = "A" * 501
          expect(test).not_to be_valid
        end
      end

      context "when description length is within range" do
        it "is valid" do
          test.description = "This is a valid description that meets the minimum length requirement"
          expect(test).to be_valid
        end
      end
    end
  end

  describe "nested attributes" do
    it "accepts nested attributes for questions with allow_destroy" do
      test = create(:test)
      question_attributes = {
        questions_attributes: [
          {
            content: "What is 2+2?",
            question_type: "multiple_choice",
            answers_attributes: [
              { content: "4", correct: true },
              { content: "5", correct: false }
            ]
          }
        ]
      }

      expect { test.update(question_attributes) }.to change { test.questions.count }.by(1)
    end

    it "allows destroying questions through nested attributes" do
      test = create(:test)
      question = create(:question, test: test)

      destroy_attributes = {
        questions_attributes: [
          { id: question.id, _destroy: "1" }
        ]
      }

      expect { test.update(destroy_attributes) }.to change { test.questions.count }.by(-1)
    end
  end

  describe "scopes" do
    describe ".recent" do
      it "orders tests by created_at in descending order" do
        first_test = create(:test, created_at: 1.day.ago)
        second_test = create(:test, created_at: 2.days.ago)
        third_test = create(:test, created_at: 3.days.ago)

        expect(Test.recent).to eq([first_test, second_test, third_test])
      end
    end

    describe ".by_name" do
      let!(:math_test) { create(:test, name: "Math Test Advanced") }
      let!(:science_test) { create(:test, name: "Science Quiz") }
      let!(:english_test) { create(:test, name: "English Grammar") }

      context "when keyword is provided" do
        it "returns tests matching the keyword" do
          expect(Test.by_name("Math")).to include(math_test)
        end

        it "does not return tests not matching the keyword" do
          expect(Test.by_name("Math")).not_to include(science_test, english_test)
        end

        it "performs case-insensitive search" do
          expect(Test.by_name("MATH")).to include(math_test)
        end

        it "performs partial match search" do
          expect(Test.by_name("Test")).to include(math_test)
        end
      end

      context "when keyword is blank" do
        it "returns all tests with empty string" do
          result = Test.by_name("")
          expect(result).to include(math_test, science_test, english_test)
        end

        it "returns all tests with nil" do
          result = Test.by_name(nil)
          expect(result).to include(math_test, science_test, english_test)
        end

        it "returns all tests with whitespace" do
          result = Test.by_name("   ")
          expect(result).to include(math_test, science_test, english_test)
        end
      end

      context "when no matches found" do
        it "returns empty collection" do
          expect(Test.by_name("NonexistentSubject")).to be_empty
        end
      end
    end
  end

  describe "factory" do
    it "creates valid test with factory" do
      test = build(:test)
      expect(test).to be_valid
    end

    it "persists test successfully" do
      test = create(:test)
      expect(test).to be_persisted
    end

    it "has name attribute" do
      test = create(:test)
      expect(test.name).to be_present
    end

    it "has description attribute" do
      test = create(:test)
      expect(test.description).to be_present
    end

    it "has duration attribute" do
      test = create(:test)
      expect(test.duration).to be_present
    end

    it "has max_attempts attribute" do
      test = create(:test)
      expect(test.max_attempts).to be_present
    end
  end

  describe "edge cases" do
    context "when test has minimum valid name length" do
      it "is valid" do
        test.name = "ABC"
        expect(test).to be_valid
      end
    end

    context "when test has maximum valid name length" do
      it "is valid" do
        test.name = "A" * 100
        expect(test).to be_valid
      end
    end

    context "when test has minimum valid description length" do
      it "is valid" do
        test.description = "A" * 10
        expect(test).to be_valid
      end
    end

    context "when test has maximum valid description length" do
      it "is valid" do
        test.description = "A" * 500
        expect(test).to be_valid
      end
    end

    context "when test has minimum valid duration" do
      it "is valid" do
        test.duration = 1
        expect(test).to be_valid
      end
    end

    context "when test has minimum valid max_attempts" do
      it "is valid" do
        test.max_attempts = 1
        expect(test).to be_valid
      end
    end
  end
end
