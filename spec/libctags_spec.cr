require "./spec_helper"

describe Ctags do
  it "has a version number" do
    Ctags::VERSION.should_not be_nil
  end

  describe "File" do
    it "can be initialized with a file path" do
      file = Ctags::File.new("spec/fixtures/tags")
      file.should_not be_nil
      file.close
    end

    it "can set the sort type" do
      file = Ctags::File.new("spec/fixtures/tags")
      file.set_sort_type(LibCtags::TagSortType::SORTED)
      file.close
    end

    it "can find the first entry" do
      file = Ctags::File.new("spec/fixtures/tags")
      entry = file.first_entry
      entry.should_not be_nil
      entry.as(Ctags::Entry).name.should eq("EmptyString")
      file.close
    end

    it "can find the next entry" do
      file = Ctags::File.new("spec/fixtures/tags")
      file.first_entry
      next_entry = file.next_entry
      next_entry.should_not be_nil
      next_entry.as(Ctags::Entry).name.should eq("JUMP_BACK")
      file.close
    end

    it "can find an entry by name" do
      file = Ctags::File.new("spec/fixtures/tags")
      entry = file.find_entry("tagsOpen")
      entry.should_not be_nil
      entry.as(Ctags::Entry).name.should eq("tagsOpen")
      entry.as(Ctags::Entry).line_number.should eq(1290)
      file.close
    end
  end
end
