class PrimaryFileTitleActor < Hyrax::Actors::AbstractActor
  def update(env)
    update_primary_file_title(env.curation_concern, env.attributes['title'])
    next_actor.update(env)
  end

  # If you change the title of the ETD, the title of
  # the primary PDF should change too.
  def update_primary_file_title(etd, new_title)
    return unless new_title

    old_title = etd.title.to_a
    return if new_title == old_title

    file_set = etd.primary_file_fs.first
    return unless file_set

    file_set.title = new_title
    file_set.save
  end
end
