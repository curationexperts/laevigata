class EtdPermissionBadge < Hyrax::PermissionBadge
  VISIBILITY_LABEL_CLASS = {
    authenticated: "label-info",
    embargo: "label-warning",
    lease: "label-warning",
    files_restricted: "label-warning",
    toc_restricted: "label-warning",
    all_restricted: "label-warning",
    open: "label-success",
    restricted: "label-danger"
  }.freeze

  def initialize(visibility)
    @visibility = visibility.to_sym
  end

  private

    def dom_label_class
      VISIBILITY_LABEL_CLASS.fetch(@visibility)
    end
end
