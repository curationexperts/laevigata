/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Embargo from 'Embargo'

describe('Embargo.vue', () => {
  it('has the correct html', () => {
    const wrapper = shallowMount(Embargo, {
    })
    expect(wrapper.html()).toContain(`<select name="etd[embargo_length]" aria-required="true" id="embargo-length" class="form-control"></select>`)
  })
})
