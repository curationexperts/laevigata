# LAEVIGATA EMBARGOES

## Embargoes in Laevigata do not follow the normal Hyrax / Samvera pattern


<!-- TODO: Remove this comment - Max, 3/15/2021-->

Although Laevigata makes use of `hydra-access-controls` and uses the `Embargoable` module, its behavior departs significantly from the usual pattern.

In Laevigata the expected embargo behavior is:
1. A depositing user can embargo only parts of their work. Specifically, they can choose to embargo:
  * Files
  * Files and Table of Contents
  * Files, Table of Contents, and Abstract

  These choices are recorded in the `Etd` model as single-value true / false fields:
  * `files_embargoed`
  * `toc_embargoed`
  * `abstract_embargoed`

  These correspond to three custom Etd visibility values for use with items under embargo:
  * `"all_restricted"`: when an embargo is active and `#abstract_embargoed` is `true`
  * `"toc_restricted"`: when an embargo is active, `#toc_embargoed` is `true`, but  `#abstract_embargoed` is `false`
  * `"files_restricted"`: when an embargo is active, but `#toc_embargoed` and  `#abstract_embargoed` are both `false`

1. A depositing user can choose the length of time of embargo, within certain parameters defined by their school. Laney Graduate School allows embargoes of up to 6 years. All schools and departments (including Laney) allow embargoes of 6 months, 1 year, and 2 years. This value is recorded in the `embargo_length` field.

1. The time specified in the `embargo_length` does not begin until the student has graduated. So, given an embargo length of 6 months, the embargo should end *not* 6 months after the work was deposited, but instead 6 months after the student's graduation. However, at deposit time, we do not know when a student will graduate. Therefore, at the time of deposit, we create an Embargo object and set the expiration date to a placeholder value of `Time.zone.today + 6.years`. This happens in `Hyrax::Actors::PregradEmbargo`, which modifies the attributes passed to `Hyrax::Actors::InterpretVisibilityActor`.

1. An automated job will later run, which will check for a student's graduation. Upon graduation, the work will be released for viewing, and the work's `embargo_release_date` will be re-set to `Time.zone.today + embargo_length`

1. Hyrax runs automated jobs to check for the expiration of an embargo, and remove it automatically when the date has been reached. We also plan to send out automated alerts telling people when their embargo is about to expire.

1. During embargo, a record is visible to the public. This is another departure from expected `Embargoable` behavior. The work's `visibility` will be set as described above, in contrast to setting it to `restricted`, which would be the usual pattern. Instead, `etd_presenter` and the relevant views check for the existence of an embargo and the authorization of the current user, and display embargoed fields accordingly.

1. Embargo of files is derived from Etd visibility through `Hyrax::Actors::FileVisibilityAttributesActor`. This ensures that `FileSet` permissions (and e.g. download access) are maintained on files as ACLs, independent of our specific application logic.

Resources:

* An explanation of how Samvera generally expects embargoes to work: https://github.com/samvera/hydra-head/wiki/Embargos-and-Leases
* Docs for Embargoable, the module that is mixed in to provide our Embargo objects: http://www.rubydoc.info/gems/hydra-access-controls/9.0.0/Hydra/AccessControls/Embargoable
* Code for `hydra-access-controls`, the gem where `Embargoable` lives: https://github.com/samvera/hydra-head/tree/master/hydra-access-controls
