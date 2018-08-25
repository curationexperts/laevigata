/* global describe */
/* global it */
/* global expect */

import { shallowMount, mount } from '@vue/test-utils'
import CommitteeMember from 'CommitteeMember'
import { formStore } from 'formStore'

formStore.savedData['committee_chair_attributes'] = {"0":{"affiliation_type":"Emory University","name":["Person"]},"1":{"affiliation_type":"Emory University","name":["Someone"]}}
formStore.savedData['committee_members_attributes'] = {"0":{"affiliation_type":"Non-Emory University","name":["Member"]},"1":{"affiliation_type":"Emory University","name":["Someone"]}}

describe('CommitteeMember.vue', () => {
  it('renders two links to start with', () => {
    const wrapper = shallowMount(CommitteeMember, {
    })
    expect(wrapper.findAll('button')).toHaveLength(2)
  })

  it('loads the data from savedData on mount', () => {
    const wrapper = mount(CommitteeMember, {
    })
    expect(wrapper.html()).toContain('Person')
    expect(wrapper.html()).toContain('Someone')
    expect(wrapper.html()).toContain('Member')
    expect(wrapper.html()).toContain('Non-Emory')
  })
})
