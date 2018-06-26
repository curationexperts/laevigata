export const formSchema = {
  tabs: {
    about_me: {
      label: "About Me",
      selected: true,
      inputs: {
        creator: { label: "Student Name", value: [] },
        graduation_date: { label: "Graduation Date", value: [] },
        school: { label: "School", value: [] },
        post_graduation_email: { label: "Post-Graduation Email", value: [] }
      }
    },
    my_program: {
      label: "My Program",
      selected: false,
      inputs: {
        department: { label: "Department", value: [] },
        partnering_agency: { label: "Partnering Agency", value: [] },
        subfield: { label: "subfield", value: [] },
        degree: { label: "Degree", value: [] },
        submitting_type: { label: "Submitting Type", value: [] }
      }
    },
    my_advisor: {
      label: "My Advisor",
      selected: false,
      inputs: {
        committee_chair: { label: "Committee Chair", value: [] },
        committee_members: { label: "Committee Members", value: [] }
      }
    },
    my_etd: {
      label: "My Etd",
      selected: false,
      inputs: {
        title: { label: "Title", value: [] },
        language: { label: "Language", value: [] },
        abstract: { label: "Abstract", value: [] },
        table_of_contents: { label: "Table of Contents", value: [] }
      }
    },
    keywords: {
      label: "Keywords",
      selected: false,
      inputs: {
        research_field: { label: "Research Field", value: [] },
        keyword: { label: "Keywork", value: [] },
        copyright_question_one: {
          label: "Copyright Question One",
          value: []
        },
        copyright_question_two: {
          label: "Copyright Question Two",
          value: []
        },
        copyright_question_three: {
          label: "Copright Question Three",
          value: []
        }
      }
    },
    my_files: {
      label: "My Files",
      selected: false,
      inputs: {
        representative_id: { label: "representative_id", value: [] },
        thumbnail_id: { label: "thumbnail_id", value: [] },
        rendering_ids: { label: "rendering_ids", value: [] },
        files: { label: "files", value: [] }
      }
    },
    embargo: {
      label: "Embargo",
      selected: false,
      inputs: {
        visibility_during_embargo: {
          label: "visibility_during_embargo",
          value: []
        },
        embargo_release_date: { label: "embargo_release_date", value: [] },
        visibility_after_embargo: {
          label: "visibility_after_embargo",
          value: []
        },
        visibility_during_lease: {
          label: "visibility_during_lease",
          value: []
        },
        lease_expiration_date: {
          label: "lease_expiration_date",
          value: []
        },
        visibility_after_lease: {
          label: "visibility_after_lease",
          value: []
        },
        visibility: { label: "visibility", value: [] },
        embargo_length: { label: "embargo_length", value: [] },
        files_embargoed: { label: "files_embargoed", value: [] },
        abstract_embargoed: { label: "abstract_embargoed", value: [] },
        toc_embargoed: { label: "toc_embargoed", value: [] }
      }
    },
    submit: {
      label: "Submit",
      selected: false
    }
  },
  hyrax: {
    contributor: [],
    description: [],
    license: [],
    rights_statement: [],
    publisher: [],
    date_created: [],
    subject: [],
    identifier: [],
    based_near: [],
    related_url: [],
    ordered_member_ids: [],
    source: [],
    in_works_ids: [],
    member_of_collection_ids: [],
    admin_set_id: [],
    resource_type: []
  }
}

