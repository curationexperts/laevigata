class EmbargoTypeFromAttributes
  def initialize(files, toc, abstract)
    @files = files
    @toc = toc
    @abstract = abstract
  end

  def s
    embargo_type = [@files, @toc, @abstract]
    case embargo_type
    when ['true', 'false', 'false']
      return 'files_embargoed'
    when ['true', 'true', 'false']
      return 'files_embargoed, toc_embargoed'
    when ['true', 'true', 'true']
      return 'files_embargoed, toc_embargoed, abstract_embargoed'
    end
  end
end
