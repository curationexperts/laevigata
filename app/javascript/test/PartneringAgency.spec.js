/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount } from '@vue/test-utils'
import PartneringAgency from 'PartneringAgency'
import { formStore } from '../formStore'

window.localStorage = jest.fn()
window.localStorage.getItem = jest.fn((value) =>{ return 'Rollins School of Public Health' })
formStore.partneringAgencies.partneringAgencies = jest.fn(() => { return true })

describe('PartneringAgency.vue', () => {
  const wrapper = shallowMount(PartneringAgency, {
  })

  it('has the correct html', () => {
    expect(wrapper.html()).toContain('Add Another Partnering Agency')
  })

  it('has a hidden input in nothing is seleceted', () => {
    expect(wrapper.html()).toContain('hidden')
  })
})
