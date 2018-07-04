/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import CommitteeMember from 'CommitteeMember'

describe('CommitteeMember.vue', () => {
  it('renders two links to start with', () => {
    const wrapper = shallowMount(CommitteeMember, {
    })
    expect(wrapper.findAll('a')).toHaveLength(2)
  })

  it('has the correct html', () => {
    const wrapper = shallowMount(CommitteeMember, {
    })
    expect(wrapper.html()).toEqual('<div> <p><a data-turbolinks="false">Add Another Chair or Advisor</a></p>  <p><a data-turbolinks="false">Add Another Committee Member</a></p></div>')
  })
})