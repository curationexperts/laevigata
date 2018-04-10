module Hyrax
  # Creates the presenters of the members (member works and file sets) of a specific object
  class EtdMemberPresenterFactory < Hyrax::MemberPresenterFactory
    self.file_presenter_class = EtdFileSetPresenter
  end
end
