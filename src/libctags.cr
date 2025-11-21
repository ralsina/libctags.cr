@[Link(ldflags: "-L#{__DIR__}/../ext/")]
@[Link(ldflags: "#{__DIR__}/../ext/libreadtags.a")]

lib LibCtags
  # Enums
  enum TagSortType
    UNSORTED   = 0
    SORTED     = 1
    FOLDSORTED = 2
  end

  enum TagErrno
    UnexpectedSortedMethod = -1
    UnexpectedFormat       = -2
    UnexpectedLineno       = -3
    InvalidArgument        = -4
    FileMaybeTooBig        = -5
  end

  enum TagResult
    Failure = 0
    Success = 1
  end

  # Structs
  struct TagFileStatus
    opened : Int32
    error_number : Int32
  end

  struct TagFileInfoFile
    format : Int16
    sort : TagSortType
  end

  struct TagFileInfoProgram
    author : UInt8*
    name : UInt8*
    url : UInt8*
    version : UInt8*
  end

  struct TagFileInfo
    status : TagFileStatus
    file : TagFileInfoFile
    program : TagFileInfoProgram
  end

  struct TagExtensionField
    key : UInt8*
    value : UInt8*
  end

  struct TagEntryAddress
    pattern : UInt8*
    line_number : UInt64
  end

  struct TagEntryFields
    count : UInt16
    list : TagExtensionField*
  end

  struct TagEntry
    name : UInt8*
    file : UInt8*
    address : TagEntryAddress
    kind : UInt8*
    file_scope : Int16
    fields : TagEntryFields
  end

  alias TagFile = Void*

  # Function Prototypes
  fun tagsOpen(file_path : UInt8*, info : TagFileInfo*) : TagFile*
  fun tagsSetSortType(file : TagFile*, type : TagSortType) : TagResult
  fun tagsFirst(file : TagFile*, entry : TagEntry*) : TagResult
  fun tagsNext(file : TagFile*, entry : TagEntry*) : TagResult
  fun tagsField(entry : TagEntry*, key : UInt8*) : UInt8*
  fun tagsFind(file : TagFile*, entry : TagEntry*, name : UInt8*, options : Int32) : TagResult
  fun tagsFindNext(file : TagFile*, entry : TagEntry*) : TagResult
  fun tagsFirstPseudoTag(file : TagFile*, entry : TagEntry*) : TagResult
  fun tagsNextPseudoTag(file : TagFile*, entry : TagEntry*) : TagResult
  fun tagsFindPseudoTag(file : TagFile*, entry : TagEntry*, name : UInt8*, match : Int32) : TagResult
  fun tagsClose(file : TagFile*) : TagResult
  fun tagsGetErrno(file : TagFile*) : Int32
end

module Ctags
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  # Options for tagsFind() and tagsFindPseudoTag()
  TAG_FULLMATCH    = 0x0
  TAG_PARTIALMATCH = 0x1
  TAG_OBSERVECASE  = 0x0
  TAG_IGNORECASE   = 0x2

  class File
    def initialize(file_path : String)
      @info = LibCtags::TagFileInfo.new
      @file = LibCtags.tagsOpen(file_path.to_unsafe, pointerof(@info))
      raise "Failed to open tag file: #{error_message}" unless @info.status.opened == 1
    end

    def set_sort_type(type : LibCtags::TagSortType)
      result = LibCtags.tagsSetSortType(@file, type)
      raise "Failed to set sort type" if result == LibCtags::TagResult::Failure
    end

    def first_entry : Entry?
      entry = LibCtags::TagEntry.new
      result = LibCtags.tagsFirst(@file, pointerof(entry))
      result == LibCtags::TagResult::Success ? Entry.new(entry) : nil
    end

    def next_entry : Entry?
      entry = LibCtags::TagEntry.new
      result = LibCtags.tagsNext(@file, pointerof(entry))
      result == LibCtags::TagResult::Success ? Entry.new(entry) : nil
    end

    def find_entry(name : String, options : Int32 = 0) : Entry?
      entry = LibCtags::TagEntry.new
      result = LibCtags.tagsFind(@file, pointerof(entry), name.to_unsafe, options)
      result == LibCtags::TagResult::Success ? Entry.new(entry) : nil
    end

    def find_next_entry : Entry?
      entry = LibCtags::TagEntry.new
      result = LibCtags.tagsFindNext(@file, pointerof(entry))
      result == LibCtags::TagResult::Success ? Entry.new(entry) : nil
    end

    def first_pseudo_tag : Entry?
      entry = LibCtags::TagEntry.new
      result = LibCtags.tagsFirstPseudoTag(@file, pointerof(entry))
      result == LibCtags::TagResult::Success ? Entry.new(entry) : nil
    end

    def next_pseudo_tag : Entry?
      entry = LibCtags::TagEntry.new
      result = LibCtags.tagsNextPseudoTag(@file, pointerof(entry))
      result == LibCtags::TagResult::Success ? Entry.new(entry) : nil
    end

    def find_pseudo_tag(name : String, match : Int32) : Entry?
      entry = LibCtags::TagEntry.new
      result = LibCtags.tagsFindPseudoTag(@file, pointerof(entry), name.to_unsafe, match)
      result == LibCtags::TagResult::Success ? Entry.new(entry) : nil
    end

    def close
      LibCtags.tagsClose(@file)
    end

    private def error_message : String
      case @info.status.error_number
      when LibCtags::TagErrno::UnexpectedSortedMethod
        "Unexpected sorted method"
      when LibCtags::TagErrno::UnexpectedFormat
        "Unexpected format"
      when LibCtags::TagErrno::UnexpectedLineno
        "Unexpected line number"
      when LibCtags::TagErrno::InvalidArgument
        "Invalid argument"
      when LibCtags::TagErrno::FileMaybeTooBig
        "File may be too big"
      else
        "Unknown error"
      end
    end
  end

  class Entry
    def initialize(entry : LibCtags::TagEntry)
      @entry = entry
    end

    def name : String
      String.new(@entry.name)
    end

    def file : String
      String.new(@entry.file)
    end

    def kind : String
      kind_ptr = @entry.kind
      return "" if kind_ptr.null?
      String.new(kind_ptr)
    end

    def line_number : UInt64
      # First try the native line number
      native_line = @entry.address.line_number
      return native_line if native_line > 0

      # If native line number is 0, try to parse from raw fields
      if line_str = get_field_from_raw("line")
        if line_match = line_str.match(/(\d+)/)
          return line_match[1].to_u64
        end
      end

      # If still no line number, try to extract from the pattern
      if pattern = self.pattern
        # Look for line number in extended format patterns
        # Pattern might be: "/^  class Section$/;\"\tline:189"
        if line_match = pattern.match(/line:(\d+)/)
          return line_match[1].to_u64
        end
      end

      0_u64
    end

    # Helper to get a field from raw ctags entry without circular dependencies
    private def get_field_from_raw(key : String) : String?
      count = @entry.fields.count
      list = @entry.fields.list
      count.times do |i|
        field_key = String.new(list[i].key)
        if field_key == key
          return String.new(list[i].value)
        end
      end
      nil
    end

    def pattern : String?
      @entry.address.pattern.null? ? nil : String.new(@entry.address.pattern)
    end

    def fields : Hash(String, String)
      field_hash = Hash(String, String).new
      count = @entry.fields.count
      list = @entry.fields.list
      count.times do |i|
        key = String.new(list[i].key)
        value = String.new(list[i].value)
        field_hash[key] = value
      end
      field_hash
    end
  end
end
