/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount } from '@vue/test-utils'
import PartneringAgency from 'PartneringAgency'

window.localStorage = jest.fn()
window.localStorage.getItem = jest.fn((value) =>{ return 'Rollins School of Public Health' })

describe('PartneringAgency.vue', () => {
  const wrapper = shallowMount(PartneringAgency, {
  })

  it('has the correct html', () => {
    expect(wrapper.html()).toContain('Add Another Partnering Agency')
  })
})
