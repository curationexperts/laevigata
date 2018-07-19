/* global describe */
/* global it */
/* global expect */

import { shallowMount } from '@vue/test-utils'
import CommitteeMember from 'CommitteeMember'

describe('CommitteeMember.vue', () => {
  it('renders two links to start with', () => {
    const wrapper = shallowMount(CommitteeMember, {
    })
    expect(wrapper.findAll('button')).toHaveLength(2)
  })
})
