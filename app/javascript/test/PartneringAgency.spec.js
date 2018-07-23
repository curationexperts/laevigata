/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount } from '@vue/test-utils'
import PartneringAgency from 'PartneringAgency'

describe('PartneringAgency.vue', () => {
  const wrapper = shallowMount(PartneringAgency, {
  })

  it('has the correct html', () => {
    expect(wrapper.html()).toContain('<div><div><input name="etd[partnering_agency][]" type="hidden" value="No partnering agency."></div></div>')
  })
})
