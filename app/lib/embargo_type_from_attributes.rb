class EmbargoTypeFromAttributes
  def initialize(files, toc, abstract)
    @files = files
    @toc = toc
    @abstract = abstract
  end

  def s
    embargo_type = [@files, @toc, @abstract]
    case embargo_type
    when [true, false, false]
      return 'files_restricted'
    when [true, true, false]
      return 'files_restricted, toc_restricted'
    when [true, true, true]
      return 'files_restricted, toc_restricted, all_restricted'
    end
  end
end
