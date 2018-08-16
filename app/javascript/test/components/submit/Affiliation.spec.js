/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Affiliation from '../../../components/submit/Affiliation'

describe('Affiliation.vue', () => {
  it('shows an affiliation if there is one', () => {
    const member = { affiliation: ['Some other university'] }
    const wrapper = shallowMount(Affiliation, {
      propsData: { member }
    })
    expect(wrapper.html()).toContain('Some other university')
  })

  it('shows the type if no affiliation', () => {
    const member = { affiliation_type: ['Emory University'] }
    const wrapper = shallowMount(Affiliation, {
      propsData: { member }
    })
    expect(wrapper.html()).toContain('Emory University')
  })
})
