# Override code from Hyrax::FileSetsController

module FileSetsControllerBehavior
  # Override this method from hyrax, so that we can
  # return a JSON response (instead of redirect) if
  # the user is deleting the FileSet by using the
  # 'Remove' button on the form for editing the ETD.
  def destroy
    parent = curation_concern.parent
    actor.destroy

    respond_to do |format|
      format.html do
        redirect_to [main_app, parent], notice: 'The file has been deleted.'
      end

      # TODO: If 'actor.destroy' is false, return an error message.
      format.json do
        render json: { status: '200' }
      end
    end
  end
end
