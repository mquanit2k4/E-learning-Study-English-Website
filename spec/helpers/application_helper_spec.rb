require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "#full_title" do
    context "when page_title is provided" do
      it "returns page title with base title" do
        expect(helper.full_title("Test Page")).to eq("Test Page | E-Learning System")
      end
    end

    context "when page_title is empty" do
      it "returns only base title" do
        expect(helper.full_title("")).to eq("E-Learning System")
        expect(helper.full_title(nil)).to eq("E-Learning System")
      end
    end
  end

  describe "#flash_class" do
    it "returns correct CSS classes for flash types" do
      expect(helper.flash_class("success")).to eq("alert alert-success")
      expect(helper.flash_class("danger")).to eq("alert alert-danger")
      expect(helper.flash_class("warning")).to eq("alert alert-warning")
      expect(helper.flash_class("info")).to eq("alert alert-info")
      expect(helper.flash_class("unknown")).to eq("alert alert-info")
    end
  end

  describe "#current_page_class" do
    before do
      allow(helper).to receive(:current_page?).and_return(false)
    end

    context "when on current page" do
      it "returns active class" do
        allow(helper).to receive(:current_page?).with("/test").and_return(true)
        expect(helper.current_page_class("/test")).to eq("active")
      end
    end

    context "when not on current page" do
      it "returns empty string" do
        expect(helper.current_page_class("/test")).to eq("")
      end
    end
  end

  describe "#format_date" do
    let(:date) { Time.zone.parse("2023-12-25 10:30:00") }

    context "with default format" do
      it "formats date correctly" do
        expect(helper.format_date(date)).to eq(date.strftime("%B %d, %Y"))
      end
    end

    context "with custom format" do
      it "formats date with custom format" do
        expect(helper.format_date(date, "%Y-%m-%d")).to eq("2023-12-25")
      end
    end

    context "with nil date" do
      it "returns empty string" do
        expect(helper.format_date(nil)).to eq("")
      end
    end
  end

  describe "#truncate_words" do
    let(:long_text) { "This is a very long text that should be truncated after certain number of words" }

    context "with text shorter than limit" do
      it "returns original text" do
        expect(helper.truncate_words("Short text", 10)).to eq("Short text")
      end
    end

    context "with text longer than limit" do
      it "truncates text and adds ellipsis" do
        result = helper.truncate_words(long_text, 5)
        expect(result).to eq("This is a very long...")
      end
    end

    context "with custom separator" do
      it "uses custom separator" do
        result = helper.truncate_words(long_text, 5, " [more]")
        expect(result).to eq("This is a very long [more]")
      end
    end
  end

  describe "#gravatar_url" do
    let(:email) { "test@example.com" }

    it "generates correct gravatar URL" do
      expected_hash = Digest::MD5.hexdigest(email.downcase)
      expected_url = "https://www.gravatar.com/avatar/#{expected_hash}?s=80&d=identicon"
      expect(helper.gravatar_url(email)).to eq(expected_url)
    end

    context "with custom size" do
      it "uses custom size" do
        expected_hash = Digest::MD5.hexdigest(email.downcase)
        expected_url = "https://www.gravatar.com/avatar/#{expected_hash}?s=120&d=identicon"
        expect(helper.gravatar_url(email, 120)).to eq(expected_url)
      end
    end
  end
end
